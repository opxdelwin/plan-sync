// lib/src/services/background_git_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class BackgroundGitService {
  late String _branch;
  late CacheOptions _cacheOptions;
  late Dio _dio;

  BackgroundGitService() {
    _setRepositoryBranch();
  }

  /// Initializes Dio and caching service for background use.
  Future<void> init() async {
    try {
      final dir = await getApplicationCacheDirectory();

      _cacheOptions = CacheOptions(
        store: HiveCacheStore(
          dir.path,
          hiveBoxName:
              'plan_sync_background', // Use a separate hive box for background cache
        ),
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
        priority: CachePriority.high,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      );

      _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15), // Connection timeout
          receiveTimeout:
              const Duration(seconds: 15), // Receive timeout for data
          headers: {'Cache-Control': 'no-cache'},
          contentType: "application/json",
        ),
      );
      _dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions));
      print('BackgroundGitService: Caching service initialized.');
    } catch (e, stack) {
      print(
          'BackgroundGitService: Error initializing caching service: $e\n$stack');
      rethrow;
    }
  }

  /// Sets the repository branch based on release mode.
  void _setRepositoryBranch() {
    if (kReleaseMode) {
      _branch = 'main';
    } else {
      _branch = 'dev';
    }
    print('BackgroundGitService: Repository branch set to $_branch');
  }

  /// Gets timetable for unique semester and section.
  Future<Timetable?> pullTimetable({
    required String year,
    required String semester,
    required String sectionCode,
  }) async {
    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$_branch/res/$year/$semester/$sectionCode.json";
    print('BackgroundGitService: Attempting to fetch timetable from: $url');

    try {
      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      print('BackgroundGitService: Checking cache for key: $key');
      final cache = await _cacheOptions.store?.get(key);

      if (cache != null) {
        final cachedResponse = cache.toResponse(options);
        print(
          "BackgroundGitService: Found cached data. "
          "Yielding cached timetable.",
        );
        return Timetable.fromJson(
          json: jsonDecode(cachedResponse.data),
          isFresh: false,
        );
      }
      print(
        'BackgroundGitService: No cache found. Proceeding with network request.',
      );

      final response = await _dio.get(url);
      print(
        'BackgroundGitService: Network request completed. '
        'Status Code: ${response.statusCode}',
      );

      if (response.statusCode! >= 400) {
        print(
          "BackgroundGitService: HTTP Error ${response.statusCode} for URL: $url",
        );
        return null;
      }
      if (response.data == "" || response.data == null) {
        print(
          "BackgroundGitService: Empty response data for URL: $url.",
        );
        return null;
      }

      print(
        "BackgroundGitService: Network data received. ETag check.",
      );
      if (response.headers.map['etag']?.first != cache?.eTag) {
        print(
          "BackgroundGitService: Received Schedule with different ETag. "
          "Parsing new data.",
        );
        return Timetable.fromJson(
          json: jsonDecode(response.data),
          isFresh: true,
        );
      } else {
        print(
          'BackgroundGitService: ETag matches. '
          'Checking internet connection for freshness.',
        );
        final connectionAvailable =
            await InternetConnection().hasInternetAccess;
        // If ETag matches, return cached data but update freshness based on connection
        return Timetable.fromJson(
          json: jsonDecode(cache!.toResponse(options).data),
          isFresh: connectionAvailable,
        );
      }
    } on DioException catch (e, stack) {
      print(
          'BackgroundGitService: DioException fetching timetable: $e\n$stack');
      if (e.type == DioExceptionType.connectionError) {
        print(
          'BackgroundGitService: Connection error. '
          'Attempting to use cache as fallback.',
        );
        final options = RequestOptions(path: url);
        final key = CacheOptions.defaultCacheKeyBuilder(options);
        final cache = await _cacheOptions.store?.get(key);
        if (cache != null) {
          print(
            'BackgroundGitService: Returning cached data on connection error.',
          );
          return Timetable.fromJson(
            json: jsonDecode(cache.toResponse(options).data),
            isFresh: false,
          );
        } else {
          print(
            'BackgroundGitService: No cache available '
            'for connection error fallback.',
          );
        }
      } else if (e.type == DioExceptionType.receiveTimeout) {
        print(
          'BackgroundGitService: Receive timeout occurred for URL: $url',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        print(
          'BackgroundGitService: Connection timeout occurred for URL: $url',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        print(
          'BackgroundGitService: Bad response (e.g., 404, 500) for URL: '
          '$url. Status: ${e.response?.statusCode}',
        );
      }
      return null;
    } catch (e, stack) {
      print(
        'BackgroundGitService: General exception fetching timetable: $e\n$stack',
      );
      return null;
    }
  }
}
