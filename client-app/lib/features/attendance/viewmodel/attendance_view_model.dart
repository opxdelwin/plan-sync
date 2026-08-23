import 'package:flutter/foundation.dart';
import 'package:plan_sync/core/util/crash_reporter.dart';
import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/model/scrape_exception.dart';
import 'package:plan_sync/features/attendance/repository/attendance_credentials_repository.dart';
import 'package:plan_sync/features/attendance/repository/attendance_repository.dart';

enum AttendanceStatus {
  /// No portal credentials stored yet.
  needsCredentials,

  /// Idle with no result yet (credentials present, not fetched).
  idle,

  /// Reading the saved copy from the cache before deciding whether to scrape.
  restoring,

  /// A scrape is in progress.
  loading,

  /// A result is available.
  success,

  /// The last scrape failed.
  error,
}

class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel({
    required AttendanceCredentialsRepository credentialsRepository,
    required AttendanceRepository repository,
  })  : _credentials = credentialsRepository,
        _repository = repository;

  final AttendanceCredentialsRepository _credentials;
  final AttendanceRepository _repository;

  AttendanceStatus status = AttendanceStatus.needsCredentials;
  AttendanceResult? result;
  ScrapeErrorKind? errorKind;
  String? errorMessage;

  /// True while a background refresh is running (data already exists on screen).
  bool isRefreshing = false;

  /// True when the visible [result] came out of the cache and hasn't been
  /// re-scraped since — the UI says so rather than passing a saved copy off as
  /// live data.
  bool loadedFromCache = false;

  /// How long a cached result stays fresh before it is refreshed.
  Duration get freshnessWindow => _repository.freshnessWindow;

  /// True when the visible [result] has aged past [freshnessWindow].
  bool get resultIsStale =>
      result != null && _repository.isStale(result!);

  /// Failed attempts since the last success. Drives the failure screen's advice
  /// and keeps "Report issue" out of reach until a retry has actually failed —
  /// most first failures clear on their own.
  int consecutiveFailures = 0;

  /// Reporting is offered once the problem has survived a retry.
  bool get canReportIssue => consecutiveFailures >= 2;

  /// Live progress lines from the scrape, newest last. Kept for stage
  /// derivation; not shown in the UI.
  final List<String> logs = [];
  String? currentStep;

  /// Coarse progress stages shown on the loading screen.
  static const List<String> loadingStages = [
    'Signing in',
    'Opening attendance',
    'Reading your attendance',
    'Finishing up',
  ];

  /// Index into [loadingStages] for the current scrape; advances monotonically.
  int loadingStage = 0;

  /// Generic, user-facing message for an unexpected failure (the real error is
  /// reported to Crashlytics separately).
  static const String _genericError =
      'Something went wrong while fetching your attendance. Please try again.';

  List<String> reportDiagnosticsLines() {
    final lines = <String>[
      'Status          : ${status.name}',
      'Is Refreshing   : $isRefreshing',
      'Loading Stage   : $loadingStage',
      'Current Step    : ${currentStep ?? '[none]'}',
      'Error Kind      : ${errorKind?.name ?? '[none]'}',
      'Error Message   : ${errorMessage ?? '[none]'}',
      'Selection Dirty : $selectionDirty',
      'Picked Year     : $academicYear',
      'Picked Session  : $session',
      'Applied Year    : ${_appliedYear ?? '[not loaded]'}',
      'Applied Session : ${_appliedSession ?? '[not loaded]'}',
    ];

    if (logs.isNotEmpty) {
      lines.add('Recent Logs:');
      final startIndex = logs.length > 8 ? logs.length - 8 : 0;
      for (final log in logs.sublist(startIndex)) {
        lines.add('- $log');
      }
    }

    return lines;
  }

  // Currently *picked* year/session (what the dropdowns show).
  late String academicYear = currentAcademicYear();
  late String session = currentSession();

  // The year/session the loaded [result] actually reflects.
  String? _appliedYear;
  String? _appliedSession;

  /// True when the picked year/session differ from what [result] shows — i.e.
  /// the user changed a dropdown but hasn't applied it yet.
  bool get selectionDirty =>
      academicYear != _appliedYear || session != _appliedSession;

  /// Reads credentials from storage and pre-populates [result] from Hive so the
  /// Attendance tab renders cached data immediately without any loading screen.
  /// Call once at app startup (from [AppInitializer]).
  Future<void> initialize() async {
    await _credentials.initialize();

    if (!_credentials.hasCredentials) {
      status = AttendanceStatus.needsCredentials;
      notifyListeners();
      return;
    }

    // Pre-load from cache so result is non-null before the tab first renders.
    final creds = await _credentials.read();
    if (creds != null) {
      final cached = await _repository.cached(
        registrationNumber: creds.$1,
        academicYear: academicYear,
        session: session,
      );
      if (cached != null) {
        result = cached;
        loadedFromCache = true;
        _appliedYear = cached.academicYear;
        _appliedSession = cached.session;
      }
    }

    status = result != null ? AttendanceStatus.success : AttendanceStatus.idle;
    notifyListeners();
  }

  bool get hasCredentials => _credentials.hasCredentials;
  String? get registrationNumber => _credentials.registrationNumber;

  // --- year / session options -----------------------------------------------

  /// KIIT academic year for "now": Autumn (Jul–Dec) belongs to YYYY-(YYYY+1),
  /// Spring (Jan–Jun) belongs to (YYYY-1)-YYYY.
  static String currentAcademicYear() {
    final now = DateTime.now();
    final start = now.month >= 7 ? now.year : now.year - 1;
    return '$start-${start + 1}';
  }

  static String currentSession() =>
      DateTime.now().month >= 7 ? 'Autumn' : 'Spring';

  List<String> get yearOptions {
    final start = int.parse(currentAcademicYear().split('-').first);
    return List.generate(7, (i) {
      final y = start + 1 - i; // a year ahead down to ~5 years back
      return '$y-${y + 1}';
    });
  }

  List<String> get sessionOptions => const ['Autumn', 'Spring'];

  /// Start instant of an academic period. For year "Y-(Y+1)": Autumn begins
  /// Jul Y, Spring begins Jan (Y+1).
  static DateTime _periodStart(String academicYear, String session) {
    final startYear = int.tryParse(academicYear.split('-').first) ?? 0;
    return session == 'Spring'
        ? DateTime(startYear + 1, 1)
        : DateTime(startYear, 7);
  }

  /// Whether a period has already begun. Past/current → true; a future
  /// year/session (e.g. picking 2027-2028 today) → false, so the UI can say the
  /// session hasn't started yet instead of scraping for data that can't exist.
  static bool periodHasStarted(String academicYear, String session) =>
      !_periodStart(academicYear, session).isAfter(DateTime.now());

  // --- progress -------------------------------------------------------------

  void pushLog(String step) {
    currentStep = step;
    logs.add(step);
    final s = _stageFor(step);
    if (s > loadingStage) loadingStage = s;
    notifyListeners();
  }

  /// Maps a raw scrape log line to a coarse [loadingStages] index.
  static int _stageFor(String message) {
    final t = message.toLowerCase();
    if (t.contains('got ') || t.contains('received attendance')) return 3;
    if (t.contains('reading the attendance') ||
        t.contains('setting filters') ||
        t.contains('iview loaded') ||
        t.contains('attendance form ready') ||
        t.contains('submit') ||
        t.contains('selected ')) {
      return 2;
    }
    if (t.contains('logged in') ||
        t.contains('navigat') ||
        t.contains('self service') ||
        t.contains('attendance details') ||
        t.contains('agent injected') ||
        t.contains('webdynpro')) {
      return 1;
    }
    return 0;
  }

  void _recordError(Object error, StackTrace stack, String reason) {
    CrashReporter.recordError(error, stack, reason: reason);
  }

  // --- actions --------------------------------------------------------------

  /// Called each time the Attendance tab is opened.
  ///
  /// If [result] is already populated (from cache or a prior scrape):
  ///   - fresh data  → no-op, keep showing it
  ///   - stale data  → silent background refresh ([isRefreshing] = true),
  ///                   the existing result stays visible
  /// If there is no [result] yet (first-ever use), a full scrape is started
  /// and the loading screen is shown.
  Future<void> ensureLoaded() async {
    if (!hasCredentials) {
      _set(AttendanceStatus.needsCredentials);
      return;
    }
    if (status == AttendanceStatus.loading || isRefreshing) return;

    if (result != null) {
      // Data is already on screen. Silently refresh only when stale.
      if (_repository.isStale(result!)) {
        await refresh(); // refresh() sees result != null → uses isRefreshing
      }
      return;
    }

    // No data yet (first-ever use) — do NOT auto-scrape. Land on the idle
    // period picker so the user chooses the year/session, then fetches.
    _set(AttendanceStatus.idle);
  }

  Future<void> refresh() async {
    if (status == AttendanceStatus.loading || isRefreshing) return;

    final creds = await _credentials.read();
    if (creds == null) {
      _set(AttendanceStatus.needsCredentials);
      return;
    }

    logs.clear();
    loadingStage = 0;
    currentStep = 'Starting…';
    errorKind = null;
    errorMessage = null;

    // Refresh silently only when the data is genuinely on screen. Retrying from
    // the error screen must show progress instead — a silent refresh there left
    // the failure screen up untouched for the whole scrape, so "Try again" read
    // as a dead button.
    final hasData = result != null && status == AttendanceStatus.success;
    if (hasData) {
      isRefreshing = true;
      notifyListeners();
    } else {
      _set(AttendanceStatus.loading);
    }

    try {
      final fetched = await _repository.fetch(
        registrationNumber: creds.$1,
        password: creds.$2,
        academicYear: academicYear,
        session: session,
        onLog: pushLog,
      );
      result = fetched;
      loadedFromCache = false; // live data now
      _appliedYear = academicYear;
      _appliedSession = session;
      consecutiveFailures = 0;

      isRefreshing = false;
      _set(AttendanceStatus.success);
    } on ScrapeException catch (e, st) {
      // Bad credentials are no longer useful — clear them so the user is
      // prompted to reconnect (and told why) rather than silently failing.
      if (e.kind == ScrapeErrorKind.invalidCredentials) {
        await _credentials.clear();
      }
      errorKind = e.kind;
      // Classified failures carry a friendly message; an unclassified one gets
      // a generic message for the user and the real error goes to Crashlytics.
      if (e.kind == ScrapeErrorKind.unknown) {
        errorMessage = _genericError;
        _recordError(e, st, 'attendance scrape failed');
      } else {
        errorMessage = e.message;
      }
      isRefreshing = false;
      // Bad credentials aren't a failure the user can retry their way out of.
      if (e.kind != ScrapeErrorKind.invalidCredentials) consecutiveFailures++;
      _set(e.kind == ScrapeErrorKind.invalidCredentials
          ? AttendanceStatus.needsCredentials
          : AttendanceStatus.error);
    } catch (e, st) {
      errorKind = ScrapeErrorKind.unknown;
      errorMessage = _genericError;
      _recordError(e, st, 'attendance fetch failed');
      isRefreshing = false;
      consecutiveFailures++;
      _set(AttendanceStatus.error);
    }
  }

  /// Update the picked year/session WITHOUT fetching. The user applies the
  /// choice explicitly (see [applySelection]) so a single dropdown tap doesn't
  /// kick off a whole scrape mid-selection.
  void changeSelection({String? year, String? session}) {
    academicYear = year ?? academicYear;
    this.session = session ?? this.session;
    notifyListeners();
  }

  /// Load the currently-picked year/session, checking cache first before
  /// falling back to a full scrape. Stale cache is shown immediately while a
  /// background refresh runs.
  ///
  /// Always loads, even when the picked period matches the last applied one:
  /// this only runs from an explicit tap ("Load attendance" / the period
  /// dialog's Apply), and skipping the work there is what made those buttons
  /// look broken. Passive entry into the tab goes through [ensureLoaded].
  Future<void> applySelection() async {
    // Reading Hive is quick, but the user tapped a button — show that their
    // saved copy is being checked instead of leaving the tap unacknowledged.
    if (result == null) _set(AttendanceStatus.restoring);

    final creds = await _credentials.read();
    if (creds != null && await _restoreFromCache(creds.$1)) {
      if (!_repository.isStale(result!)) {
        return; // Fresh — no scrape needed.
      }
      // Stale — fall through; refresh() will use isRefreshing (data is visible).
    }

    await refresh();
  }

  /// Loads the saved copy for the picked period onto the screen, if there is
  /// one. Returns whether anything was restored.
  Future<bool> _restoreFromCache(String registrationNumber) async {
    final cached = await _repository.cached(
      registrationNumber: registrationNumber,
      academicYear: academicYear,
      session: session,
    );
    if (cached == null) return false;
    result = cached;
    loadedFromCache = true;
    _appliedYear = academicYear;
    _appliedSession = session;
    _set(AttendanceStatus.success);
    return true;
  }

  /// Save new credentials. Does NOT fetch — the user lands on the idle period
  /// picker and triggers the scrape after choosing a year/session.
  Future<void> connect({
    required String registrationNumber,
    required String password,
  }) async {
    await _credentials.save(
      registrationNumber: registrationNumber,
      password: password,
    );
    // Clear any prior "incorrect password" notice from a failed attempt.
    errorKind = null;
    errorMessage = null;
    // A saved copy from before the log-out is still on the device, so land on it
    // exactly as a cold app start would — otherwise logging back in dumps the
    // user on an empty picker while their attendance sits in the cache.
    if (await _restoreFromCache(registrationNumber)) return;
    _set(AttendanceStatus.idle);
  }

  /// Return to the period picker (idle) without logging out, so a user who hit
  /// "No attendance found" can pick a different year/session instead of
  /// re-entering their portal credentials.
  void chooseAnotherPeriod() {
    errorKind = null;
    errorMessage = null;
    _set(AttendanceStatus.idle);
  }

  Future<void> disconnect() async {
    await _credentials.clear();
    result = null;
    loadedFromCache = false;
    errorKind = null;
    errorMessage = null;
    // The applied period must go with the result, or the next log-in sees a
    // clean picker whose selection already looks "applied" and refuses to load.
    _appliedYear = null;
    _appliedSession = null;
    _set(AttendanceStatus.needsCredentials);
  }

  void _set(AttendanceStatus newStatus) {
    status = newStatus;
    notifyListeners();
  }
}
