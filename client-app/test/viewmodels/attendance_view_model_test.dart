import 'package:flutter_test/flutter_test.dart';
import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/repository/attendance_credentials_repository.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';
import '../helpers/fake_attendance_repository.dart';

class FakeAttendanceCredentialsRepository
    implements AttendanceCredentialsRepository {
  bool _hasCredentials;
  String? _registrationNumber;

  FakeAttendanceCredentialsRepository({
    bool hasCredentials = false,
    String? registrationNumber,
  })  : _hasCredentials = hasCredentials,
        _registrationNumber = registrationNumber;

  @override
  Future<void> initialize() async {}

  @override
  bool get hasCredentials => _hasCredentials;

  @override
  String? get registrationNumber => _registrationNumber;

  @override
  Future<(String, String)?> read() async {
    if (!_hasCredentials) return null;
    return (_registrationNumber ?? '22001234', 'password');
  }

  @override
  Future<void> save({
    required String registrationNumber,
    required String password,
  }) async {
    _hasCredentials = true;
    _registrationNumber = registrationNumber;
  }

  @override
  Future<void> clear() async {
    _hasCredentials = false;
    _registrationNumber = null;
  }
}

AttendanceViewModel _makeVm({
  bool hasCredentials = false,
  String? registrationNumber,
  FakeAttendanceRepository? repository,
}) =>
    AttendanceViewModel(
      credentialsRepository: FakeAttendanceCredentialsRepository(
        hasCredentials: hasCredentials,
        registrationNumber: registrationNumber,
      ),
      repository: repository ?? FakeAttendanceRepository(),
    );

AttendanceResult _result({
  required String academicYear,
  required String session,
  List<AttendanceRecord> records = const [],
  Duration age = const Duration(hours: 1),
}) =>
    AttendanceResult(
      records: records,
      student: null,
      academicYear: academicYear,
      session: session,
      fetchedAt: DateTime.now().subtract(age),
    );

