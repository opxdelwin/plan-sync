import 'package:flutter_test/flutter_test.dart';
import 'package:plan_sync/core/services/kiit_attendance_scraper.dart';
import 'package:plan_sync/features/attendance/model/scrape_exception.dart';

/// Column-mapping tests for the attendance grid parser. Mapping is driven only
/// by the header names SAP sends, so these lock in that fields follow their
/// headers wherever the columns sit, and that a missing column is reported
/// instead of guessed around.
void main() {
  List<String> h(String s) => s.split('|');

  const standardHeaders = 'subject|no.of absent|no.of present|'
      'total no. of days|total percentage|faculty id|faculty name|'
      'no. of excuses';

  group('attendance grid parser', () {
    test('standard KIIT layout maps every field', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h(standardHeaders),
        [
          ['Chemistry', '5', '25', '30', '83.33', '12345', 'Dr. X', '2'],
        ],
      );

      expect(recs, hasLength(1));
      final rec = recs.first;
      expect(rec.subject, 'Chemistry');
      expect(rec.facultyName, 'Dr. X');
      expect(rec.facultyId, '12345');
      expect(rec.present, 25);
      expect(rec.absent, 5);
      expect(rec.totalDays, 30);
      expect(rec.percentage, closeTo(83.33, 0.01));
      expect(rec.excuses, 2);
    });

    test('fields follow their headers when the columns are reordered', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('faculty name|subject|no.of present|no.of absent|'
            'total no. of days|total percentage|faculty id|no. of excuses'),
        [
          ['Dr. Smith', 'Physics', '25', '5', '30', '83.33', '54321', '0'],
        ],
      );

      final rec = recs.first;
      expect(rec.subject, 'Physics');
      expect(rec.facultyName, 'Dr. Smith');
      expect(rec.present, 25);
      expect(rec.absent, 5);
    });

    test('decimal-formatted counts decode', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h(standardHeaders),
        [
          ['English', '25.00', '6.00', '31.00', '19.35', '', 'Prof. Y', '0'],
        ],
      );

      final rec = recs.first;
      expect(rec.present, 6);
      expect(rec.absent, 25);
      expect(rec.totalDays, 31);
      expect(rec.percentage, closeTo(19.35, 0.01));
      expect(rec.facultyId, isEmpty);
    });

    test('percentage is derived when that column is hidden', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of absent|no.of present|total no. of days'),
        [
          ['Maths', '5', '15', '20'],
        ],
      );

      expect(recs.first.percentage, closeTo(75.0, 0.01));
    });

    test('optional faculty and excuse columns may be absent', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of absent|no.of present|total no. of days'),
        [
          ['Maths', '5', '15', '20'],
        ],
      );

      final rec = recs.first;
      expect(rec.facultyId, isEmpty);
      expect(rec.facultyName, isEmpty);
      expect(rec.excuses, 0);
    });

    test('rows without a subject are skipped', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h(standardHeaders),
        [
          ['', '5', '25', '30', '83.33', '12345', 'Dr. X', '0'],
          ['Chemistry', '5', '25', '30', '83.33', '12345', 'Dr. X', '0'],
        ],
      );

      expect(recs, hasLength(1));
      expect(recs.first.subject, 'Chemistry');
    });

    test('multiple rows map independently', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h(standardHeaders),
        [
          ['Chemistry', '5', '25', '30', '83.33', '12345', 'Dr. A', '0'],
          ['Physics', '2', '28', '30', '93.33', '67890', 'Dr. B', '1'],
        ],
      );

      expect(recs, hasLength(2));
      expect(recs[0].subject, 'Chemistry');
      expect(recs[0].facultyName, 'Dr. A');
      expect(recs[1].subject, 'Physics');
      expect(recs[1].facultyName, 'Dr. B');
    });
  });

  group('missing required columns', () {
    void expectReported(String headers, String named) {
      expect(
        () => KiitAttendanceScraper.recordsFromGridForTest(
          h(headers),
          [
            ['Chemistry', '5', '25', '30'],
          ],
        ),
        throwsA(
          isA<ScrapeException>()
              .having((e) => e.kind, 'kind', ScrapeErrorKind.columnsChanged)
              .having((e) => e.message, 'message', contains(named)),
        ),
      );
    }

    test('a hidden subject column is reported', () {
      expectReported(
        'no.of absent|no.of present|total no. of days|total percentage',
        'Subject',
      );
    });

    test('a hidden present column is reported', () {
      expectReported(
        'subject|no.of absent|total no. of days|total percentage',
        'No.of Present',
      );
    });

    test('a hidden total-days column is reported', () {
      expectReported(
        'subject|no.of absent|no.of present|total percentage',
        'Total No. of Days',
      );
    });

    test('every missing column is named at once', () {
      expect(
        () => KiitAttendanceScraper.recordsFromGridForTest(
          h('subject|total percentage'),
          [
            ['Chemistry', '83.33'],
          ],
        ),
        throwsA(isA<ScrapeException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('No.of Absent'),
            contains('No.of Present'),
            contains('Total No. of Days'),
          ),
        )),
      );
    });
  });
}
