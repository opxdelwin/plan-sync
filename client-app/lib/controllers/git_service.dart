import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class GitService extends ChangeNotifier {
  late String branch;

  late final CacheOptions cacheOptions;
  late final Dio dio;

  // normal schedule years
  List<String>? years;
  String? _selectedYear;
  String? get selectedYear => _selectedYear;
  set selectedYear(String? newYear) {
    if (newYear == null || selectedYear == newYear) {
      return;
    }
    _selectedYear = newYear;
    filterController.activeSemester = null;
    notifyListeners();
  }

  // elective year
  List<String>? electiveYears;

  String? _selectedElectiveYear;
  String? get selectedElectiveYear => _selectedElectiveYear;
  set selectedElectiveYear(String? newYear) {
    if (newYear == null || selectedElectiveYear == newYear) {
      return;
    }
    _selectedElectiveYear = newYear;
    filterController.activeElectiveSemester = null;
    notifyListeners();

    // getElectiveSchemes();
  }

  Map? _sections;
  Map? get sections => _sections;

  List? _semesters;
  List? get semesters => _semesters?.toList();
  set semesters(List? newSemesters) {
    Logger.i("setting sermestes to $newSemesters");
    if (newSemesters == null) return;
    _semesters = newSemesters;
    notifyListeners();
  }

  List? _electivesSemesters;
  List? get electivesSemesters => _electivesSemesters?.toList();
  set electivesSemesters(List? newElectivesSemesters) {
    if (newElectivesSemesters == null || newElectivesSemesters.isEmpty) {
      _electivesSemesters = null;
      notifyListeners();
      return;
    }
    _electivesSemesters = newElectivesSemesters;
    notifyListeners();
    return;
  }

  Map? electiveSchemes;

  bool isWorking = false;
  late FilterController filterController;

  Map? errorDetails;

  /// Helper method to show network error snackbar
  void _showNetworkErrorSnackbar(BuildContext context, String source) {
    if (context.mounted) {
      CustomSnackbar.error(
        'Poor Internet Connection',
        'Please restart app with a better connection',
        context,
      );
    }
  }

  Future<void> onInit() async {
    // onInit
    setRepositoryBranch();
    await startCachingService();
    notifyListeners();
  }

  Future<void> onReady(BuildContext ctx) async {
    try {
      // onReady
      filterController = Provider.of<FilterController>(ctx, listen: false);
      await getYears(ctx);
      await getSemesters(ctx);
      await getElectiveSemesters(ctx);
      await getElectiveYears(ctx);
      notifyListeners();
    } on DioException catch (e) {
      _showNetworkErrorSnackbar(ctx, 'onReady');
      Logger.i('DioException in onReady: ${e.toString()}');
    } catch (e) {
      Logger.i('General exception in onReady: ${e.toString()}');
    }
  }

  /// Adds an interceptor to global dio instance, which is used to
  /// cache responses from requested API's.
  ///
  /// Implemented to enable offline functionality, to fetch schedules
  /// once it's cached in temp storage.
  Future<void> startCachingService() async {
    try {
      final dir = await getApplicationCacheDirectory();

      cacheOptions = CacheOptions(
        store: HiveCacheStore(
          dir.path,
          hiveBoxName: 'plan_sync',
        ),
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
        priority: CachePriority.high,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      );

      dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          headers: {'Cache-Control': 'no-cache'},
          contentType: "application/json",
        ),
      );
      dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

      return;
    } on DioException catch (e) {
      Logger.i('DioException in startCachingService: ${e.toString()}');
      // Note: We can't show snackbar here as we don't have context
      rethrow; // Re-throw to be handled by caller
    } catch (e) {
      Logger.i('General exception in startCachingService: ${e.toString()}');
      rethrow;
    }
  }

  /// From v1.0.0, app will use main branch for release client app,
  /// and pre-mvp for debug/development.
  void setRepositoryBranch() {
    if (kReleaseMode) {
      branch = 'main';
    } else {
      // branch = 'main';
      branch = 'dev';
    }
    return;
  }

  ///
  Future<void> getYears(BuildContext context) async {
    try {
      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cacheData = await cacheOptions.store?.get(key);
      if (cacheData != null) {
        final cacheResponse = cacheData.toResponse(options);
        final cachedYears = jsonDecode(cacheResponse.data).keys;
        Logger.i("Cached Years: $cachedYears");
        years = List.from(cachedYears);
        setYear();
      }

      final response = await dio.get(url);
      // stop if the etags match for both cached and newly fetched
      if (response.headers.map['etag']?.first == cacheData?.eTag) {
        return;
      }
      final data = jsonDecode(response.data) as Map<String, dynamic>;

      years = List.from(data.keys);

      // stop execution if there are no semesters for selected year
      if (years!.isEmpty) {
        CustomSnackbar.error(
          'Error',
          'No Years found, contact support.',
          context,
        );
        return;
      }
      Logger.i("Fetched years: $years");
      setYear();

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      Logger.i(errorDetails);
      _showNetworkErrorSnackbar(context, 'getYears');

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      Logger.i(e.toString());
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    }
  }

  /// Dynamically sets current year.
  void setYear() {
    // final int currentYear = DateTime.now().year;
    // if (years?.contains(currentYear.toString()) != false) {
    //   selectedYear = currentYear;
    // }
    filterController.setPrimaryYear();
    return;
  }

  /// Gets all the available semesters for a selected year.
  /// While startup, year is same as current year, if available on remote server.
  /// May be changed later.
  Future<void> getSemesters(BuildContext context) async {
    try {
      if (selectedYear == null) {
        return;
      }

      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cacheData = await cacheOptions.store?.get(key);
      if (cacheData != null) {
        final cacheResponse = cacheData.toResponse(options);
        final cachedSemesters =
            jsonDecode(cacheResponse.data)["$selectedYear"]?.keys;
        Logger.i("Cached Semesters: $cachedSemesters");
        semesters = List.from(cachedSemesters);
        notifyListeners();
        filterController.setPrimarySemester();
      }

      final response = await dio.get(url);
      if (response.headers.map['etag']?.first == cacheData?.eTag) {
        Logger.i("Semester Etag matches");
        if (isWorking) {
          isWorking = false;
          notifyListeners();
        }
        return;
      }
      final data = jsonDecode(response.data) as Map<String, dynamic>;

      semesters = List.from(data["$selectedYear"]?.keys);

      // stop execution if there are no semesters for selected year
      if (semesters!.isEmpty) {
        CustomSnackbar.error(
          'Error',
          'No Semesters found for year: $selectedYear',
          context,
        );
        return;
      }

      notifyListeners();
      Logger.i("Fetched semesters: $_semesters");

      filterController.setPrimarySemester();

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      _showNetworkErrorSnackbar(context, 'getSemesters');

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }

      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    }
  }

  /// Gets all the available sections for a selected semester.
  Future<void> getSections(FilterController filterController) async {
    try {
      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      if (filterController.activeSemester == null ||
          selectedYear == null ||
          semesters == null) {
        _sections?.clear();
        notifyListeners();
        return;
      }
      String activeSemester = filterController.activeSemester!;

      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cacheData = await cacheOptions.store?.get(key);
      if (cacheData != null) {
        final cachedResponse = cacheData.toResponse(options);

        _sections = Map.from(
          jsonDecode(cachedResponse.data)["$selectedYear"][activeSemester],
        );
        notifyListeners();
        filterController.setPrimarySection();
        Logger.i("Cached sections: $sections");
      }

      final response = await dio.get(url);

      if (response.headers.map['etag']?.first == cacheData?.eTag) {
        Logger.i("Sections Etag matches");
        if (isWorking) {
          isWorking = false;
          notifyListeners();
        }
        return;
      }

      final data = jsonDecode(response.data) as Map<String, dynamic>;
      _sections = Map.from(data["$selectedYear"][activeSemester]);
      notifyListeners();
      filterController.setPrimarySection();
      Logger.i("Fetched sections: $sections");
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      throw Future.error(errorDetails.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      Logger.i(e.toString());
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      throw Future.error(errorDetails.toString());
    }
  }

  /// Gets concurrent timetable for unique semester and section.
  Stream<Timetable?> getTimeTable(FilterController filterController) async* {
    final section = filterController.activeSectionCode;
    final semester = filterController.activeSemester;

    if (section == null || semester == null || selectedYear == null) {
      yield null;
      yield* const Stream.empty(); // This terminates the stream
      return;
    }

    if (!isWorking) {
      isWorking = true;
      notifyListeners();
    }
    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/$selectedYear/$semester/$section.json";
    try {
      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cache = await cacheOptions.store?.get(key);

      if (cache != null) {
        final cachedResponse = cache.toResponse(options);
        Logger.i("Yield Cache : ${DateTime.now().millisecondsSinceEpoch}");

        yield Timetable.fromJson(
          json: jsonDecode(cachedResponse.data),
          isFresh: false,
        );
      }

      final response = await dio.get(url);

      if (response.statusCode! >= 400) {
        yield* Stream.error(response);
      }

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      Logger.i("Yield Actual : ${DateTime.now().millisecondsSinceEpoch}");

      /// send data again only if e-tag are different
      if (response.headers.map['etag']?.first != cache?.eTag) {
        Logger.i("Received Schedule with different ETag");

        yield Timetable.fromJson(
          json: jsonDecode(response.data),
          isFresh: true,
        );
        yield* const Stream.empty();
      } else {
        Logger.i('ETag matches');

        // as Dio may respond from the cache itself, we can check if the
        // device has active network connection to judge if the response
        // is really from the server..
        final connectionAvailable =
            await InternetConnection().hasInternetAccess;

        yield Timetable.fromJson(
          json: jsonDecode(cache!.toResponse(options).data),
          isFresh: connectionAvailable,
        );
      }
    } on DioException catch (e) {
      errorDetails = {
        'error': 'DioException',
        'type': e.type.toString(),
        'code': e.response?.statusCode.toString(),
        'message':
            'We couldn\'t fetch requested timetable. Please try again later.',
      };

      if (e.type == DioExceptionType.connectionError) {
        errorDetails?['message'] = 'Please check your network connection.';
      }

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      Logger.i(e.toString());
      yield* Stream.error(Exception(errorDetails));
    } catch (e) {
      errorDetails = {
        "type": "CatchException",
        "message": "Some unknown error occoured while getting schedule",
      };

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      yield* Stream.error(Exception(errorDetails));
    }
  }

  ///
  Future<void> getElectiveYears(BuildContext context) async {
    try {
      electivesSemesters = null;
      electivesSemesters = null;
      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cacheData = await cacheOptions.store?.get(key);
      if (cacheData != null) {
        final cachedResponse = cacheData.toResponse(options);

        electiveYears = List.from(jsonDecode(cachedResponse.data).keys);
        Logger.i("Cached elective years: $electiveYears");
        await filterController.setPrimaryElectiveYear();

        getElectiveSemesters(context);
      }

      final response = await dio.get(url);
      // stop execution if etags match
      if (response.headers.map['etag']?.first == cacheData?.eTag &&
          cacheData?.eTag != null) {
        Logger.i("Elective Year Etag Matches, aborting fn");
        if (isWorking) {
          isWorking = false;
          notifyListeners();
        }
        return;
      }

      final data = jsonDecode(response.data) as Map<String, dynamic>;

      electiveYears = List.from(data.keys);

      // stop execution if there are no semesters for selected year
      if (electiveYears!.isEmpty) {
        CustomSnackbar.error(
          'Error',
          'No Years found, contact support.',
          context,
        );
        return;
      }
      Logger.i("Fetched elective years: $electiveYears");
      await filterController.setPrimaryElectiveYear();

      getElectiveSemesters(context);
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      Logger.i(errorDetails);
      _showNetworkErrorSnackbar(context, 'getElectiveYears');

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      Logger.i(e.toString());
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    }
  }

  /// Gets available semesters for elective.
  Future<void> getElectiveSemesters(BuildContext context) async {
    try {
      if (selectedElectiveYear == null) {
        return;
      }
      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cacheData = await cacheOptions.store?.get(key);
      if (cacheData != null) {
        final cachedResponse = cacheData.toResponse(options);
        electivesSemesters = List.from(
          jsonDecode(cachedResponse.data)["$selectedElectiveYear"].keys,
        );

        Logger.i("Cached elective semesters: $electivesSemesters");
        await filterController.setPrimaryElectiveSemester();
        notifyListeners();
      }

      final response = await dio.get(url);

      // stop execution if etags match
      if (response.headers.map['etag']?.first == cacheData?.eTag &&
          cacheData?.eTag != null) {
        Logger.i("Elective Semester Etag Matches, aborting fn");
        if (isWorking) {
          isWorking = false;
          notifyListeners();
        }
        return;
      }

      final data = jsonDecode(response.data) as Map<String, dynamic>;
      electivesSemesters = List.from(data["$selectedElectiveYear"].keys);
      Logger.i("Fetched elective semesters: $electivesSemesters");

      // if no semesters are available, show snackbar
      if (electivesSemesters!.isEmpty) {
        CustomSnackbar.error(
          "Error",
          "No semesters are available for the selected year.",
          context,
        );
      }

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      await filterController.setPrimaryElectiveSemester();
      notifyListeners();
      return;
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      _showNetworkErrorSnackbar(context, 'getElectiveSemesters');

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }

      return;
    }
  }

  /// Gets available schemes (usually A or B) for elective.
  Future<void> getElectiveSchemes({
    BuildContext? context,
    FilterController? filterController,
  }) async {
    assert(context != null || filterController != null);
    final controller = filterController ??
        Provider.of<FilterController>(
          context!,
          listen: false,
        );

    try {
      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      if (controller.activeElectiveSemester == null) {
        return;
      }

      String activeSemester = controller.activeElectiveSemester!;
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cacheData = await cacheOptions.store?.get(key);
      if (cacheData != null) {
        final cachedResponse = cacheData.toResponse(options);
        electiveSchemes = Map.from(
          jsonDecode(cachedResponse.data)["$selectedElectiveYear"]
              [activeSemester],
        );
        Logger.i("cached elective schemes: $electiveSchemes");
        await controller.setPrimaryElectiveScheme();
        notifyListeners();
      }

      final response = await dio.get(url);

      // stop execution if etags match
      if (response.headers.map['etag']?.first == cacheData?.eTag &&
          cacheData?.eTag != null) {
        Logger.i("Elective schemes Etag Matches, aborting fn");
        if (isWorking) {
          isWorking = false;
          notifyListeners();
        }
        return;
      }

      final data = jsonDecode(response.data) as Map<String, dynamic>;

      if (data["$selectedElectiveYear"][activeSemester] == null) {
        electiveSchemes = null;
        controller.activeElectiveScheme = null;
        return;
      }

      electiveSchemes = Map.from(
        data["$selectedElectiveYear"][activeSemester],
      );

      // if no schemes are available, show snackbar
      if (electiveSchemes == null && context != null) {
        CustomSnackbar.error(
          "Error",
          "No schemes available for the selected semester.",
          context,
        );
        return;
      }

      Logger.i("Fetched elective schemes: $electiveSchemes");
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      await controller.setPrimaryElectiveScheme();
      notifyListeners();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      notifyListeners();
      throw Exception(e.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }

      throw Exception(e.toString());
    }
  }

  /// Gets concurrent elective timetable for unique semester and section.
  Stream<Timetable?> getElectives() async* {
    if (!isWorking) {
      isWorking = true;
      notifyListeners();
    }

    if (filterController.activeElectiveSchemeCode == null ||
        filterController.activeElectiveSemester == null) {
      yield* const Stream.empty();
      return;
    }

    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/$selectedElectiveYear/${filterController.activeElectiveSemester}/electives-scheme-${filterController.activeElectiveSchemeCode}.json";
    try {
      final options = RequestOptions(path: url);
      final key = CacheOptions.defaultCacheKeyBuilder(options);

      final cacheData = await cacheOptions.store?.get(key);
      if (cacheData != null) {
        final cachedResponse = cacheData.toResponse(options);
        Logger.i("Sending Elective from cache");

        yield Timetable.fromJson(
          json: jsonDecode(cachedResponse.data),
          isFresh: false,
        );
      }

      final response = await dio.get(url);

      if (response.statusCode! >= 400) {
        yield* Stream.error(response);
        return;
      }
      if (response.data == "") {
        yield* const Stream.empty();
        return;
      }

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }

      // Handle freshness properly like in getTimeTable
      if (response.headers.map['etag']?.first != cacheData?.eTag) {
        Logger.i("Received Elective Schedule with different ETag");

        yield Timetable.fromJson(
          json: jsonDecode(response.data),
          isFresh: true,
        );
        yield* const Stream.empty();
      } else {
        Logger.i('Elective ETag matches');

        // Check network connection to determine freshness
        final connectionAvailable =
            await InternetConnection().hasInternetAccess;

        yield Timetable.fromJson(
          json: jsonDecode(cacheData!.toResponse(options).data),
          isFresh: connectionAvailable, // This fixes the freshness indicator
        );
      }
    } on DioException catch (e) {
      errorDetails = {
        'error': 'DioException',
        'type': e.type.toString(),
        'code': e.response?.statusCode.toString(),
        'message':
            'We couldn\'t fetch requested timetable. Please try again later.',
      };

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }

      yield* Stream.error(Exception(errorDetails));
      return;
    } catch (e) {
      errorDetails = {
        "type": "CatchException",
        "message": "Some unknown error occurred while getting electives",
      };

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }

      yield* Stream.error(Exception(errorDetails));
      return;
    }
  }

  /// Fetches the min.version file from remote.
  Future<String?> fetchMininumVersion() async {
    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/min.version";
    try {
      final response = await dio.get(url);

      if (response.statusCode! >= 400) {
        return Future.error(response);
      }
      if (response.data == "") {
        return null;
      }
      return response.data;
    } on DioException catch (e) {
      errorDetails = {
        'error': 'DioException',
        'type': e.type.toString(),
        'code': e.response?.statusCode.toString(),
        'message':
            'We couldn\'t fetch requested version. Please try again later.',
      };
      return Future.error(Exception(errorDetails));
    } catch (err, trace) {
      errorDetails = {
        "type": "CatchException",
        "message": "Some unknown error occoured fetching minimum version",
      };
      return Future.error(Exception({
        'errorDetails': errorDetails,
        'catchError': err,
        'trace': trace,
      }));
    }
  }
}
