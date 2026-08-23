import 'package:flutter_test/flutter_test.dart';
import 'package:plan_sync/core/util/attendance_status.dart';
import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/repository/attendance_credentials_repository.dart';
import 'package:plan_sync/features/attendance/repository/attendance_repository.dart';
import 'package:plan_sync/features/attendance/viewmodel/attendance_view_model.dart';

void main() {
  group('AttendanceRecord.fromScrape', () {
    test('coerces string cells from the portal into numbers', () {
      final r = AttendanceRecord.fromScrape({
        'subject': 'Chemistry',
        'absent': '5',
        'present': '25',
        'totalDays': '30',
        'percentage': '83.33',
        'facultyId': '12345',
        'facultyName': 'Dr. X',
        'excuses': '0',
      });

      expect(r.subject, 'Chemistry');
      expect(r.absent, 5);
      expect(r.present, 25);
      expect(r.totalDays, 30);
      expect(r.percentage, closeTo(83.33, 0.001));
    });

    test('tolerates decimal-formatted counts and blanks', () {
      final r = AttendanceRecord.fromScrape({
        'subject': 'English',
        'absent': '25.00',
        'present': '6.00',
        'totalDays': '31.00',
        'percentage': '19.35',
        'facultyId': '',
        'facultyName': '',
        'excuses': '',
      });

      expect(r.absent, 25);
      expect(r.present, 6);
      expect(r.totalDays, 31);
      expect(r.excuses, 0);
    });
  });

  group('AttendanceResult derived totals', () {
    // Deliberately uneven class counts so the mean and the class-weighted
    // formula give different answers (mean=55, weighted=46.67) — the test then
    // actually locks in the averaging behaviour instead of passing by luck.
    final result = AttendanceResult.fromScrape(
      {
        'records': [
          {
            'subject': 'A',
            'absent': '2',
            'present': '8',
            'totalDays': '10',
            'percentage': '80.00',
          },
          {
            'subject': 'B',
            'absent': '14',
            'present': '6',
            'totalDays': '20',
            'percentage': '30.00',
          },
        ],
        'student': {'name': 'Test Student', 'rollNo': '111'},
      },
      academicYear: '2025-2026',
      session: 'Spring',
    );

    test('overall percentage is the mean of subject percentages', () {
      // mean(80, 30) = 55, NOT class-weighted (8 + 6) / (10 + 20) = 46.67.
      expect(result.overallPercentage, closeTo(55.0, 0.001));
      expect(result.totalPresent, 14);
      expect(result.totalClasses, 30);
    });

    test('counts subjects below the 75% threshold', () {
      expect(result.subjectsBelowThreshold, 1);
    });

    test('parses student details', () {
      expect(result.student?.name, 'Test Student');
      expect(result.student?.rollNo, '111');
    });
  });

  group('attendanceLevelFor thresholds', () {
    test('>= 75 is good', () {
      expect(attendanceLevelFor(75), AttendanceLevel.good);
      expect(attendanceLevelFor(92.5), AttendanceLevel.good);
    });
    test('65..<75 is warning', () {
      expect(attendanceLevelFor(74.99), AttendanceLevel.warning);
      expect(attendanceLevelFor(65), AttendanceLevel.warning);
    });
    test('< 65 is critical', () {
      expect(attendanceLevelFor(64.99), AttendanceLevel.critical);
      expect(attendanceLevelFor(0), AttendanceLevel.critical);
    });
  });

  group('AttendanceRecord.canSkip', () {
    test('is 0 when already below 75%', () {
      final r = AttendanceRecord.fromScrape({
        'subject': 'X',
        'absent': '5',
        'present': '5',
        'totalDays': '10',
        'percentage': '50.00',
      });
      expect(r.canSkip, 0);
    });

    test('reports skippable classes when comfortably above threshold', () {
      // 90/100 = 90%. floor(90/0.75)=120 max days -> can miss 20 more.
      final r = AttendanceRecord.fromScrape({
        'subject': 'Y',
        'absent': '10',
        'present': '90',
        'totalDays': '100',
        'percentage': '90.00',
      });
      expect(r.canSkip, 20);
    });

    test('is 0 at exactly 75% (no buffer to skip)', () {
      // 75/100 = 75%. floor(75/0.75)=100 max days -> 100-100 = 0.
      final r = AttendanceRecord.fromScrape({
        'subject': 'Z',
        'absent': '25',
        'present': '75',
        'totalDays': '100',
        'percentage': '75.00',
      });
      expect(r.canSkip, 0);
    });
  });

  group('AttendanceResult edge cases', () {
    AttendanceResult build(List<Map<String, dynamic>> records) =>
        AttendanceResult.fromScrape(
          {'records': records},
          academicYear: '2025-2026',
          session: 'Spring',
        );

    test('empty result: totals are zero and isEmpty is true', () {
      final r = build([]);
      expect(r.isEmpty, isTrue);
      expect(r.totalPresent, 0);
      expect(r.totalClasses, 0);
      expect(r.subjectsBelowThreshold, 0);
    });

    test('overallPercentage is 0 when there are no classes (no divide-by-zero)',
        () {
      expect(build([]).overallPercentage, 0);
    });

    test('a subject at exactly 75% is not counted as below threshold', () {
      final r = build([
        {
          'subject': 'A',
          'absent': '25',
          'present': '75',
          'totalDays': '100',
          'percentage': '75.00',
        },
      ]);
      expect(r.subjectsBelowThreshold, 0);
      expect(r.isEmpty, isFalse);
    });
  });

  group('AttendanceViewModel selection', () {
    test('changeSelection marks dirty; applySelection fetches and clears it',
        () async {
      final vm = AttendanceViewModel(
        credentialsRepository: _FakeCredsRepo('22051234'),
        repository: _FakeAttendanceRepo(),
      );

      // First fetch establishes the applied year/session baseline.
      await vm.refresh();
      expect(vm.status, AttendanceStatus.success);
      expect(vm.selectionDirty, isFalse);

      // Picking a different year marks dirty but must NOT fetch on its own.
      final picked =
          vm.academicYear == '2020-2021' ? '2021-2022' : '2020-2021';
      vm.changeSelection(year: picked);
      expect(vm.selectionDirty, isTrue);
      expect(vm.status, AttendanceStatus.success); // unchanged: no fetch yet

      // Applying fetches and clears the dirty flag.
      await vm.applySelection();
      expect(vm.status, AttendanceStatus.success);
      expect(vm.academicYear, picked);
      expect(vm.selectionDirty, isFalse);
    });
  });
}

