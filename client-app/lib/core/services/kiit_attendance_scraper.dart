import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' show max;
import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/model/scrape_exception.dart';

/// Scrapes the KIIT SAP portal invisibly using a [HeadlessInAppWebView].
///
/// This mirrors the implementation that is known to work end-to-end against the
/// live portal. Notes (learned from probing the live site):
///  * The portal is SAP NetWeaver Enterprise Portal; the attendance screen is a
///    WebDynpro ABAP iView served from a DIFFERENT origin
///    (https://wdprd.kiituniversity.net:8001). Main-page JS cannot read that
///    iframe (same-origin policy), so a UserScript is injected into ALL frames
///    (`forMainFrameOnly: false`) at `AT_DOCUMENT_START` (required to reach the
///    cross-origin iframe on Android). The copy that lands in the WebDynpro
///    iframe scrapes the table within its own origin and posts the result up to
///    the main frame via `window.top.postMessage`, which relays it to Dart.
///  * Year/Session are WebDynpro DropDownByKey listboxes, not native `select`s:
///    selecting means clicking the dropdown arrow (`#ID-btn`) then the option,
///    which triggers SAP's server round-trip. A plain `change` event does
///    nothing.
class KiitAttendanceScraper {
  static const String loginUrl =
      'https://kiitportal.kiituniversity.net/irj/portal/';

  // A desktop UA so the portal serves the full tree-navigation layout.
  static const String _desktopUa =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

  // Generous safety net for a total network stall; normal failures are bounded
  // by the agent itself (login error, nav exhausted, no data, HTTP 500).
  static const Duration _safetyTimeout = Duration(minutes: 3);

  HeadlessInAppWebView? _headless;

  /// Optional agent script fetched from Remote Config. When null/blank the
  /// scraper uses [_agentTemplate] baked into the binary, so a failed or
  /// unconfigured Remote Config fetch never stops attendance from loading.
  /// Set by the repository before [scrape] from the current Remote Config value.
  String? scriptOverride;

  Future<AttendanceResult> scrape({
    required String username,
    required String password,
    required String academicYear,
    required String session,
    void Function(String message)? onLog,
  }) async {
    // Fail fast when offline: the portal load would otherwise hang until the
    // 3-minute safety timeout. The checker itself failing must never block a
    // scrape, so treat an errored check as "assume online".
    bool online = true;
    try {
      online = await InternetConnection().hasInternetAccess;
    } catch (_) {
      online = true;
    }
    if (!online) {
      throw const ScrapeException(
        ScrapeErrorKind.networkUnavailable,
        "You're offline. Check your internet connection and try again.",
      );
    }

    final completer = Completer<AttendanceResult>();
    var reloadCount = 0;
    var navStarted = false;
    var done = false;

    void log(String m) {
      onLog?.call(m);
      if (kDebugMode) debugPrint('[scrape] $m');
    }

    log('Launching headless WebView and opening the portal '
        '($academicYear / $session)…');

    void finishOk(AttendanceResult r) {
      if (done) return;
      done = true;
      if (!completer.isCompleted) completer.complete(r);
    }

    void finishErr(ScrapeException e) {
      if (done) return;
      done = true;
      if (!completer.isCompleted) completer.completeError(e);
    }

    _headless = HeadlessInAppWebView(
      initialSize: const Size(1280, 900),
      initialUrlRequest: URLRequest(url: WebUri(loginUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        incognito: true,
        userAgent: _desktopUa,
        mediaPlaybackRequiresUserGesture: true,
        transparentBackground: true,
        // The attendance iView is on a different origin/port (wdprd:8001) and
        // the portal mixes resource origins — allow them so the iframe renders.
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source: _agentJs(academicYear, session),
          // AT_DOCUMENT_START is required for the script to be injected into the
          // CROSS-ORIGIN WebDynpro iframe on Android (uses
          // addDocumentStartJavaScript, all-origins). END only reaches the
          // main/same-origin frames.
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
      ]),
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'kiitResult',
          callback: (args) {
            try {
              final result = _resultFromAgentJson(
                args.first as String,
                academicYear: academicYear,
                session: session,
              );
              log('Received attendance data: ${result.records.length} '
                  'subject(s)'
                  '${result.student?.name != null ? " for ${result.student!.name}" : ""}.');
              finishOk(result);
            } on ScrapeException catch (e) {
              // Already classified (e.g. a changed column layout) — keep the
              // kind so the user gets the matching guidance.
              log('ERROR [${e.kind.name}]: ${e.message}');
              finishErr(e);
            } catch (e) {
              log('Failed to parse attendance JSON: $e');
              finishErr(
                ScrapeException(ScrapeErrorKind.unknown, 'Parse error: $e'),
              );
            }
            return null;
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'kiitError',
          callback: (args) {
            try {
              final map =
                  jsonDecode(args.first as String) as Map<String, dynamic>;
              final code = (map['code'] ?? '').toString();
              final msg = (map['message'] ?? 'Scrape failed').toString();
              log('ERROR [$code]: $msg');
              finishErr(ScrapeException(_kindFromCode(code), msg));
            } catch (_) {
              log('ERROR: scrape failed (unparseable error payload)');
              finishErr(
                const ScrapeException(ScrapeErrorKind.unknown, 'Scrape failed'),
              );
            }
            return null;
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'kiitLog',
          callback: (args) {
            if (args.isNotEmpty) log('• ${args.first}');
            return null;
          },
        );
      },
      onConsoleMessage: (controller, msg) {
        if (!kDebugMode) return;
        // The KIIT SAP portal ships its own broken/legacy scripts (empty hover
        // frames, theme JS) that spam "Unexpected end of input" and
        // "Cannot read properties of undefined" on every frame. These are the
        // portal's, not ours (our injected script passes a JS syntax check), so
        // drop them to keep the scrape log readable.
        final m = msg.message;
        if (m.contains('Unexpected end of input') ||
            m.contains("Cannot read properties of undefined") ||
            m.contains('origin-keyed agent cluster') ||
            m.contains('document.domain mutation is ignored')) {
          return;
        }
        debugPrint('[webview] $m');
      },
      onReceivedError: (controller, request, error) {
        // A main-frame load failing with a connectivity error type means the
        // connection dropped mid-fetch. Sub-resource errors (blocked CSS/SVG,
        // ORB) are noise — only the main document matters here.
        final offlineTypes = {
          WebResourceErrorType.NOT_CONNECTED_TO_INTERNET,
          WebResourceErrorType.NETWORK_CONNECTION_LOST,
          WebResourceErrorType.CANNOT_CONNECT_TO_HOST,
          WebResourceErrorType.HOST_LOOKUP,
          WebResourceErrorType.TIMEOUT,
          WebResourceErrorType.IO,
          WebResourceErrorType.SERVER_UNREACHABLE,
          WebResourceErrorType.CANNOT_LOAD_FROM_NETWORK,
        };
        final desc = error.description.toUpperCase();
        final offlineDesc = desc.contains('INTERNET_DISCONNECTED') ||
            desc.contains('NAME_NOT_RESOLVED') ||
            desc.contains('ADDRESS_UNREACHABLE') ||
            desc.contains('NETWORK_CHANGED');
        if ((request.isForMainFrame ?? false) &&
            (offlineTypes.contains(error.type) || offlineDesc)) {
          finishErr(const ScrapeException(
            ScrapeErrorKind.networkUnavailable,
            "You lost your internet connection. Check it and try again.",
          ));
          return;
        }
        log('Network error loading ${request.url}: ${error.description}');
      },
      // wdprd:8001 requests a TLS client certificate; proceed without one
      // (same as a desktop browser) so the WebDynpro iframe still loads.
      onReceivedClientCertRequest: (controller, challenge) async {
        log('Client-certificate requested by ${challenge.protectionSpace.host}'
            ' — proceeding without a certificate.');
        return ClientCertResponse(
          certificatePath: '',
          action: ClientCertResponseAction.IGNORE,
        );
      },
      onLoadStop: (controller, url) async {
        if (done) return;
        // Detect + fill the login form with INLINE JS rather than a function
        // installed by the agent. This is self-contained (no dependency on the
        // agent being installed/timed on the main frame — the earlier failure
        // mode where "the login form exists but the app couldn't load it") and
        // it scans every same-origin frame with generic selectors, so a form in
        // a nested frame or with non-default field ids is still handled.
        final state = (await controller.evaluateJavascript(
          source: _loginProbeJs(username, password),
        ))
            ?.toString()
            .replaceAll('"', '');
        log('Page loaded: $url${state != null ? ' (state: $state)' : ''}');

        switch (state) {
          case 'is500':
            if (reloadCount++ < 6) {
              log('Portal returned an HTTP 500 page — reloading '
                  '(attempt $reloadCount/6).');
              await controller.reload();
            } else {
              finishErr(const ScrapeException(
                ScrapeErrorKind.portalUnavailable,
                'The portal is returning errors (HTTP 500). Please try again.',
              ));
            }
            return;

          case 'bad_creds':
          case 'form_again':
            log('Login page shows the form again / an error → invalid credentials.');
            finishErr(const ScrapeException(
              ScrapeErrorKind.invalidCredentials,
              'Your registration number or password is incorrect.',
            ));
            return;

          case 'submitted':
            log('Login form detected — filled and submitted credentials.');
            return;

          case 'logged_in':
            if (!navStarted) {
              navStarted = true;
              log('Logged in. Navigating: Student Self Service → '
                  'Student Attendance Details…');
              await controller.evaluateJavascript(
                source: 'window.__kiitNavigate && window.__kiitNavigate()',
              );
            }
            return;

          default:
            // 'waiting' or null: page/redirect still settling — retry on the
            // next load. Keep it out of the user-facing log.
            if (kDebugMode) {
              debugPrint('[scrape] Waiting for login form / portal to settle.');
            }
            return;
        }
      },
    );

    log('Starting headless run.');
    await _headless!.run();
    try {
      return await completer.future.timeout(
        _safetyTimeout,
        onTimeout: () => throw const ScrapeException(
          ScrapeErrorKind.timeout,
          'Timed out while fetching your attendance. '
          'Check your internet connection and try again.',
        ),
      );
    } finally {
      log('Scrape finished — disposing WebView.');
      await dispose();
    }
  }

