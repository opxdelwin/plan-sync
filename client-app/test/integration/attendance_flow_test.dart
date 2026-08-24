import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_sync/core/services/kiit_attendance_scraper.dart';
import 'package:plan_sync/core/services/theme_service.dart';
import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/model/scrape_exception.dart';
import 'package:plan_sync/features/attendance/repository/attendance_credentials_repository.dart';
import 'package:plan_sync/features/attendance/view/attendance_screen.dart';
import 'package:plan_sync/features/attendance/repository/attendance_repository_impl.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';
import 'package:provider/provider.dart';

import '../helpers/fake_cache_service.dart';

class _FakeCredentials implements AttendanceCredentialsRepository {
  _FakeCredentials({bool hasCredentials = false, String? registrationNumber})
      : _has = hasCredentials,
        _reg = registrationNumber;

  bool _has;
  String? _reg;

  @override
  Future<void> initialize() async {}
  @override
  bool get hasCredentials => _has;
  @override
  String? get registrationNumber => _reg;
  @override
  Future<(String, String)?> read() async =>
      _has ? (_reg ?? '22001234', 'pw') : null;
  @override
  Future<void> save({
    required String registrationNumber,
    required String password,
  }) async {
    _has = true;
    _reg = registrationNumber;
  }

  @override
  Future<void> clear() async {
    _has = false;
    _reg = null;
  }
}

/// Stand-in for [KiitAttendanceScraper] that never touches a WebView.
class _FakeScraper extends KiitAttendanceScraper {
  _FakeScraper({
    this.result,
    this.error,
    this.logs = const [],
    this.delay = Duration.zero,
  });

  final AttendanceResult? result;
  final Object? error;
  final List<String> logs;
  final Duration delay;

  @override
  Future<AttendanceResult> scrape({
    required String username,
    required String password,
    required String academicYear,
    required String session,
    void Function(String message)? onLog,
  }) async {
    for (final l in logs) {
      onLog?.call(l);
    }
    if (delay > Duration.zero) await Future.delayed(delay);
    if (error != null) throw error!;
    return result!;
  }
}

AttendanceResult _result({String subject = 'Mathematics'}) => AttendanceResult(
      records: [
        AttendanceRecord(
          subject: subject,
          absent: 4,
          present: 26,
          totalDays: 30,
          percentage: 86.6,
          facultyId: 'F01',
          facultyName: 'Dr. Smith',
          excuses: 0,
        ),
      ],
      student: null,
      academicYear: '2024-2025',
      session: 'Autumn',
      fetchedAt: DateTime(2024, 1, 1),
    );

