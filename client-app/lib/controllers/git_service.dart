import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plan_sync/backend/supabase_models/academic_years.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/backend/supabase_models/branches.dart';
import 'package:plan_sync/backend/supabase_models/programs.dart';
import 'package:plan_sync/backend/supabase_models/section.dart';
import 'package:plan_sync/backend/supabase_models/semesters.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/local_database_provider.dart';
import 'package:plan_sync/controllers/supabase_provider.dart';
import 'package:plan_sync/util/hashing.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class GitService extends ChangeNotifier {
  late String branch;

  late final CacheOptions cacheOptions;
  late final Dio dio;

  List<Program>? _programs;
  List<Program>? get programs => _programs;
  set programs(List<Program>? newPrograms) {
    _programs = newPrograms;
    branches = null;
    notifyListeners();
    filterController.setPrimaryProgram();
    return;
  }

  List<Branches>? _branches;
  List<Branches>? get branches => _branches;
  set branches(List<Branches>? newBranches) {
    _branches = newBranches;
    semesters = null;
    notifyListeners();
    filterController.selectedBranch = null;
    filterController.setPrimaryBranch();
    return;
  }

  // normal schedule years
  List<AcademicYear>? years;
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

  List<Section>? _sections;
  List<Section>? get sections => _sections;
  set sections(List<Section>? newSections) {
    _sections = newSections;
    if (_sections == null) {
      filterController.activeSection = null;
    }
    notifyListeners();
    filterController.setPrimarySection();
    return;
  }

  List<Semesters>? _semesters;
  List<Semesters>? get semesters => _semesters?.toList();
  set semesters(List<Semesters>? newSemesters) {
    Logger.i("setting sermestes to $newSemesters");
    if (newSemesters == null) {
      filterController.activeSemester = null;
      return;
    }
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

  Future<void> onInit() async {
    // onInit
    setRepositoryBranch();
    await startCachingService();
    notifyListeners();
  }

  Future<void> onReady(BuildContext ctx) async {
    // onReady
    filterController = Provider.of<FilterController>(ctx, listen: false);
    await getProgram(ctx);
    await getYears(ctx);
    await getSemesters(ctx);
    await getElectiveSemesters(ctx);
    await getElectiveYears(ctx);
    notifyListeners();
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

  /// Select from public.programs
  Future<void> getProgram(BuildContext context) async {
    try {
      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      final localDatabase =
          Provider.of<LocalDatabaseProvider>(context, listen: false);
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);

      final cacheData = await localDatabase.getProgramsFromLocal();
      if (cacheData.isNotEmpty) {
        Logger.i("Cached Academic Programs: $cacheData");
        programs = cacheData;
        filterController.setPrimaryProgram();
        notifyListeners();
      }

      final response = await supabaseProvider.getProgramsFromRemote(
        exitIfNoInternet: true,
      );

      // Terminate if the device is offline
      if (response == null) {
        Logger.e('log: stopping after getProgram');
        return;
      }

      // stop if the hash matches for both cached and newly fetched
      if (genSortedHash(cacheData) == genSortedHash(response)) {
        Logger.w('Academic Program is cached.');
        await getBranch(context);
        return;
      }

      programs = response;

      // stop execution if there are no semesters for selected year
      if (programs!.isEmpty) {
        CustomSnackbar.error(
          'Error',
          'No Programs found, contact support.',
          context,
        );
        return;
      }
      Logger.i("Fetched Programs: $programs");
      notifyListeners();
      setYear();

      // save data to sqflite
      localDatabase.insertProgramsToLocal(response);

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

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException @ Fetching Programs"};
      Logger.i(e.toString());
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    }
  }

  /// Select from public.branch
  Future<void> getBranch(BuildContext context) async {
    try {
      // Program must be selected to fetch branches
      if (filterController.selectedProgram == null) {
        return;
      }

      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      final localDatabase =
          Provider.of<LocalDatabaseProvider>(context, listen: false);
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);

      final cacheData = await localDatabase.getBranchesFromLocal(
        programName: filterController.selectedProgram!.name,
      );
      if (cacheData.isNotEmpty) {
        Logger.i("Cached Branches: $cacheData");
        branches = cacheData;
        await filterController.setPrimaryBranch();

        semesters = null;
        filterController.activeSemester = null;
        await getSemesters(context);
        notifyListeners();
      }

      final response = await supabaseProvider.getBranchesFromRemote(
        programName: filterController.selectedProgram!.name,
        exitIfNoInternet: true,
      );

      // Terminate if the device is offline
      if (response == null) {
        Logger.e('log: stopping after getBranch');
        return;
      }

      // stop if the hash matches for both cached and newly fetched
      if (genSortedHash(cacheData) == genSortedHash(response)) {
        Logger.w(
          'Program (${filterController.selectedProgram!.name}) Branches are cached.',
        );
        return;
      }

      branches = response;

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

      // save data to sqflite
      localDatabase.insertBranchesToLocal(response);

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

  ///
  Future<void> getYears(BuildContext context) async {
    try {
      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      final localDatabase =
          Provider.of<LocalDatabaseProvider>(context, listen: false);
      final supabaseProvider =
          Provider.of<SupabaseProvider>(context, listen: false);

      final cacheData = await localDatabase.getYearsFromLocal();
      if (cacheData.isNotEmpty) {
        Logger.i("Cached Years: $cacheData");
        years = List.from(cacheData);
        setYear();
      }

      final response = await supabaseProvider.getYearsFromRemote(
        exitIfNoInternet: true,
      );
      // Terminate if the device is offline
      if (response == null) {
        Logger.e('log: stopping after getYears');
        return;
      }

      // stop if the hash matches for both cached and newly fetched
      if (genSortedHash(cacheData) == genSortedHash(response)) {
        Logger.w('Normal Schedulw Year is cached.');
        return;
      }

      years = response;

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

      // save data to sqflite
      localDatabase.insertYearsToLocal(response);

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
      // both program and academic year must be selected
      if (selectedYear == null ||
          filterController.selectedProgram == null ||
          filterController.selectedBranch == null) {
        semesters = [];
        filterController.activeSemester = null;
        getSections(context);
        notifyListeners();
        return;
      }

      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      final localDatabase = Provider.of<LocalDatabaseProvider>(
        context,
        listen: false,
      );
      final supabaseProvider = Provider.of<SupabaseProvider>(
        context,
        listen: false,
      );

      final cacheData = await localDatabase.getSemestersFromLocal(
          programName: filterController.selectedProgram!.name,
          academicYear: selectedYear!,
          branchName: filterController.selectedBranch!.branchName);
      if (cacheData.isNotEmpty) {
        Logger.i("Cached Semesters: $cacheData");
        semesters = cacheData;
        filterController.setPrimarySemester(context);

        sections = null;
        getSections(context);
        notifyListeners();
      }

      final response = await supabaseProvider.getSemestersFromRemote(
        programName: filterController.selectedProgram!.name,
        academicYear: selectedYear!,
        branchName: filterController.selectedBranch!.branchName,
        exitIfNoInternet: true,
      );
      // Terminate if the device is offline
      if (response == null) {
        Logger.e('log: stopping after getSemesters');
        return;
      }

      if (genSortedHash(cacheData) == genSortedHash(response)) {
        Logger.i("Semester cache hash matches");
        if (isWorking) {
          isWorking = false;
          notifyListeners();
        }
        return;
      }

      semesters = response;

      // save new resposne as cache
      localDatabase.insertSemestersToLocal(
        response,
        programName: filterController.selectedProgram!.name,
        academicYear: selectedYear!,
        branchName: filterController.selectedBranch!.branchName,
      );

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

      filterController.setPrimarySemester(context);

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

      return;
    } catch (e) {
      errorDetails = {"error": "CatchException @ Fetching Semesters"};

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      return;
    }
  }

  /// Gets all the available sections for a selected semester.
  Future<void> getSections(BuildContext context) async {
    try {
      if (filterController.activeSemester == null ||
          selectedYear == null ||
          filterController.selectedBranch == null ||
          filterController.selectedProgram == null) {
        sections = null;
        filterController.activeSection = null;
        notifyListeners();
        return;
      }

      if (!isWorking) {
        isWorking = true;
        notifyListeners();
      }

      Semesters activeSemester = filterController.activeSemester!;
      final localDatabase = Provider.of<LocalDatabaseProvider>(
        context,
        listen: false,
      );
      final supabaseProvider = Provider.of<SupabaseProvider>(
        context,
        listen: false,
      );

      final cacheData = await localDatabase.getSectionsFromLocal(
        programName: filterController.selectedProgram!.name,
        academicYear: selectedYear!,
        branch: filterController.selectedBranch!.branchName,
        semester: activeSemester.semesterName,
      );

      if (cacheData.isNotEmpty) {
        sections = cacheData;
        await filterController.setPrimarySection();
        notifyListeners();
        Logger.i("Cached sections: $sections");
      }

      final response = await supabaseProvider.getSectionsFromRemote(
        programName: filterController.selectedProgram!.name,
        academicYear: selectedYear!,
        branch: filterController.selectedBranch!.branchName,
        semester: activeSemester.semesterName,
        exitIfNoInternet: true,
      );
      // Terminate if the device is offline
      if (response == null) {
        Logger.e('log: stopping after getSections');

        return;
      }

      if (genSortedHash(cacheData) == genSortedHash(response)) {
        Logger.i("Sections cache hash matches");
        if (isWorking) {
          isWorking = false;
          notifyListeners();
        }
        return;
      }

      await localDatabase.insertSectionsToLocal(
        response,
        programName: filterController.selectedProgram!.name,
        academicYear: selectedYear!,
        branch: filterController.selectedBranch!.branchName,
        semester: activeSemester.semesterName,
      );

      sections = response;
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
      errorDetails = {"error": "CatchException @ Fetching Sections"};
      Logger.i(e.toString());
      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      throw Future.error(errorDetails.toString());
    }
  }

  /// Gets concurrent timetable for unique semester and section.
  Stream<Timetable?> getTimeTable(BuildContext context) async* {
    final section = filterController.activeSection?.sectionName;
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
    try {
      final localDatabase = Provider.of<LocalDatabaseProvider>(
        context,
        listen: false,
      );
      final supabaseProvider = Provider.of<SupabaseProvider>(
        context,
        listen: false,
      );

      final cache = await localDatabase.getStudentScheduleFromLocal(
        programName: filterController.selectedProgram!.name,
        academicYear: selectedYear!,
        branch: filterController.selectedBranch!.branchName,
        semester: semester.semesterName,
        section: section,
      );

      if (cache.isNotEmpty) {
        Logger.i(
          "Yield Schedule Cache : ${DateTime.now().millisecondsSinceEpoch}",
        );

        yield Timetable.fromStudentScheduleModel(
          scheduleList: cache,
          isFresh: false,
        );
      }

      final response = await supabaseProvider.getStudentSchedulesFromRemote(
        programName: filterController.selectedProgram!.name,
        academicYear: selectedYear!,
        branch: filterController.selectedBranch!.branchName,
        semester: semester.semesterName,
        section: section,
      );
      // Terminate if the device is offline / or data is null
      if (response == null) {
        Logger.e('log: getTimeTable remote response is null');
        return;
      }

      if (isWorking) {
        isWorking = false;
        notifyListeners();
      }
      Logger.i("Yield Actual : ${DateTime.now().millisecondsSinceEpoch}");

      /// send data again only if e-tag are different
      if (genSortedHash(cache) != genSortedHash(response)) {
        Logger.i("Received Schedule with different ETag");

        localDatabase.insertStudentScheduleToLocal(
          response,
          programName: filterController.selectedProgram!.name,
          academicYear: selectedYear!,
          branch: filterController.selectedBranch!.branchName,
          semester: semester.semesterName,
          section: section,
        );

        yield Timetable.fromStudentScheduleModel(
          scheduleList: response,
          isFresh: true,
        );
        yield* const Stream.empty();
      } else {
        Logger.i('ETag matches');

        yield Timetable.fromStudentScheduleModel(
          scheduleList: cache,
          isFresh: true,
        );
        yield* const Stream.empty();
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
        "error": e.toString(),
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
      notifyListeners();
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
        Logger.i("Sending Elecive from cache");

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
      if (response.headers.map['etag']?.first != cacheData?.eTag) {
        yield Timetable.fromJson(
          json: jsonDecode(response.data),
          isFresh: true,
        );
      }

      yield* const Stream.empty();
      return;
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
        "message": "Some unknown error occoured while getting electives",
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