  Future<void> dispose() async {
    try {
      await _headless?.dispose();
    } catch (_) {}
    _headless = null;
  }

  /// Maps the agent's JSON into this app's [AttendanceResult].
  ///
  /// The agent emits the raw table — `{name, headers:[...], rows:[[...]]}` — and
  /// the mapping from columns to fields happens HERE, by header name, so a
  /// user-reordered table is handled entirely app-side. A legacy
  /// `{name, records:[...]}` payload (from an older Remote Config script) is
  /// still accepted.
  static AttendanceResult _resultFromAgentJson(
    String json, {
    required String academicYear,
    required String session,
  }) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final name = (map['name'] ?? '').toString().trim();

    List<AttendanceRecord> records;
    if (map['rows'] is List) {
      final headers = ((map['headers'] as List?) ?? const [])
          .map((h) => h.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim())
          .toList();
      final rows = (map['rows'] as List)
          .whereType<List>()
          .map((r) => r.map((c) => (c ?? '').toString().trim()).toList())
          .toList();
      records = _recordsFromGrid(headers, rows);
      if (kDebugMode && records.isEmpty && rows.isNotEmpty) {
        // The agent captured rows but none mapped to a record — dump the actual
        // headers + first row so the column layout can be matched exactly.
        debugPrint('[scrape] EMPTY PARSE — headers=$headers');
        debugPrint('[scrape] EMPTY PARSE — row0=${rows.first}');
      }
    } else {
      records = _recordsFromLegacy((map['records'] as List?) ?? const []);
    }

    // Dedupe by subject + faculty id (DOM and response rows can arrive for the
    // same subject with slightly different formatting).
    final seen = <String>{};
    records = records.where((r) {
      final k = '${r.subject.toLowerCase().trim()}|${r.facultyId.trim()}';
      return r.subject.trim().isNotEmpty && seen.add(k);
    }).toList();

