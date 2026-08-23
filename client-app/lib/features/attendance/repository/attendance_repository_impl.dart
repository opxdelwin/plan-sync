import 'package:plan_sync/core/cache/cache_service.dart';
import 'package:plan_sync/core/services/kiit_attendance_scraper.dart';
import 'package:plan_sync/core/services/remote_config_service.dart';
import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/repository/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({
    required CacheService cache,
    RemoteConfigService? remoteConfig,
    KiitAttendanceScraper Function()? scraperFactory,
  })  : _cache = cache,
        _remoteConfig = remoteConfig,
        _scraperFactory = scraperFactory ?? KiitAttendanceScraper.new;

  final CacheService _cache;

  /// Serves the Remote Config scraper script. Optional so tests (which inject a
  /// fake scraper) can omit it; when null the scraper uses its baked-in script.
  final RemoteConfigService? _remoteConfig;

  /// Builds the scraper used by [fetch]. Injectable so tests can supply a fake
  /// that returns canned results instead of launching a headless WebView.
  final KiitAttendanceScraper Function() _scraperFactory;

  /// Attendance is posted through the day, so a saved copy older than this is
  /// refreshed rather than shown as current.
  static const _ttl = Duration(hours: 4);

  @override
  Duration get freshnessWindow => _ttl;

  String _key(String regNo, String year, String session) =>
      'attendance/$regNo/$year/$session';

  @override
  Future<AttendanceResult?> cached({
    required String registrationNumber,
    required String academicYear,
    required String session,
  }) {
    return _cache.get<AttendanceResult>(
      _key(registrationNumber, academicYear, session),
      fromJson: AttendanceResult.fromJson,
    );
  }

  @override
  bool isStale(AttendanceResult result) =>
      DateTime.now().difference(result.fetchedAt) >= _ttl;

  @override
  Future<AttendanceResult> fetch({
    required String registrationNumber,
    required String password,
    required String academicYear,
    required String session,
    required void Function(String step) onLog,
  }) async {
    final scraper = _scraperFactory();
    // Hot-patchable script from Remote Config; blank/unset → baked-in fallback.
    scraper.scriptOverride = _remoteConfig?.sapAgentScript();
    final fetched = await scraper.scrape(
      username: registrationNumber,
      password: password,
      academicYear: academicYear,
      session: session,
      onLog: onLog,
    );
    await _cache.set<AttendanceResult>(
      _key(registrationNumber, fetched.academicYear, fetched.session),
      fetched,
      toJson: (r) => r.toJson(),
    );
    return fetched;
  }
}
