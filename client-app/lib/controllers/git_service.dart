import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

class GitService extends GetxController {
  late String branch;

  late final CacheOptions cacheOptions;
  late final Dio dio;

  // normal schedule years
  List<String>? years;
  RxString? _selectedYear;
  String? get selectedYear => _selectedYear?.value;
  set selectedYear(String? newYear) {
    if (newYear == null || selectedYear == newYear) {
      return;
    }
    _selectedYear = newYear.obs;
    filterController.activeSemester = null;
    update();
    getSemesters();
  }

  // elective year
  List<String>? electiveYears;

  RxString? _selectedElectiveYear;
  String? get selectedElectiveYear => _selectedElectiveYear?.value;
  set selectedElectiveYear(String? newYear) {
    if (newYear == null || selectedElectiveYear == newYear) {
      return;
    }
    _selectedElectiveYear = newYear.obs;
    filterController.activeElectiveSemester = null;
    update();
    getElectiveSemesters();
    // getElectiveSchemes();
  }

  RxMap? _sections;
  RxMap? get sections => _sections;

  RxList? _semesters;
  List? get semesters => _semesters?.toList();
  set semesters(List? newSemesters) {
    Logger.i("setting sermestes to $newSemesters");
    if (newSemesters == null) return;
    _semesters = newSemesters.obs;
    update();
  }

  RxList? _electivesSemesters;
  List? get electivesSemesters => _electivesSemesters?.toList();
  set electivesSemesters(List? newElectivesSemesters) {
    if (newElectivesSemesters == null || newElectivesSemesters.isEmpty) {
      _electivesSemesters = null;
      update();
      return;
    }
    _electivesSemesters = newElectivesSemesters.obs;
    update();
    return;
  }

  RxMap? electiveSchemes;

  RxBool isWorking = false.obs;
  late FilterController filterController;

  Map? errorDetails;

  @override
  void onReady() async {
    super.onReady();
    filterController = Get.find();
    setRepositoryBranch();
    await startCachingService();
    await getYears();
    await getSemesters();
    await getElectiveSemesters();
    await getElectiveYears();
  }