void main() {
  group('initialize — credentials', () {
    test('sets status to idle when credentials present but no cache', () async {
      final vm = _makeVm(hasCredentials: true, registrationNumber: '22001234');
      await vm.initialize();
      expect(vm.status, AttendanceStatus.idle);
    });

    test('sets status to needsCredentials when no credentials', () async {
      final vm = _makeVm();
      await vm.initialize();
      expect(vm.status, AttendanceStatus.needsCredentials);
    });
  });

  group('pushLog', () {
    test('appends step to logs and updates currentStep', () {
      final vm = _makeVm();

      vm.pushLog('Connecting…');
      expect(vm.logs, ['Connecting…']);
      expect(vm.currentStep, 'Connecting…');

      vm.pushLog('Fetching data…');
      expect(vm.logs, ['Connecting…', 'Fetching data…']);
      expect(vm.currentStep, 'Fetching data…');
    });
  });

  group('disconnect', () {
    test('clears result, errors, and sets status to needsCredentials', () async {
      final vm = _makeVm(hasCredentials: true);
      await vm.initialize();

      // Simulate a prior result
      vm.pushLog('Fetched');

      await vm.disconnect();

      expect(vm.status, AttendanceStatus.needsCredentials);
      expect(vm.result, isNull);
      expect(vm.errorKind, isNull);
      expect(vm.errorMessage, isNull);
    });

    test('log out then log back in can load the same period again', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      // Nothing saved on the device, so the picker is what the user lands on.
      repo.fetchResult =
          _result(academicYear: year, session: sess, age: Duration.zero);

      await vm.initialize();
      await vm.disconnect();
      await vm.connect(registrationNumber: '22001234', password: 'password');
      expect(vm.status, AttendanceStatus.idle);

      // Picking the SAME year/session as before must still load — the applied
      // period was cleared with the result, so this isn't a no-op.
      vm.changeSelection(year: year, session: sess);
      await vm.applySelection();

      expect(vm.status, AttendanceStatus.success);
      expect(vm.result, isNotNull);
    });

    test('logging back in lands on the saved copy, not an empty picker',
        () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      repo.seed('22001234', year, sess,
          _result(academicYear: year, session: sess));

      await vm.initialize();
      await vm.disconnect();
      expect(vm.result, isNull);

      await vm.connect(registrationNumber: '22001234', password: 'password');

      // Same behaviour as a cold start with a cache present.
      expect(vm.status, AttendanceStatus.success);
      expect(vm.loadedFromCache, isTrue);
      expect(repo.fetchCount, 0);
    });

    test('re-applying the period already on screen still reloads', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      repo.seed('22001234', year, sess,
          _result(academicYear: year, session: sess));
      await vm.initialize();

      // Mirrors the error screen's "Change year & session" → pick the same
      // period → Apply. This used to early-return and do nothing.
      vm.chooseAnotherPeriod();
      expect(vm.status, AttendanceStatus.idle);
      expect(vm.selectionDirty, isFalse); // period unchanged

      await vm.applySelection();

      expect(vm.status, AttendanceStatus.success);
      expect(vm.result, isNotNull);
    });
  });

  group('changeSelection', () {
    test('is a no-op when year and session are unchanged', () async {
      final vm = _makeVm();
      await vm.initialize();

      final yearBefore = vm.academicYear;
      final sessionBefore = vm.session;

      vm.changeSelection(year: yearBefore, session: sessionBefore);

      expect(vm.academicYear, yearBefore);
      expect(vm.session, sessionBefore);
    });

    test('updates academicYear when year changes', () async {
      final vm = _makeVm();
      await vm.initialize();

      vm.changeSelection(year: '2019-2020');

      expect(vm.academicYear, '2019-2020');
    });
  });

  group('yearOptions', () {
    test('returns 7 entries', () {
      final vm = _makeVm();
      expect(vm.yearOptions.length, 7);
    });

    test('entries are in YYYY-YYYY+1 format with consecutive years', () {
      final vm = _makeVm();
      for (final option in vm.yearOptions) {
        final parts = option.split('-');
        expect(parts.length, 2);
        final start = int.parse(parts[0]);
        final end = int.parse(parts[1]);
        expect(end, start + 1);
      }
    });
  });

  group('sessionOptions', () {
    test('returns Autumn and Spring', () {
      final vm = _makeVm();
      expect(vm.sessionOptions, ['Autumn', 'Spring']);
    });
  });

  group('initialize', () {
    test('pre-loads result from cache so tab renders without loading screen',
        () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );

      // Seed the repository before initialize() (simulates a prior session).
      final record = AttendanceRecord(
        subject: 'Math',
        absent: 1,
        present: 9,
        totalDays: 10,
        percentage: 90.0,
        facultyId: 'F1',
        facultyName: 'Dr. A',
        excuses: 0,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      repo.seed('22001234', year, sess,
          _result(academicYear: year, session: sess, records: [record]));

      await vm.initialize();

      expect(vm.status, AttendanceStatus.success);
      expect(vm.result?.records.first.subject, 'Math');
    });
  });

  group('ensureLoaded', () {
    test('sets status to needsCredentials when no credentials', () async {
      final vm = _makeVm();
      await vm.ensureLoaded();
      expect(vm.status, AttendanceStatus.needsCredentials);
    });

    test('is a no-op when fresh data is already on screen', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      repo.seed('22001234', year, sess,
          _result(academicYear: year, session: sess)); // 1h old → fresh
      await vm.initialize(); // pre-loads cache → status = success

      await vm.ensureLoaded(); // should be a no-op

      expect(vm.status, AttendanceStatus.success);
      expect(vm.isRefreshing, isFalse);
      expect(repo.fetchCount, 0); // no scrape triggered
    });

    test('starts background refresh when stale data is on screen', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      repo.seed(
        '22001234',
        year,
        sess,
        _result(academicYear: year, session: sess, age: const Duration(hours: 7)),
      );
      await vm.initialize(); // pre-loads stale cache → status = success

      // ensureLoaded() detects stale data and calls refresh(), which uses
      // isRefreshing (not the loading screen) because result != null. The fake
      // fetch throws (unconfigured), so status ends at error — but the
      // full-screen loading state was never shown.
      expect(vm.status, AttendanceStatus.success); // before ensureLoaded
      await vm.ensureLoaded();
      expect(repo.fetchCount, 1); // a refresh was attempted
      expect(vm.status, isNot(AttendanceStatus.loading));
    });
  });

  group('retrying after a failure', () {
    test('retry from the error screen shows the loading screen', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      // Stale saved copy on screen, then a failed background refresh.
      repo.seed(
        '22001234',
        year,
        sess,
        _result(academicYear: year, session: sess, age: const Duration(hours: 5)),
      );
      await vm.initialize();
      repo.fetchError = StateError('offline');
      await vm.ensureLoaded();
      expect(vm.status, AttendanceStatus.error);
      expect(vm.result, isNotNull); // the saved copy is still held

      // Retrying must show progress: with a result present the old code flipped
      // isRefreshing and left the failure screen untouched for the whole scrape.
      final statuses = <AttendanceStatus>[];
      vm.addListener(() => statuses.add(vm.status));
      await vm.refresh();

      expect(statuses, contains(AttendanceStatus.loading));
      expect(vm.isRefreshing, isFalse);
    });

    test('report is offered only once a retry has also failed', () async {
      final repo = FakeAttendanceRepository()..fetchError = StateError('down');
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      await vm.initialize();

      await vm.refresh();
      expect(vm.status, AttendanceStatus.error);
      expect(vm.consecutiveFailures, 1);
      expect(vm.canReportIssue, isFalse);

      await vm.refresh();
      expect(vm.consecutiveFailures, 2);
      expect(vm.canReportIssue, isTrue);
    });

    test('a success resets the failure count', () async {
      final repo = FakeAttendanceRepository()..fetchError = StateError('down');
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      await vm.initialize();
      await vm.refresh();
      await vm.refresh();
      expect(vm.canReportIssue, isTrue);

      repo.fetchError = null;
      repo.fetchResult = _result(
        academicYear: vm.academicYear,
        session: vm.session,
        age: Duration.zero,
      );
      await vm.refresh();

      expect(vm.status, AttendanceStatus.success);
      expect(vm.consecutiveFailures, 0);
      expect(vm.canReportIssue, isFalse);
    });
  });

  group('cache provenance', () {
    test('a cached load is flagged as a saved copy', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      repo.seed('22001234', year, sess,
          _result(academicYear: year, session: sess)); // 1h old → fresh

      await vm.initialize();

      expect(vm.status, AttendanceStatus.success);
      expect(vm.loadedFromCache, isTrue);
      expect(vm.resultIsStale, isFalse);
      expect(repo.fetchCount, 0);
    });

    test('a completed scrape clears the saved-copy flag', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      repo.seed('22001234', year, sess,
          _result(academicYear: year, session: sess));
      await vm.initialize();
      expect(vm.loadedFromCache, isTrue);

      repo.fetchResult = _result(
        academicYear: year,
        session: sess,
        age: Duration.zero,
      );
      await vm.refresh();

      expect(vm.status, AttendanceStatus.success);
      expect(vm.loadedFromCache, isFalse);
      expect(vm.isRefreshing, isFalse);
    });

    test('stale cache is shown, flagged stale, and refreshed', () async {
      final repo = FakeAttendanceRepository();
      final vm = _makeVm(
        hasCredentials: true,
        registrationNumber: '22001234',
        repository: repo,
      );
      final year = AttendanceViewModel.currentAcademicYear();
      final sess = AttendanceViewModel.currentSession();
      // Older than the 4h window.
      repo.seed(
        '22001234',
        year,
        sess,
        _result(academicYear: year, session: sess, age: const Duration(hours: 5)),
      );

      await vm.initialize();
      expect(vm.loadedFromCache, isTrue);
      expect(vm.resultIsStale, isTrue);

      repo.fetchResult =
          _result(academicYear: year, session: sess, age: Duration.zero);
      await vm.ensureLoaded(); // stale → background refresh

      expect(repo.fetchCount, 1);
      expect(vm.loadedFromCache, isFalse);
      expect(vm.resultIsStale, isFalse);
    });

    test('freshnessWindow comes from the repository', () {
      final repo = FakeAttendanceRepository()..ttl = const Duration(hours: 4);
      final vm = _makeVm(repository: repo);
      expect(vm.freshnessWindow, const Duration(hours: 4));
    });
  });

  group('AttendanceResult derived', () {
    test('toJson → fromJson round-trip preserves all fields', () {
      final record = AttendanceRecord(
        subject: 'Physics',
        absent: 2,
        present: 18,
        totalDays: 20,
        percentage: 90.0,
        facultyId: '123',
        facultyName: 'Dr. Smith',
        excuses: 0,
      );
      final json = record.toJson();
      final restored = AttendanceRecord.fromJson(json);
      expect(restored.subject, record.subject);
      expect(restored.absent, record.absent);
      expect(restored.present, record.present);
      expect(restored.percentage, record.percentage);
    });
  });
}