    return AttendanceResult(
      records: records,
      student: name.isEmpty ? null : StudentDetails(name: name),
      academicYear: academicYear,
      session: session,
      fetchedAt: DateTime.now(),
    );
  }

  /// Test seam: run the raw-grid mapping (`{headers, rows}` → records) exactly
  /// as it runs on a live scrape, so the column-disambiguation logic can be
  /// verified without a device.
  @visibleForTesting
  static List<AttendanceRecord> recordsFromGridForTest(
    List<String> headers,
    List<List<String>> rows,
  ) =>
      _recordsFromGrid(headers, rows);

  static List<AttendanceRecord> _recordsFromLegacy(List raw) {
    int toInt(dynamic v) =>
        v is num ? v.round() : (double.tryParse('$v')?.round() ?? 0);
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);
    return raw.whereType<Map>().map((e) {
      final m = e.cast<String, dynamic>();
      final attended = toInt(m['attended']);
      final total = toInt(m['total']);
      return AttendanceRecord(
        subject: (m['subject'] ?? '').toString(),
        present: attended,
        totalDays: total,
        absent: (total - attended) < 0 ? 0 : total - attended,
        percentage: toDouble(m['percentage']),
        facultyId: (m['facultyId'] ?? '').toString(),
        facultyName: (m['facultyName'] ?? '').toString(),
        excuses: toInt(m['excuses']),
      );
    }).toList();
  }

  /// Maps the raw grid to records using ONLY the column header names SAP sends.
  ///
  /// Column *identity* always comes from the header name — never from a cell's
  /// position or the shape of its value. A column the user hid on the portal is
  /// then reconstructed arithmetically from the ones that are still there, so a
  /// customised table keeps working without asking anyone to restore it:
  ///
  ///  * total   = present + absent
  ///  * present = total - absent            (or percentage x total)
  ///  * absent  = total - present
  ///  * total   = present / percentage      (or absent / (1 - percentage))
  ///  * percentage = present / total
  ///
  /// Only a table with no subject column, or with fewer than two of the four
  /// numeric columns, is unreadable — that alone raises
  /// [ScrapeErrorKind.columnsChanged].
  /// Headers of columns that hold no attendance value — the row-selection
  /// column and friends. The portal names it "Column for row selection", and
  /// it has a header but emits no cell, so it is treated as blank.
  static final RegExp _controlHeader = RegExp(
    r'row selection|select a row|selection column|spacebar|checkbox',
  );

  static List<AttendanceRecord> _recordsFromGrid(
    List<String> allHeaders,
    List<List<String>> rows,
  ) {
    final headers = allHeaders
        .map((h) => _controlHeader.hasMatch(h) ? '' : h)
        .toList();

    // The header row can carry columns the data rows don't emit at all. When
    // that leaves the two out of step, retry with those leading headers
    // dropped — a pure width reconciliation, no reading of the values.
    final widths = rows
        .where((r) => r.any((c) => c.trim().isNotEmpty))
        .map((r) => r.length)
        .toSet();
    for (final width in [headers.length, ...widths]) {
      final drop = headers.length - width;
      final candidate =
          drop > 0 ? headers.sublist(drop) : headers;
      final records = _mapRows(candidate, rows);
      if (records.isNotEmpty) return records;
    }

    return _mapRows(headers, rows, reportFailure: true);
  }

  static List<AttendanceRecord> _mapRows(
    List<String> headers,
    List<List<String>> rows, {
    bool reportFailure = false,
  }) {
    int col(RegExp re, {RegExp? not}) {
      for (var i = 0; i < headers.length; i++) {
        if (re.hasMatch(headers[i]) &&
            (not == null || !not.hasMatch(headers[i]))) {
          return i;
        }
      }
      return -1;
    }

    List<int> cols(RegExp re) {
      final found = <int>[];
      for (var i = 0; i < headers.length; i++) {
        if (re.hasMatch(headers[i])) found.add(i);
      }
      return found;
    }

    final subjectI = col(RegExp(r'subject|course|paper'), not: RegExp(r'fac'));
    final absentI = col(RegExp(r'absent'));
    final presentI = col(RegExp(r'present'));
    final totalI = col(RegExp(r'total.*day|day.*total'));
    final percentageI = col(RegExp(r'percent'));
    final excusesI = col(RegExp(r'excuse'));

    // The portal labels the faculty id column "Faculty Name" too, so the name
    // regex can match twice. With nothing in the headers to tell them apart,
    // the first of the pair is the id and the last is the name.
    final facultyColumns = cols(RegExp(r'fac.*name|teacher.*name'));
    final explicitIdI = col(RegExp(r'fac.*id|faculty.*code'));
    final facultyIdI = explicitIdI >= 0
        ? explicitIdI
        : (facultyColumns.length > 1 ? facultyColumns.first : -1);
    final facultyNameI = facultyColumns.isEmpty ? -1 : facultyColumns.last;

    if (subjectI < 0) {
      if (!reportFailure) return const [];
      throw const ScrapeException(
        ScrapeErrorKind.columnsChanged,
        'Your attendance table on the portal has no subject column, so there '
        'is nothing to label your attendance with.',
      );
    }
    final numericColumns =
        [absentI, presentI, totalI, percentageI].where((i) => i >= 0).length;
    if (numericColumns < 2) {
      if (!reportFailure) return const [];
      throw const ScrapeException(
        ScrapeErrorKind.columnsChanged,
        'Your attendance table on the portal is showing too few columns to '
        'work out your attendance from.',
      );
    }

    String at(List<String> cells, int i) =>
        (i >= 0 && i < cells.length) ? cells[i] : '';

    // Values are read by column position, so a row that doesn't line up with
    // the header row is dropped rather than mapped into plausible nonsense.
    final widest = [subjectI, absentI, presentI, totalI, percentageI]
        .reduce(max) +
        1;
    var misaligned = 0;

    final letter = RegExp(r'[A-Za-z]');
    final out = <AttendanceRecord>[];
    for (final raw in rows) {
      // Tables are padded with blank rows; those aren't a layout problem.
      if (raw.every((c) => c.trim().isEmpty)) continue;

      final cells = _alignToHeaders(headers, raw);
      final subject = at(cells, subjectI).trim();
      // A row that doesn't reach the header row's width, or whose subject
      // column holds no text, is sitting one or more columns out of line.
      if (cells.length < widest || !letter.hasMatch(subject)) {
        misaligned++;
        continue;
      }

      final counts = _countsFor(
        present: _cellToNullableInt(at(cells, presentI)),
        absent: _cellToNullableInt(at(cells, absentI)),
        total: _cellToNullableInt(at(cells, totalI)),
        percentage: _cellToNullableDouble(at(cells, percentageI)),
      );
      if (counts == null) continue;

      out.add(AttendanceRecord(
        subject: subject,
        present: counts.present,
        totalDays: counts.total,
        absent: counts.absent,
        percentage: counts.percentage,
        facultyId: at(cells, facultyIdI).trim(),
        facultyName: at(cells, facultyNameI).trim(),
        excuses: _cellToInt(at(cells, excusesI)),
      ));
    }

    if (out.isEmpty && misaligned > 0 && reportFailure) {
      if (kDebugMode) {
        debugPrint('[scrape] UNALIGNED — headers=$headers');
        debugPrint(
            '[scrape] UNALIGNED — row0=${rows.isEmpty ? '[]' : rows.first}');
      }
      throw const ScrapeException(
        ScrapeErrorKind.columnsChanged,
        'The columns on your attendance table did not line up with its '
        'headers, so nothing could be read from it.',
      );
    }
    return out;
  }

  /// Lines a data row up with the header row.
  ///
  /// The portal's header row and its data rows don't always carry the same
  /// number of cells: the row-selection column has a header but no `gridcell`,
  /// and some layouts add a trailing filler. Padding is added or dropped at
  /// whichever end is blank, so the cell at a header's position really is that
  /// header's value. A row that can't be reconciled is returned untouched and
  /// gets rejected by the caller's checks.
  static List<String> _alignToHeaders(
    List<String> headers,
    List<String> cells,
  ) {
    if (headers.isEmpty || headers.length == cells.length) return cells;

    if (cells.length < headers.length) {
      final gap = headers.length - cells.length;
      // Leading headers with no text (the selection column) own no cell.
      if (headers.take(gap).every((h) => h.trim().isEmpty)) {
        return [...List.filled(gap, ''), ...cells];
      }
      // Otherwise the row is short at the end (hidden trailing columns).
      if (headers.skip(headers.length - gap).every((h) => h.trim().isEmpty)) {
        return [...cells, ...List.filled(gap, '')];
      }
      // Blank headers at both ends: pad each side by the blanks it owns.
      var lead = 0;
      while (lead < headers.length && headers[lead].trim().isEmpty) {
        lead++;
      }
      var trail = 0;
      while (trail < headers.length - lead &&
          headers[headers.length - 1 - trail].trim().isEmpty) {
        trail++;
      }
      if (lead + trail == gap) {
        return [
          ...List.filled(lead, ''),
          ...cells,
          ...List.filled(trail, ''),
        ];
      }
      return cells;
    }

    final extra = cells.length - headers.length;
    // Extra leading cells with no text (a selection cell with no header).
    if (cells.take(extra).every((c) => c.trim().isEmpty)) {
      return cells.sublist(extra);
    }
    if (cells.skip(cells.length - extra).every((c) => c.trim().isEmpty)) {
      return cells.sublist(0, headers.length);
    }
    return cells;
  }

  /// Fills in whichever of present/absent/total/percentage the portal isn't
  /// showing, using the others. Returns null when the row holds too little to
  /// reconstruct.
  static _RowCounts? _countsFor({
    int? present,
    int? absent,
    int? total,
    double? percentage,
  }) {
    if (total == null && present != null && absent != null) {
      total = present + absent;
    }
    if (present == null && total != null && absent != null) {
      present = total - absent;
    }
    if (absent == null && total != null && present != null) {
      absent = total - present;
    }

    // Only a percentage plus one count: scale one into the other.
    final fraction = percentage == null ? null : percentage / 100;
    if (fraction != null && fraction > 0 && fraction <= 1) {
      if (total == null && present != null) {
        total = (present / fraction).round();
        absent = total - present;
      } else if (total == null && absent != null && fraction < 1) {
        total = (absent / (1 - fraction)).round();
        present = total - absent;
      } else if (total != null && present == null) {
        present = (fraction * total).round();
        absent = total - present;
      }
    }

    if (present == null || absent == null || total == null) return null;
    if (present < 0) present = 0;
    if (absent < 0) absent = 0;
    if (total <= 0) return null;
    if (present > total) present = total;

    return _RowCounts(
      present: present,
      absent: absent,
      total: total,
      percentage:
          percentage ?? (present / total * 10000).round() / 100,
    );
  }

  /// Portal counts render as either "30" or "30.00".
  static int _cellToInt(String cell) =>
      double.tryParse(cell.trim())?.round() ?? 0;

  /// Null when the column is hidden or the cell is blank, so a missing value is
  /// never confused with a real zero.
  static int? _cellToNullableInt(String cell) =>
      double.tryParse(cell.trim())?.round();

  static double? _cellToNullableDouble(String cell) =>
      double.tryParse(cell.trim());

  static ScrapeErrorKind _kindFromCode(String code) {
    switch (code) {
      case 'no_data':
        return ScrapeErrorKind.noData;
      case 'invalid_credentials':
        return ScrapeErrorKind.invalidCredentials;
      case 'nav_failed':
        return ScrapeErrorKind.navigationFailed;
      case 'columns_changed':
        return ScrapeErrorKind.columnsChanged;
      default:
        return ScrapeErrorKind.unknown;
    }
  }

  // Self-contained login probe injected on every onLoadStop. Scans the main
  // document AND every same-origin frame for the SAP logon form (by id, then by
  // generic input types), fills + submits it once, and otherwise reports the
  // page state. Credentials are interpolated at call time (never stored in the
  // agent template) and this runs inline, so login does not depend on the
  // agent script having installed a helper on the main frame.
  // Returns one of: submitted | bad_creds | form_again | is500 | logged_in |
  // waiting.
  static String _loginProbeJs(String username, String password) {
    final u = jsonEncode(username);
    final p = jsonEncode(password);
    return '''
(function(){
  function docs(){ var d=[document]; (function rec(w){ try{ for(var i=0;i<w.frames.length;i++){ try{ var x=w.frames[i].document; if(x){ d.push(x); rec(w.frames[i]); } }catch(e){} } }catch(e){} })(window); return d; }
  var ds=docs(), pf=null, uf=null, dw=null;
  for(var i=0;i<ds.length;i++){
    var f=ds[i].querySelector('#logonpassfield') || ds[i].querySelector('input[type=password]');
    if(f){ pf=f; dw=ds[i];
      uf=ds[i].querySelector('#logonuidfield') || ds[i].querySelector('input[type=text]') ||
         ds[i].querySelector('input:not([type=password]):not([type=hidden]):not([type=submit]):not([type=checkbox])');
      break; }
  }
  var bt=''; for(var k=0;k<ds.length;k++){ try{ bt += ' ' + (ds[k].body ? ds[k].body.innerText : ''); }catch(e){} }
  if(pf){
    if(/logon failed|authentication failed|invalid|incorrect|not authorized|wrong user|user is locked|failed to/i.test(bt)) return 'bad_creds';
    // Count submits in sessionStorage (survives the post-submit navigation,
    // per-origin, empty each incognito scrape) so we submit once and, if the
    // form keeps coming back without an error, bail instead of looping.
    var tries=0; try{ tries=parseInt(sessionStorage.getItem('kiitLoginTries')||'0',10)||0; }catch(e){}
    if(tries>=2) return 'form_again';
    try{ sessionStorage.setItem('kiitLoginTries', String(tries+1)); }catch(e){}
    try{
      if(uf){ uf.value=$u; uf.dispatchEvent(new Event('input',{bubbles:true})); uf.dispatchEvent(new Event('change',{bubbles:true})); }
      pf.value=$p; pf.dispatchEvent(new Event('input',{bubbles:true})); pf.dispatchEvent(new Event('change',{bubbles:true}));
      var btn=dw.querySelector('input[type=submit]') || dw.querySelector('#logonSubmit') || dw.querySelector('button[type=submit]') || dw.querySelector('a[role=button]');
      var form=dw.querySelector('#logonForm') || dw.querySelector('form[name=certLogonForm]') || pf.form || dw.querySelector('form');
      if(btn){ btn.click(); }
      else if(form && form.submit){ form.submit(); }
      else { pf.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',keyCode:13,which:13,bubbles:true})); }
    }catch(e){ return 'waiting'; }
    return 'submitted';
  }
  if(/Internal Server Error|WebApplicationException|Application error occurred/i.test(bt)) return 'is500';
  if(/Student Self Service|Detailed Navigation|Attendance|Overview|Log ?off|Log ?out/i.test(bt)) return 'logged_in';
  return 'waiting';
})()
''';
  }

  // The injected agent. RAW string so JS regex backslashes survive; the two
  // config literals are substituted in (they are constants, not secrets —
  // credentials are entered by the inline login probe, never baked into this
  // script). Prefers the Remote Config script when present, else the baked-in
  // template.
  String _agentJs(String year, String session) {
    final override = scriptOverride?.trim();
    final template = (override != null && override.isNotEmpty)
        ? scriptOverride!
        : _agentTemplate;
    return template
        .replaceAll('__YEAR__', year.replaceAll('"', r'\"'))
        .replaceAll('__SESSION__', session.replaceAll('"', r'\"'));
  }
}
const String _agentTemplate = r'''
(function () {
  var IS_TOP = (window.top === window.self);
  var YEAR = "__YEAR__";
  var SESSION = "__SESSION__";
  function sleep(ms){ return new Promise(function (r) { setTimeout(r, ms); }); }

  // ===================== MAIN / TOP FRAME =====================
  if (IS_TOP) {
    if (window.__kiitTopInstalled) return;
    window.__kiitTopInstalled = true;

    function clog(m) {
      try { if (window.flutter_inappwebview) window.flutter_inappwebview.callHandler('kiitLog', m); } catch (e) {}
    }
    function cerr(code, message) {
      try { if (window.flutter_inappwebview) window.flutter_inappwebview.callHandler('kiitError', JSON.stringify({ code: code, message: message })); } catch (e) {}
    }

    // Relay messages posted up from the cross-origin WebDynpro iframe.
    window.addEventListener('message', function (ev) {
      var d = ev.data;
      if (typeof d === 'string' && d.indexOf('__KIIT__') === 0) {
        try {
          var msg = JSON.parse(d.substring(8));
          if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler(msg.handler, msg.payload);
          }
        } catch (e) {}
      }
    });

    // (Login is driven from Dart via an inline probe — see _loginProbeJs — so
    // no login helper is installed here; this frame only handles navigation.)

    // Collect every same-origin document (cross-origin frames throw -> skipped).
    function allDocs() {
      var docs = [document];
      (function rec(win) {
        try {
          for (var i = 0; i < win.frames.length; i++) {
            try {
              var d = win.frames[i].document;
              if (d) { docs.push(d); rec(win.frames[i]); }
            } catch (e) {}
          }
        } catch (e) {}
      })(window);
      return docs;
    }
    function navNorm(s) { return (s || '').replace(/\s+/g, ' ').trim(); }
    function navFire(el) {
      try { el.scrollIntoView({ block: 'center' }); } catch (_) {}
      var o = { bubbles: true, cancelable: true, view: window };
      try { el.dispatchEvent(new MouseEvent('mousedown', o)); } catch (_) {}
      try { el.dispatchEvent(new MouseEvent('mouseup', o)); } catch (_) {}
      try { el.dispatchEvent(new MouseEvent('click', o)); } catch (_) {}
      try { el.click(); } catch (_) {}
    }
    function clickByText(text, exact, skipTop) {
      var ds = allDocs();
      var want = text.toLowerCase();
      for (var k = skipTop ? 1 : 0; k < ds.length; k++) {
        var els = ds[k].querySelectorAll('a,span,td,div,li');
        for (var i = 0; i < els.length; i++) {
          var e = els[i];
          if (e.children.length !== 0) continue;
          var t = navNorm(e.textContent).toLowerCase();
          if (!t) continue;
          if (exact ? (t === want) : (t.indexOf(want) >= 0)) {
            // Click the nearest clickable ancestor (tree nodes wrap the text in
            // a span but hang the handler on the <a>/<li>); fall back to the leaf.
            var target = (e.closest && e.closest('a,[role="link"],[role="treeitem"],[onclick],li,td')) || e;
            navFire(target);
            return true;
          }
        }
      }
      return false;
    }
    // Diagnostic: visible nav-ish leaf texts across same-origin frames, so a
    // failure log reveals the portal's actual labels (and whether the tree is
    // even reachable) to fix the matcher.
    function dumpNavTexts() {
      var ds = allDocs();
      var out = [], seen = {};
      var re = /student|attendance|self\s*service|exam|fee|grade|semester|result|hall/i;
      for (var k = 0; k < ds.length; k++) {
        var els = ds[k].querySelectorAll('a,span,td,div,li');
        for (var i = 0; i < els.length && out.length < 40; i++) {
          if (els[i].children.length !== 0) continue;
          var t = navNorm(els[i].textContent);
          if (t && t.length < 60 && re.test(t) && !seen[t]) { seen[t] = 1; out.push(t); }
        }
      }
      return out.join(' | ');
    }
    // Expand the left-nav "Student Self Service" folder (the tree node lives in
    // an inner content frame, so skipTop avoids hitting the top-level tab), then
    // poll for and click the "Student Attendance Details" service link.
    window.__kiitNavigate = async function () {
      if (window.__kiitNavStarted) return 'already';
      window.__kiitNavStarted = true;
      clog('Expanding the "Student Self Service" navigation folder.');
      // Click the top-level workset tab (loads the detailed-nav tree) AND the
      // inner tree node; contains-match tolerates the "… for SOT (2025 Batch)"
      // suffix on the tab.
      clickByText('student self service', false, false);
      clickByText('student self service', true, true);
      for (var i = 0; i < 60; i++) {
        await sleep(1000);
        // A same-origin child nav frame may have already opened the service;
        // its sessionStorage flag is shared with us, so don't re-launch the
        // iView (a second launch aborts the pending SAP session mid-scrape).
        if (navDone2()) { clog('Attendance service already opened; not re-launching.'); return 'clicked'; }
        if (clickByText('student attendance details', false, false)) {
          markNav2();
          clog('Found and clicked "Student Attendance Details". Loading iView…');
          return 'clicked';
        }
        if (i % 5 === 4) {
          clog('Still waiting for the "Student Attendance Details" link (' + (i + 1) + 's)…');
          clickByText('student self service', false, false);
          clickByText('student self service', true, true);
        }
      }
      cerr('nav_failed', 'Could not reach Student Attendance Details. frames=' +
          allDocs().length + '; nav texts seen: [' +
          dumpNavTexts().slice(0, 400) + ']');
      return 'not_found';
    };
    return;
  }

  // ===================== CHILD FRAME (WebDynpro iView) =====================
  // Capture the WebDynpro attendance response body. The agent runs INSIDE the
  // wdprd frame (same-origin as its own XHRs), so hooking XHR here lets us read
  // the full server response — which lists EVERY row as a TextView, bypassing
  // the DOM row virtualization that otherwise drops rows below the fold.
  // Keep EVERY matching response: the table pages in more rows on scroll, and
  // each scroll fires a fresh (often smaller) delta response, so we can't just
  // keep the longest one.
  window.__kiitResps = [];
  (function () {
    try {
      var send = XMLHttpRequest.prototype.send;
      XMLHttpRequest.prototype.send = function () {
        try {
          this.addEventListener('load', function () {
            try {
              var u = this.responseURL || '';
              var t = this.responseText || '';
              if (t && (/ZWDA_HRIQ_ST_ATTENDANCE/i.test(u) || /Total Percentage|Faculty Name/i.test(t))) {
                window.__kiitResps.push(t);
              }
            } catch (e) {}
          });
        } catch (e) {}
        return send.apply(this, arguments);
      };
    } catch (e) {}
  })();
  function kiitDecodeEntities(s) {
    return String(s)
      .replace(/&#x([0-9a-fA-F]+);/g, function (_, h) { return String.fromCharCode(parseInt(h, 16)); })
      .replace(/&#(\d+);/g, function (_, d) { return String.fromCharCode(parseInt(d, 10)); })
      .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"')
      .replace(/\s+/g, ' ').trim();
  }
  // The agent does NO column interpretation — it extracts the table as raw
  // rows of cell strings (aligned to the header labels) and the app maps
  // columns by name. These predicates only classify a cell enough to find the
  // data rows inside the raw response (skip the student-detail preamble and the
  // header labels); the app decides what each column means.
  function isFacStr(x) { return /^\d{5,}$/.test(x); }
  function isDecStr(x) { return /^\d+\.\d+$/.test(x); }
  function isIntStr(x) { return /^\d+$/.test(x); }
  function looksDataRow(a, n) {
    if (a.length < n) return false;
    var fac = 0, alpha = 0, numeric = 0;
    for (var i = 0; i < n; i++) {
      var v = a[i];
      if (isFacStr(v)) fac++;
      else if (isDecStr(v) || isIntStr(v)) numeric++;
      else if (/[A-Za-z]/.test(v)) alpha++;
    }
    return fac === 1 && alpha >= 2 && numeric >= 3;
  }
  // Group one response body's flat TextView values into raw rows. The number of
  // columns is DERIVED from the data (every row has exactly one faculty id, so
  // the gap between consecutive ids is the column count) rather than assumed —
  // this is independent of the DOM header and of any user column reordering.
  function respRowsOf(body) {
    var vals = [], re = /ct="TV" lsdata='\{"0":"([^"]*)"/g, m;
    while ((m = re.exec(body))) vals.push(kiitDecodeEntities(m[1]));
    var fac = [];
    for (var i = 0; i < vals.length; i++) if (isFacStr(vals[i])) fac.push(i);
    if (!fac.length) return { name: '', rows: [] };
    // Stride = most common gap between faculty-id positions.
    var n = 8;
    if (fac.length >= 2) {
      var gaps = {}, best = -1;
      for (var k = 1; k < fac.length; k++) {
        var g = fac[k] - fac[k - 1];
        if (g > 0) { gaps[g] = (gaps[g] || 0) + 1; if (gaps[g] > best) { best = gaps[g]; n = g; } }
      }
    }
    if (n < 6 || n > 24) n = 8; // sanity clamp
    // Offset of the faculty id within a row (constant), found by aligning the
    // first id to a window that looks like a data row.
    var off = -1;
    for (var a = 0; a < n; a++) {
      var s0 = fac[0] - a;
      if (s0 >= 0 && looksDataRow(vals.slice(s0, s0 + n), n)) { off = a; break; }
    }
    if (off < 0) return { name: '', rows: [] };
    var start = fac[0] - off;
    var rows = [], name = '';
    if (start >= 6) name = vals[start - 6 + 2] || '';
    for (var j = start; j + n <= vals.length; j += n) {
      var grp = vals.slice(j, j + n);
      if (!looksDataRow(grp, n)) break;
      rows.push(grp);
    }
    return { name: name, rows: rows };
  }
  // Merge raw rows from every captured response (the scroll deltas), deduped by
  // full-row signature.
  function respGrid() {
    var seen = {}, out = [], name = '';
    var all = window.__kiitResps || [];
    for (var i = 0; i < all.length; i++) {
      var p = respRowsOf(all[i]);
      if (p.name) name = p.name;
      for (var j = 0; j < p.rows.length; j++) {
        var sig = p.rows[j].join('|').toLowerCase();
        if (sig && !seen[sig]) { seen[sig] = 1; out.push(p.rows[j]); }
      }
    }
    return { name: name, rows: out };
  }
  function isAttendanceApp() {
    var ls = document.querySelectorAll('label');
    for (var i = 0; i < ls.length; i++) {
      if (ls[i].textContent.trim() === 'Year') return true;
    }
    return false;
  }
  function relay(handler, payload) {
    try {
      window.top.postMessage('__KIIT__' + JSON.stringify({ handler: handler, payload: payload }), '*');
    } catch (e) {}
  }
  // Open a WebDynpro DropDownByKey by its label and click the matching option.
  async function pick(labelText, optionText) {
    var ls = document.querySelectorAll('label'), label = null;
    for (var i = 0; i < ls.length; i++) {
      if (ls[i].textContent.trim() === labelText) { label = ls[i]; break; }
    }
    if (!label) return false;
    var inputId = label.getAttribute('for');
    var arrow = document.getElementById(inputId + '-btn') || document.getElementById(inputId);
    if (!arrow) return false;
    arrow.click();
    await sleep(900);
    var opts = document.querySelectorAll('[role=option]');
    var match = null, visMatch = null;
    for (var j = 0; j < opts.length; j++) {
      var o = opts[j];
      var v = (o.getAttribute('data-itemvalue1') || o.textContent || '').trim();
      if (v === optionText) {
        match = match || o;
        if (o.offsetParent !== null) { visMatch = o; break; }
      }
    }
    var target = visMatch || match;
    if (!target) { relay('kiitLog', 'Option "' + optionText + '" not found in the ' + labelText + ' dropdown.'); return false; }
    target.click();
    relay('kiitLog', 'Selected ' + labelText + ' = "' + optionText + '" (waiting for SAP round-trip).');
    await sleep(2600); // SAP server round-trip
    return true;
  }
  // The visible column header labels, in display order, minus the blank
  // selection column. The app maps these names to fields, so a user-reordered
  // column layout is handled entirely app-side.
  // Header and cell arrays MUST stay positionally aligned: the app maps columns
  // by header name and reads the cell at that position, so a dropped blank
  // header (the row-selection column, an icon column) would shift every value
  // after it into the wrong field. Blanks are kept as '' and, when the grid
  // exposes aria-colindex, that index places the value exactly.
  function cellText(el) {
    var t = (el.innerText || el.textContent || '').replace(/\s+/g, ' ').trim();
    return /select a row|row selection|selection column|spacebar/i.test(t) ? '' : t;
  }
  function placeCells(nodes) {
    var ordered = [], byIndex = [], useIndex = nodes.length > 0;
    for (var i = 0; i < nodes.length; i++) {
      var t = cellText(nodes[i]);
      ordered.push(t);
      var ci = parseInt(nodes[i].getAttribute('aria-colindex'), 10);
      if (isNaN(ci) || ci < 1) { useIndex = false; } else { byIndex[ci - 1] = t; }
    }
    if (!useIndex) return ordered;
    for (var k = 0; k < byIndex.length; k++) {
      if (byIndex[k] === undefined) byIndex[k] = '';
    }
    return byIndex;
  }
  function countFilled(arr) {
    var n = 0;
    for (var i = 0; i < arr.length; i++) if (arr[i] !== '') n++;
    return n;
  }
  function gridHeaders() {
    var rows = document.querySelectorAll('[role=row]');
    for (var i = 0; i < rows.length; i++) {
      var hc = rows[i].querySelectorAll('[role=columnheader]');
      if (hc.length < 4) continue;
      var headers = placeCells(hc);
      if (countFilled(headers) >= 4) return headers;
    }
    // Fallback: a plain HTML <table> header.
    var ths = document.querySelectorAll('th');
    if (ths.length >= 4) {
      var hs = placeCells(ths);
      if (countFilled(hs) >= 4) return hs;
    }
    return [];
  }
  function studentName() {
    var bt = document.body ? (document.body.innerText || '').replace(/\s+/g, ' ') : '';
    var m = bt.match(/Student Name\s*:\s*([A-Za-z .]+?)\s+Reg/i);
    return m ? m[1].trim() : '';
  }
  // One snapshot of the rendered table as raw cell arrays aligned to
  // gridHeaders() — no interpretation. Drops the leading selection/checkbox
  // cell so cells line up with the headers.
  function domRowsOnce() {
    var out = [];
    var rows = document.querySelectorAll('[role=row]');
    for (var i = 0; i < rows.length; i++) {
      var gc = rows[i].querySelectorAll('[role=gridcell]');
      if (!gc.length) continue; // header row has columnheader, not gridcell
      var cells = placeCells(gc);
      if (cells.length >= 5) out.push(cells);
    }
    if (out.length) return out;
    // Fallback: plain HTML <table> rows (some WebDynpro tables aren't ARIA grids).
    var trs = document.querySelectorAll('tr');
    for (var r = 0; r < trs.length; r++) {
      var tds = trs[r].querySelectorAll('td');
      if (!tds.length) continue;
      var tcells = placeCells(tds);
      if (tcells.length >= 5) out.push(tcells);
    }
    return out;
  }
  function sendKey(el, k, code) {
    try { el.dispatchEvent(new KeyboardEvent('keydown', { key: k, code: k, keyCode: code, which: code, bubbles: true })); } catch (e) {}
    try { el.dispatchEvent(new KeyboardEvent('keyup', { key: k, code: k, keyCode: code, which: code, bubbles: true })); } catch (e) {}
  }
  function scrollEls() {
    var arr = [];
    var named = document.querySelectorAll('[role=scrollbar], [class*="scroll" i]');
    for (var i = 0; i < named.length; i++) arr.push(named[i]);
    var divs = document.querySelectorAll('div');
    for (var j = 0; j < divs.length; j++) {
      var e = divs[j];
      if (e.clientHeight > 0 && e.scrollHeight > e.clientHeight + 4) arr.push(e);
    }
    return arr;
  }
  // WebDynpro grids virtualize rows: only the visible window is in the DOM and
  // nodes recycle on scroll. Drive the table's own virtual scroll (keyboard nav
  // triggers a server round-trip; programmatic scrollTop alone does not),
  // accumulating UNIQUE rows until nothing new appears — so rows below the fold
  // are captured too.
  // Tunables. Worst case is roughly MAX_STEPS * SETTLE_MS of scrolling.
  // SETTLE_MS must be long enough to clear the SAP scroll round-trip (the table
  // re-renders rows from the server); the loop ends early once STABLE_LIMIT
  // consecutive steps add nothing, or aria-rowcount is reached. Fixed-delay
  // polling is used on purpose: the grid updates via cross-origin XHR deltas, so
  // a MutationObserver would fire mid-delta and settle before all rows arrive.
  var SCROLL_MAX_STEPS = 80;
  var SCROLL_SETTLE_MS = 900;
  var SCROLL_STABLE_LIMIT = 8;
  async function scrapeGrid() {
    var seen = {}, rows = [], name = '', headers = [];
    function harvest() {
      if (!name) name = studentName();
      if (!headers.length) headers = gridHeaders();
      var rs = domRowsOnce();
      for (var i = 0; i < rs.length; i++) {
        var sig = rs[i].join('|').toLowerCase();
        if (sig && !seen[sig]) { seen[sig] = 1; rows.push(rs[i]); }
      }
    }
    var grid = document.querySelector('[role=grid],[role=treegrid]');
    var expected = grid ? (parseInt(grid.getAttribute('aria-rowcount'), 10) || 0) : 0;
    harvest();
    var last = -1, stable = 0;
    for (var step = 0; step < SCROLL_MAX_STEPS; step++) {
      var domRows = document.querySelectorAll('[role=row]');
      var lastRow = domRows.length ? domRows[domRows.length - 1] : null;
      if (lastRow) {
        var cell = lastRow.querySelector('[role=gridcell]') || lastRow;
        try { cell.focus(); } catch (e) {}
        try { cell.click(); } catch (e) {}
        sendKey(cell, 'End', 35);
        sendKey(cell, 'PageDown', 34);
        sendKey(cell, 'ArrowDown', 40);
        sendKey(cell, 'ArrowDown', 40);
        try { lastRow.scrollIntoView({ block: 'end' }); } catch (e) {}
        try { lastRow.dispatchEvent(new WheelEvent('wheel', { deltaY: 800, bubbles: true })); } catch (e) {}
      }
      var els = scrollEls();
      for (var s = 0; s < els.length; s++) {
        try {
          els[s].scrollTop = els[s].scrollHeight;
          els[s].dispatchEvent(new Event('scroll', { bubbles: true }));
        } catch (e) {}
      }
      await sleep(SCROLL_SETTLE_MS); // allow the scroll round-trip to re-render rows
      harvest();
      if (expected > 0 && rows.length >= expected - 1) break; // -1: header counted
      if (rows.length === last) { stable++; if (stable >= SCROLL_STABLE_LIMIT) break; } else { stable = 0; }
      last = rows.length;
    }
    return { name: name, headers: headers, rows: rows };
  }
  // Snapshot of what the page contained, for diagnosing an empty result.
  function gridDiag() {
    function cnt(sel) { try { return document.querySelectorAll(sel).length; } catch (e) { return -1; } }
    var resp = window.__kiitResps || [];
    var tv = 0;
    for (var i = 0; i < resp.length; i++) {
      var mm = resp[i].match(/ct="TV" lsdata=/g);
      tv += mm ? mm.length : 0;
    }
    var bt = document.body ? (document.body.innerText || '').replace(/\s+/g, ' ').slice(0, 160) : '';
    return 'role-row=' + cnt('[role=row]') + ' gridcell=' + cnt('[role=gridcell]') +
      ' colhdr=' + cnt('[role=columnheader]') + ' tr=' + cnt('tr') + ' td=' + cnt('td') +
      ' th=' + cnt('th') + ' resp=' + resp.length + ' respTV=' + tv + ' body="' + bt + '"';
  }
  async function run() {
    if (window.__kiitRan) return;
    window.__kiitRan = true;
    try {
      relay('kiitLog', 'Attendance iView loaded. Setting filters…');
      await pick('Year', YEAR);
      await pick('Session', SESSION);
      var bs = document.querySelectorAll('[role=button]'), btn = null;
      for (var i = 0; i < bs.length; i++) {
        if (/submit/i.test(bs[i].innerText || '')) { btn = bs[i]; break; }
      }
      if (btn) { relay('kiitLog', 'Clicking Submit to load the attendance table.'); btn.click(); await sleep(3000); }
      else { relay('kiitLog', 'Submit button not found; reading whatever is rendered.'); }

      // Extract the WHOLE table as raw rows + header labels and hand it to the
      // app, which maps columns by NAME. scrapeGrid scrolls the virtualized
      // grid to render every row; the response merge (respGrid) recovers rows
      // that DOM virtualization drops. Both keep cells in header order, so one
      // header list labels every row.
      relay('kiitLog', 'Reading the attendance table…');
      var domData = await scrapeGrid();
      var headers = domData.headers;
      var respData = respGrid();
      var name = domData.name || respData.name || '';
      var seen = {}, rows = [];
      function addRows(arr) {
        for (var i = 0; i < arr.length; i++) {
          var sig = arr[i].join('|').toLowerCase();
          if (sig && !seen[sig]) { seen[sig] = 1; rows.push(arr[i]); }
        }
      }
      addRows(domData.rows);
      addRows(respData.rows);
      relay('kiitLog', 'Got ' + rows.length + ' table row(s)' +
        (name ? ' for ' + name : '') +
        ' (dom ' + domData.rows.length + ', resp ' + respData.rows.length +
        ', cols ' + headers.length + ').');
      if (rows.length === 0) {
        // Surface what the page actually contained so an empty result can be
        // diagnosed from the log instead of guessed at.
        relay('kiitLog', 'No rows parsed. DIAG: ' + gridDiag());
        relay('kiitError', JSON.stringify({ code: 'no_data', message: 'The attendance table was empty for the selected year/session.' }));
        return;
      }
      relay('kiitResult', JSON.stringify({ name: name, headers: headers, rows: rows }));
    } catch (e) {
      relay('kiitError', JSON.stringify({ code: 'scrape_error', message: String(e) }));
    }
  }
  // Local portal navigation, run in EVERY frame. The Detailed Navigation tree
  // (with "Student Attendance Details") can live in a cross-origin frame the
  // top frame's DOM walk can't reach — but the agent is injected here too, so
  // whichever frame holds the tree expands the folder and clicks the service.
  function navNorm2(s) { return (s || '').replace(/\s+/g, ' ').trim().toLowerCase(); }
  function navFire2(el) {
    try { el.scrollIntoView({ block: 'center' }); } catch (e) {}
    var o = { bubbles: true, cancelable: true, view: window };
    try { el.dispatchEvent(new MouseEvent('mousedown', o)); } catch (e) {}
    try { el.dispatchEvent(new MouseEvent('mouseup', o)); } catch (e) {}
    try { el.dispatchEvent(new MouseEvent('click', o)); } catch (e) {}
    try { el.click(); } catch (e) {}
  }
  function localDocs2() {
    var docs = [];
    (function rec(w) {
      try {
        var d = w.document; if (!d) return;
        docs.push(d);
        for (var i = 0; i < w.frames.length; i++) { try { rec(w.frames[i]); } catch (e) {} }
      } catch (e) {}
    })(window);
    return docs;
  }
  function clickLocal2(substr) {
    var ds = localDocs2();
    for (var k = 0; k < ds.length; k++) {
      var els = ds[k].querySelectorAll('a,span,td,div,li');
      for (var i = 0; i < els.length; i++) {
        var e = els[i];
        if (e.children.length !== 0) continue;
        var t = navNorm2(e.textContent);
        if (t && t.indexOf(substr) >= 0) {
          var tgt = (e.closest && e.closest('a,[role="treeitem"],[role="link"],[onclick],li,td')) || e;
          navFire2(tgt);
          return true;
        }
      }
    }
    return false;
  }
  // Persistent nav guard. Clicking "Student Attendance Details" reloads this
  // nav frame, which spins up a FRESH JS context and wipes the in-memory
  // __kiitChildRan guard below — so without a guard that survives the reload we
  // re-click forever. Each re-click re-launches the iView with
  // sap-sessioncmd=USR_ABORT, aborting the pending SAP session; the churn
  // eventually kills the renderer (device disconnect). sessionStorage survives
  // the reload (per-origin, and starts empty in the incognito webview each
  // scrape), so the service link is clicked at most once.
  function navDone2() { try { return sessionStorage.getItem('__kiitAttNav') === '1'; } catch (e) { return false; } }
  function markNav2() { try { sessionStorage.setItem('__kiitAttNav', '1'); } catch (e) {} }
  (async function () {
    if (window.__kiitChildRan) return;
    window.__kiitChildRan = true;
    var isWd = /wdprd|webdynpro|ZWDA/i.test(location.href);
    if (isWd) relay('kiitLog', 'Agent injected into WebDynpro frame: ' + location.host);
    for (var i = 0; i < 45; i++) {
      if (isAttendanceApp()) {
        relay('kiitLog', 'Attendance form ready in ' + location.host);
        await run();
        return;
      }
      // If the nav tree lives in this frame, expand the folder and open the
      // service ONCE. The WebDynpro frame holds the form (not the tree), so it
      // must never click — clicking there is what re-launches the iView.
      if (!isWd && !navDone2()) {
        if (clickLocal2('student attendance details')) {
          markNav2();
          relay('kiitLog', 'Clicked Student Attendance Details (' + location.host + ').');
        } else {
          clickLocal2('student self service');
        }
      }
      await sleep(700);
    }
    if (isWd) {
      relay('kiitError', JSON.stringify({ code: 'nav_failed', message: 'The attendance page did not finish loading. Please try again.' }));
    }
  })();
})();
''';

/// One row's attendance counts after any hidden column has been filled in.
class _RowCounts {
  const _RowCounts({
    required this.present,
    required this.absent,
    required this.total,
    required this.percentage,
  });

  final int present;
  final int absent;
  final int total;
  final double percentage;
}