  /// Adds an interceptor to global dio instance, which is used to
  /// cache responses from requested API's.
  ///
  /// Implemented to enable offline functionality, to fetch schedules
  /// once it's cached in temp storage.
  Future<void> startCachingService() async {
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
  Future<void> getYears() async {
    try {
      isWorking.value ? null : isWorking.toggle();
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;

      years = List.from(data.keys);

      // stop execution if there are no semesters for selected year
      if (years!.isEmpty) {
        CustomSnackbar.error('Error', 'No Years found, contact support.');
        return;
      }
      Logger.i("Fetched years: $years");
      setYear();
      !isWorking.value ? null : isWorking.toggle();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      Logger.i(errorDetails);

      !isWorking.value ? null : isWorking.toggle();
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      Logger.i(e.toString());
      !isWorking.value ? null : isWorking.toggle();
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
  Future<void> getSemesters() async {
    try {
      if (selectedYear == null) {
        return;
      }

      isWorking.value ? null : isWorking.toggle();
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;

      semesters = RxList.from(data["$selectedYear"]?.keys);

      // stop execution if there are no semesters for selected year
      if (semesters!.isEmpty) {
        CustomSnackbar.error(
          'Error',
          'No Semesters found for year: $selectedYear',
        );
        return;
      }

      update();
      Logger.i("Fetched semesters: $_semesters");

      filterController.setPrimarySemester();

      !isWorking.value ? null : isWorking.toggle();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      !isWorking.value ? null : isWorking.toggle();
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};

      !isWorking.value ? null : isWorking.toggle();
      return;
    }
  }

  /// Gets all the available sections for a selected semester.
  Future<void> getSections() async {
    try {
      isWorking.value ? null : isWorking.toggle();

      FilterController filterController = Get.find();
      if (filterController.activeSemester == null ||
          selectedYear == null ||
          semesters == null) {
        _sections?.clear();
        update();
        return;
      }
      String activeSemester = filterController.activeSemester!;

      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      _sections = RxMap.from(data["$selectedYear"][activeSemester]);
      update();
      filterController.setPrimarySection();
      Logger.i("Fetched sections: $sections");
      !isWorking.value ? null : isWorking.toggle();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      !isWorking.value ? null : isWorking.toggle();
      throw Future.error(errorDetails.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      Logger.i(e.toString());
      !isWorking.value ? null : isWorking.toggle();
      throw Future.error(errorDetails.toString());
    }
  }

  /// Gets concurrent timetable for unique semester and section.
  Future<Timetable?> getTimeTable() async {
    FilterController filterController = Get.find();
    final section = filterController.activeSectionCode;
    final semester = filterController.activeSemester;

    if (section == null || semester == null || selectedYear == null) {
      return null;
    }

    isWorking.value ? null : isWorking.toggle();
    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/$selectedYear/$semester/$section.json";
    try {
      final response = await dio.get(url);

      if (response.statusCode! >= 400) {
        return Future.error(response);
      }

      !isWorking.value ? null : isWorking.toggle();
      return Timetable.fromJson(jsonDecode(response.data));
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

      !isWorking.value ? null : isWorking.toggle();
      Logger.i(e.toString());
      return Future.error(Exception(errorDetails));
    } catch (e) {
      errorDetails = {
        "type": "CatchException",
        "message": "Some unknown error occoured.",
      };

      !isWorking.value ? null : isWorking.toggle();
      return Future.error(Exception(errorDetails));
    }
  }

  ///
  Future<void> getElectiveYears() async {
    try {
      electivesSemesters = null;
      electivesSemesters = null;
      isWorking.value ? null : isWorking.toggle();
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;

      electiveYears = List.from(data.keys);

      // stop execution if there are no semesters for selected year
      if (electiveYears!.isEmpty) {
        CustomSnackbar.error('Error', 'No Years found, contact support.');
        return;
      }
      Logger.i("Fetched electives years: $electiveYears");
      await filterController.setPrimaryElectiveYear();
      getElectiveSemesters();
      !isWorking.value ? null : isWorking.toggle();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      Logger.i(errorDetails);
      update();
      !isWorking.value ? null : isWorking.toggle();
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      Logger.i(e.toString());
      !isWorking.value ? null : isWorking.toggle();
      return;
    }
  }

  /// Gets available semesters for elective.
  Future<void> getElectiveSemesters() async {
    try {
      if (selectedElectiveYear == null) {
        return;
      }
      isWorking.value ? null : isWorking.toggle();

      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      electivesSemesters = RxList.from(data["$selectedElectiveYear"].keys);
      Logger.i("Fetched elective semesters: $electivesSemesters");

      // if no semesters are available, show snackbar
      if (electivesSemesters!.isEmpty) {
        CustomSnackbar.error(
          "Error",
          "No semesters are available for the selected year.",
        );
      }

      !isWorking.value ? null : isWorking.toggle();
      await filterController.setPrimaryElectiveSemester();
      update();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };
      !isWorking.value ? null : isWorking.toggle();
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};

      !isWorking.value ? null : isWorking.toggle();

      return;
    }
  }

  /// Gets available schemes (usually A or B) for elective.
  Future<void> getElectiveSchemes() async {
    try {
      isWorking.value ? null : isWorking.toggle();
      update();
      FilterController filterController = Get.find();
      if (filterController.activeElectiveSemester == null) {
        return;
      }

      String activeSemester = filterController.activeElectiveSemester!;
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;

      if (data["$selectedElectiveYear"][activeSemester] == null) {
        electiveSchemes = null;
        filterController.activeElectiveScheme = null;
        return;
      }

      electiveSchemes = RxMap.from(
        data["$selectedElectiveYear"][activeSemester],
      );

      // if no schemes are available, show snackbar
      if (electiveSchemes == null) {
        CustomSnackbar.error(
          "Error",
          "No schemes available for the selected semester.",
        );
        return;
      }

      Logger.i("Fetched electives schemes: $electiveSchemes");
      !isWorking.value ? null : isWorking.toggle();
      await filterController.setPrimaryElectiveScheme();
      update();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };

      !isWorking.value ? null : isWorking.toggle();
      update();
      throw Exception(e.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};

      !isWorking.value ? null : isWorking.toggle();

      throw Exception(e.toString());
    }
  }

  /// Gets concurrent elective timetable for unique semester and section.
  Future<Timetable?> getElectives() async {
    isWorking.value ? null : isWorking.toggle();

    if (filterController.activeElectiveSchemeCode == null ||
        filterController.activeElectiveSemester == null) {
      return null;
    }

    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/$selectedElectiveYear/${filterController.activeElectiveSemester}/electives-scheme-${filterController.activeElectiveSchemeCode}.json";
    try {
      final response = await dio.get(url);

      if (response.statusCode! >= 400) {
        return Future.error(response);
      }
      if (response.data == "") {
        return null;
      }

      !isWorking.value ? null : isWorking.toggle();

      return Timetable.fromJson(jsonDecode(response.data));
    } on DioException catch (e) {
      errorDetails = {
        'error': 'DioException',
        'type': e.type.toString(),
        'code': e.response?.statusCode.toString(),
        'message':
            'We couldn\'t fetch requested timetable. Please try again later.',
      };

      !isWorking.value ? null : isWorking.toggle();

      return Future.error(Exception(errorDetails));
    } catch (e) {
      errorDetails = {
        "type": "CatchException",
        "message": "Some unknown error occoured.",
      };

      !isWorking.value ? null : isWorking.toggle();

      return Future.error(Exception(errorDetails));
    }
  }
}
