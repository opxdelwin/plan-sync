import 'package:plan_sync/features/attendance/model/attendance_record.dart';
import 'package:plan_sync/features/attendance/repository/attendance_repository.dart';

/// In-memory [AttendanceRepository] for ViewModel tests. Seed cached results
/// with [seed]; configure [fetch] via [fetchResult] or [fetchError].
class FakeAttendanceRepository implements AttendanceRepository {
  final Map<String, AttendanceResult> _store = {};

  /// Freshness window used by [isStale]; mirrors the production default.
  Duration ttl = const Duration(hours: 4);

  @override
  Duration get freshnessWindow => ttl;

  /// Returned by [fetch] when set (and [fetchError] is null).
  AttendanceResult? fetchResult;

  /// Thrown by [fetch] when set. Defaults to throwing if neither is configured,
  /// mirroring a scrape that fails (e.g. no WebView in tests).
  Object? fetchError;

  int fetchCount = 0;

  String _key(String regNo, String year, String session) =>
      '$regNo/$year/$session';

  void seed(
    String registrationNumber,
    String academicYear,
    String session,
    AttendanceResult result,
  ) =>
      _store[_key(registrationNumber, academicYear, session)] = result;

  @override
  Future<AttendanceResult?> cached({
    required String registrationNumber,
    required String academicYear,
    required String session,
  }) async =>
      _store[_key(registrationNumber, academicYear, session)];

  @override
  bool isStale(AttendanceResult result) =>
      DateTime.now().difference(result.fetchedAt) >= ttl;

  @override
  Future<AttendanceResult> fetch({
    required String registrationNumber,
    required String password,
    required String academicYear,
    required String session,
    required void Function(String step) onLog,
  }) async {
    fetchCount++;
    if (fetchError != null) throw fetchError!;
    if (fetchResult != null) {
      _store[_key(registrationNumber, academicYear, session)] = fetchResult!;
      return fetchResult!;
    }
    throw StateError('FakeAttendanceRepository.fetch not configured');
  }
}
