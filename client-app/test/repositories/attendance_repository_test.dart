import 'package:flutter_test/flutter_test.dart';
import 'package:plan_sync/core/services/kiit_attendance_scraper.dart';
import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/repository/attendance_repository_impl.dart';

import '../helpers/fake_cache_service.dart';

class _FakeScraper extends KiitAttendanceScraper {
  _FakeScraper({this.result, this.error});

  final AttendanceResult? result;
  final Object? error;

  @override
  Future<AttendanceResult> scrape({
    required String username,
    required String password,
    required String academicYear,
    required String session,
    void Function(String message)? onLog,
  }) async {
    onLog?.call('scraping');
    if (error != null) throw error!;
    return result!;
  }
}

AttendanceResult _result({
  String academicYear = '2025-2026',
  String session = 'Autumn',
  Duration age = Duration.zero,
}) =>
    AttendanceResult(
      records: const [],
      student: null,
      academicYear: academicYear,
      session: session,
      fetchedAt: DateTime.now().subtract(age),
    );

void main() {
  group('fetch', () {
    test('scrapes, writes to cache, and returns the result', () async {
      final cache = FakeCacheService();
      final repo = AttendanceRepositoryImpl(
        cache: cache,
        scraperFactory: () => _FakeScraper(result: _result()),
      );

      final logs = <String>[];
      final fetched = await repo.fetch(
        registrationNumber: '22001234',
        password: 'pw',
        academicYear: '2025-2026',
        session: 'Autumn',
        onLog: logs.add,
      );

      expect(fetched.academicYear, '2025-2026');
      expect(logs, contains('scraping'));

      // Written to cache under the period key → readable via cached().
      final cached = await repo.cached(
        registrationNumber: '22001234',
        academicYear: '2025-2026',
        session: 'Autumn',
      );
      expect(cached, isNotNull);
      expect(cached!.session, 'Autumn');
    });

    test('propagates scrape errors without caching', () async {
      final cache = FakeCacheService();
      final repo = AttendanceRepositoryImpl(
        cache: cache,
        scraperFactory: () => _FakeScraper(error: StateError('boom')),
      );

      await expectLater(
        repo.fetch(
          registrationNumber: '22001234',
          password: 'pw',
          academicYear: '2025-2026',
          session: 'Autumn',
          onLog: (_) {},
        ),
        throwsStateError,
      );
      final cached = await repo.cached(
        registrationNumber: '22001234',
        academicYear: '2025-2026',
        session: 'Autumn',
      );
      expect(cached, isNull);
    });
  });

  group('cached', () {
    test('returns null when nothing is cached', () async {
      final repo = AttendanceRepositoryImpl(cache: FakeCacheService());
      final cached = await repo.cached(
        registrationNumber: 'x',
        academicYear: '2025-2026',
        session: 'Autumn',
      );
      expect(cached, isNull);
    });
  });

  group('isStale', () {
    final repo = AttendanceRepositoryImpl(cache: FakeCacheService());

    test('fresh within the 4h window, stale after', () {
      expect(repo.freshnessWindow, const Duration(hours: 4));
      expect(repo.isStale(_result(age: const Duration(hours: 1))), isFalse);
      expect(repo.isStale(_result(age: const Duration(hours: 3, minutes: 59))),
          isFalse);
      expect(repo.isStale(_result(age: const Duration(hours: 5))), isTrue);
    });
  });
}