/// Returns a canned result without touching the network or cache.
class _FakeAttendanceRepo implements AttendanceRepository {
  @override
  Future<AttendanceResult?> cached({
    required String registrationNumber,
    required String academicYear,
    required String session,
  }) async =>
      null;

  @override
  Duration get freshnessWindow => const Duration(hours: 4);

  @override
  bool isStale(AttendanceResult result) => true;

  @override
  Future<AttendanceResult> fetch({
    required String registrationNumber,
    required String password,
    required String academicYear,
    required String session,
    required void Function(String step) onLog,
  }) async {
    return AttendanceResult(
      records: const [
        AttendanceRecord(
          subject: 'A',
          absent: 0,
          present: 10,
          totalDays: 10,
          percentage: 100,
          facultyId: '',
          facultyName: '',
          excuses: 0,
        ),
      ],
      student: null,
      academicYear: academicYear,
      session: session,
      fetchedAt: DateTime(2026, 1, 1),
    );
  }
}

class _FakeCredsRepo implements AttendanceCredentialsRepository {
  _FakeCredsRepo(this._reg);
  String? _reg;

  @override
  Future<void> initialize() async {}

  @override
  String? get registrationNumber => _reg;

  @override
  bool get hasCredentials => _reg != null;

  @override
  Future<(String, String)?> read() async =>
      _reg == null ? null : (_reg!, 'pass');

  @override
  Future<void> save({
    required String registrationNumber,
    required String password,
  }) async {
    _reg = registrationNumber;
  }

  @override
  Future<void> clear() async {
    _reg = null;
  }
}