void main() {
  Future<void> pumpAttendance(
    WidgetTester tester, {
    required AttendanceCredentialsRepository creds,
    KiitAttendanceScraper Function()? scraperFactory,
  }) async {
    final vm = AttendanceViewModel(
      credentialsRepository: creds,
      repository: AttendanceRepositoryImpl(
        cache: FakeCacheService(),
        scraperFactory: scraperFactory,
      ),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
          ChangeNotifierProvider<AttendanceViewModel>.value(value: vm),
        ],
        child: MaterialApp(
          theme: ThemeService.lightTheme,
          home: const AttendanceScreen(),
        ),
      ),
    );
  }

  testWidgets('no credentials shows the connect prompt', (tester) async {
    await pumpAttendance(tester, creds: _FakeCredentials());
    await tester.pumpAndSettle();

    expect(find.text('Track your attendance'), findsOneWidget);
    expect(find.text('Connect KIIT Portal'), findsOneWidget);
    // No ID chip in the appbar when not connected.
    expect(find.textContaining('ID ·'), findsNothing);
  });

  testWidgets('successful scrape renders the attendance records',
      (tester) async {
    await pumpAttendance(
      tester,
      creds: _FakeCredentials(hasCredentials: true, registrationNumber: '2205'),
      scraperFactory: () => _FakeScraper(result: _result()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load attendance'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('portal error shows the error state with retry', (tester) async {
    await pumpAttendance(
      tester,
      creds: _FakeCredentials(hasCredentials: true, registrationNumber: '2205'),
      scraperFactory: () => _FakeScraper(
        error: const ScrapeException(
          ScrapeErrorKind.portalUnavailable,
          'The KIIT portal is down.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load attendance'));
    await tester.pumpAndSettle();

    // The failure screen explains the specific kind of failure, suggests what
    // to try (ending in a restart), and offers a retry — rather than surfacing
    // one generic line.
    expect(find.text('Portal is down'), findsOneWidget);
    expect(find.textContaining('isn\'t serving pages'), findsOneWidget);
    expect(find.textContaining('Close Plan Sync completely'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

    // Reporting is not one tap away on a first failure.
    expect(find.text('Report issue'), findsNothing);
    expect(find.text('Tried everything?'), findsNothing);

    // A second failure reveals the disclosure — beside the retry button, not in
    // a block below it where the nav bar covers it.
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    final disclosure = find.text('Tried everything?');
    expect(disclosure, findsOneWidget);
    expect(find.text('Report issue'), findsNothing); // still two taps away
    expect(
      tester.getCenter(disclosure).dy,
      closeTo(tester.getCenter(find.text('Try again')).dy, 24),
      reason: 'the disclosure shares the retry row',
    );

    await tester.tap(disclosure);
    await tester.pumpAndSettle();
    expect(find.text('Report issue'), findsOneWidget);
  });

  testWidgets('a changed column layout tells the user how to restore it',
      (tester) async {
    await pumpAttendance(
      tester,
      creds: _FakeCredentials(hasCredentials: true, registrationNumber: '2205'),
      scraperFactory: () => _FakeScraper(
        error: const ScrapeException(
          ScrapeErrorKind.columnsChanged,
          'Your attendance table on the portal has no subject column.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load attendance'));
    await tester.pumpAndSettle();

    expect(find.text('Attendance table changed'), findsOneWidget);
    expect(find.textContaining('no subject column'), findsOneWidget);
    expect(find.textContaining('unhide the'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('invalid credentials clears creds and returns to connect prompt',
      (tester) async {
    await pumpAttendance(
      tester,
      creds: _FakeCredentials(hasCredentials: true, registrationNumber: '2205'),
      scraperFactory: () => _FakeScraper(
        error: const ScrapeException(
          ScrapeErrorKind.invalidCredentials,
          'Wrong password.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load attendance'));
    await tester.pumpAndSettle();

    // invalidCredentials -> creds cleared -> needsCredentials, not error state.
    expect(find.text('Track your attendance'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('shows loading state with progress while scraping',
      (tester) async {
    await pumpAttendance(
      tester,
      creds: _FakeCredentials(hasCredentials: true, registrationNumber: '2205'),
      scraperFactory: () => _FakeScraper(
        result: _result(),
        logs: const ['Opening the KIIT portal…'],
        delay: const Duration(milliseconds: 500),
      ),
    );
    await tester.pump(); // post-frame ensureLoaded -> refresh
    await tester.tap(find.text('Load attendance'));
    await tester.pump(); // loading frame

    expect(find.text('Signing in'), findsOneWidget);
    expect(find.text('This can take up to a minute on the KIIT portal.'),
        findsOneWidget);

    await tester.pumpAndSettle(); // resolve the delayed scrape
    expect(find.text('Mathematics'), findsOneWidget);
  });

  testWidgets('logging out of the portal returns to the connect prompt',
      (tester) async {
    await pumpAttendance(
      tester,
      creds: _FakeCredentials(hasCredentials: true, registrationNumber: '2205'),
      scraperFactory: () => _FakeScraper(result: _result()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load attendance'));
    await tester.pumpAndSettle();
    expect(find.byType(RefreshIndicator), findsOneWidget);

    // Appbar logout -> confirmation dialog -> Log out -> disconnect.
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Log out of KIIT portal?'), findsOneWidget);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Track your attendance'), findsOneWidget);
  });
}
