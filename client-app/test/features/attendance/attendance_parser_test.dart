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

  // The agent keeps blank headers and every cell, so header position lines up
  // with cell position. These lock that contract in: dropping the blank
  // selection header while keeping its cell is what silently shifted every
  // value one column left.
  group('alignment with the raw payload', () {
    test('a blank leading header keeps its column aligned', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('|$standardHeaders'),
        [
          ['', 'Chemistry', '5', '25', '30', '83.33', '12345', 'Dr. X', '2'],
        ],
      );

      final rec = recs.first;
      expect(rec.subject, 'Chemistry');
      expect(rec.absent, 5);
      expect(rec.present, 25);
      expect(rec.totalDays, 30);
      expect(rec.percentage, closeTo(83.33, 0.01));
      expect(rec.facultyId, '12345');
      expect(rec.facultyName, 'Dr. X');
      expect(rec.excuses, 2);
    });

    test('a blank header between data columns keeps the rest aligned', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject||no.of absent|no.of present|total no. of days|'
            'total percentage'),
        [
          ['Physics', '', '2', '28', '30', '93.33'],
        ],
      );

      final rec = recs.first;
      expect(rec.subject, 'Physics');
      expect(rec.absent, 2);
      expect(rec.present, 28);
      expect(rec.totalDays, 30);
    });

    test('a row shifted out of line is dropped, not mapped to nonsense', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h(standardHeaders),
        [
          // Leading cell present but no matching header: everything shifts and
          // the subject column lands on a number.
          ['', 'Chemistry', '5', '25', '30', '83.33', '12345', 'Dr. X'],
          ['Physics', '2', '28', '30', '93.33', '67890', 'Dr. B', '1'],
        ],
      );

      expect(recs, hasLength(1));
      expect(recs.first.subject, 'Physics');
      expect(recs.first.present, 28);
    });

    test('a row too short for its headers is dropped', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h(standardHeaders),
        [
          ['Chemistry', '5'],
          ['Physics', '2', '28', '30', '93.33', '67890', 'Dr. B', '1'],
        ],
      );

      expect(recs, hasLength(1));
      expect(recs.first.subject, 'Physics');
    });

    test('reports a layout problem when every row is misaligned', () {
      expect(
        () => KiitAttendanceScraper.recordsFromGridForTest(
          h(standardHeaders),
          [
            ['', 'Chemistry', '5', '25', '30', '83.33', '12345', 'Dr. X'],
          ],
        ),
        throwsA(isA<ScrapeException>()
            .having((e) => e.kind, 'kind', ScrapeErrorKind.columnsChanged)),
      );
    });
  });

  // The real KIIT table, verbatim: a leading selection column that has a
  // header but emits no cell, Present before Absent, and the faculty id column
  // mislabelled "Faculty Name" so the name regex matches twice.
  group('the live KIIT layout', () {
    // Verbatim from a device run, including the selection column's own header.
    const liveHeaders =
        'column for row selection|subject|no.of present|no.of absent|'
        'no. of excuses|total no. of days|total percentage|faculty name|'
        'faculty name';

    List<List<String>> liveRows() => [
          [
            'Scientific and Technical Writing',
            '1.00',
            '9.00',
            '0.00',
            '10.00',
            '10.00',
            '00105704',
            'Asit Behera',
          ],
          [
            'Data Structures',
            '2.00',
            '19.00',
            '0.00',
            '21.00',
            '9.52',
            '00104432',
            'Debashis Hati',
          ],
          ['', '', '', '', '', '', '', ''],
        ];

    test('rows shorter than the header row still map correctly', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        liveHeaders.split('|'),
        liveRows(),
      );

      expect(recs, hasLength(2));
      final first = recs.first;
      expect(first.subject, 'Scientific and Technical Writing');
      expect(first.present, 1);
      expect(first.absent, 9);
      expect(first.totalDays, 10);
      expect(first.percentage, closeTo(10.0, 0.01));
      expect(first.excuses, 0);
      expect(recs[1].subject, 'Data Structures');
      expect(recs[1].present, 2);
      expect(recs[1].totalDays, 21);
      expect(recs[1].percentage, closeTo(9.52, 0.01));
    });

    test('an unrecognised extra header is reconciled by width', () {
      // Even if the portal renames the selection column to something we don't
      // know, the data rows still map — the header row is trimmed to the rows.
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        'some new control column|subject|no.of present|no.of absent|'
                'no. of excuses|total no. of days|total percentage|'
                'faculty name|faculty name'
            .split('|'),
        liveRows(),
      );

      expect(recs, hasLength(2));
      expect(recs.first.subject, 'Scientific and Technical Writing');
      expect(recs.first.present, 1);
      expect(recs.first.absent, 9);
      expect(recs.first.totalDays, 10);
      expect(recs.first.facultyName, 'Asit Behera');
    });

    test('a duplicated Faculty Name header splits into id and name', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        liveHeaders.split('|'),
        liveRows(),
      );

      expect(recs.first.facultyId, '00105704');
      expect(recs.first.facultyName, 'Asit Behera');
    });

    test('the same layout with the selection cell emitted also maps', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        liveHeaders.split('|'),
        [
          [
            '',
            'Digital Systems Design',
            '7.00',
            '9.00',
            '0.00',
            '16.00',
            '43.75',
            '00103185',
            'Deep Mukherjee',
          ],
        ],
      );

      final rec = recs.first;
      expect(rec.subject, 'Digital Systems Design');
      expect(rec.present, 7);
      expect(rec.absent, 9);
      expect(rec.totalDays, 16);
      expect(rec.facultyName, 'Deep Mukherjee');
    });
  });

  // A user who hid columns on the portal keeps working attendance: identity
  // still comes from the header name, and the missing quantity is worked out
  // from the ones that are left.
  group('hidden columns are derived, not demanded', () {
    test('hidden total days is present + absent', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of absent|no.of present'),
        [
          ['Maths', '5', '15'],
        ],
      );

      final rec = recs.first;
      expect(rec.totalDays, 20);
      expect(rec.present, 15);
      expect(rec.absent, 5);
      expect(rec.percentage, closeTo(75.0, 0.01));
    });

    test('hidden absent is total - present', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of present|total no. of days'),
        [
          ['Maths', '15', '20'],
        ],
      );

      expect(recs.first.absent, 5);
      expect(recs.first.percentage, closeTo(75.0, 0.01));
    });

    test('hidden present is total - absent', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of absent|total no. of days'),
        [
          ['Maths', '5', '20'],
        ],
      );

      expect(recs.first.present, 15);
    });

    test('hidden percentage is present / total', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of absent|no.of present|total no. of days'),
        [
          ['Maths', '5', '15', '20'],
        ],
      );

      expect(recs.first.percentage, closeTo(75.0, 0.01));
    });

    test('percentage plus total reconstructs the counts', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|total no. of days|total percentage'),
        [
          ['Maths', '20', '75.00'],
        ],
      );

      final rec = recs.first;
      expect(rec.present, 15);
      expect(rec.absent, 5);
      expect(rec.totalDays, 20);
    });

    test('percentage plus present reconstructs the total', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of present|total percentage'),
        [
          ['Maths', '15', '75.00'],
        ],
      );

      final rec = recs.first;
      expect(rec.totalDays, 20);
      expect(rec.absent, 5);
    });

    test('percentage plus absent reconstructs the total', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h('subject|no.of absent|total percentage'),
        [
          ['Maths', '5', '75.00'],
        ],
      );

      final rec = recs.first;
      expect(rec.totalDays, 20);
      expect(rec.present, 15);
    });

    test('a blank cell in a shown column is not read as a zero', () {
      final recs = KiitAttendanceScraper.recordsFromGridForTest(
        h(standardHeaders),
        [
          ['Maths', '', '15', '20', '', '12345', 'Dr. X', '0'],
        ],
      );

      final rec = recs.first;
      expect(rec.absent, 5, reason: 'derived from total - present');
      expect(rec.percentage, closeTo(75.0, 0.01));
    });
  });

  group('tables that cannot be read at all', () {
    test('no subject column is reported', () {
      expect(
        () => KiitAttendanceScraper.recordsFromGridForTest(
          h('no.of absent|no.of present|total no. of days|total percentage'),
          [
            ['5', '25', '30', '83.33'],
          ],
        ),
        throwsA(
          isA<ScrapeException>()
              .having((e) => e.kind, 'kind', ScrapeErrorKind.columnsChanged)
              .having((e) => e.message, 'message', contains('subject column')),
        ),
      );
    });

    test('fewer than two numeric columns is reported', () {
      expect(
        () => KiitAttendanceScraper.recordsFromGridForTest(
          h('subject|faculty name|no.of present'),
          [
            ['Maths', 'Dr. X', '15'],
          ],
        ),
        throwsA(
          isA<ScrapeException>()
              .having((e) => e.kind, 'kind', ScrapeErrorKind.columnsChanged)
              .having((e) => e.message, 'message', contains('too few columns')),
        ),
      );
    });
  });
}
