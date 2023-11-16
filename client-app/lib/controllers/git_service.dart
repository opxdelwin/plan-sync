import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';

class GitService extends GetxController {
  final branch = "pre-mvp";
  final year = 2023;
  final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));

  RxMap? _sections;
  RxMap? get sections => _sections;

  RxList? _semesters;
  List? get semesters => _semesters?.toList();
  set semesters(List? newSemesters) {
    print("setting sermestes to $newSemesters");
    if (newSemesters == null) return;
    _semesters = newSemesters.obs;
    update();
  }

  Map? latestTimeTable;
  RxBool isError = false.obs;
  RxBool isElectivesError = false.obs;

  RxMap? latestElectives;
  RxList? electivesSemesters;
  RxMap? electiveSchemes;

  RxBool isWorking = false.obs;
  late FilterController filterController;

  Map? errorDetails;

  @override
  void onInit() async {
    super.onInit();
    filterController = Get.find();
    await getSemesters();
    await getElectiveSemesters();
  }

  // by deault year is 2023
  Future<void> getSemesters() async {
    try {
      isError.value ? isError.toggle() : null;
      isWorking.value ? null : isWorking.toggle();
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      semesters = RxList.from(data["$year"].keys);
      update();
      print("Fetched semesters: $_semesters");

      filterController.setPrimarySemester();

      !isWorking.value ? null : isWorking.toggle();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };
      isError = true.obs;
      update();
      !isWorking.value ? null : isWorking.toggle();
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      isError = true.obs;
      update();
      !isWorking.value ? null : isWorking.toggle();
      return;
    }
  }

  Future<void> getSections() async {
    isError.value ? isError.toggle() : null;
    try {
      isWorking.value ? null : isWorking.toggle();

      FilterController filterController = Get.find();
      String activeSemester = filterController.activeSemester!;

      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/sections.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      _sections = RxMap.from(data["$year"][activeSemester]);
      update();
      filterController.setPrimarySection();
      print("Fetched semesters: $sections");
      !isWorking.value ? null : isWorking.toggle();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };
      isError = true.obs;
      update();
      !isWorking.value ? null : isWorking.toggle();
      throw Exception(e.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      isError = true.obs;
      update();
      !isWorking.value ? null : isWorking.toggle();
      throw Exception(e.toString());
    }
  }

  Future<void> getTimeTable() async {
    isError.value ? isError.toggle() : null;
    FilterController filterController = Get.find();
    final section = filterController.activeSectionCode;
    final semester = filterController.activeSemester;

    if (section == null) {
      return;
    }

    isWorking.value ? null : isWorking.toggle();
    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/$year/$semester/$section.json";
    try {
      final response = await dio.get(url,
          options: Options(
            headers: {
              "accept": "application/vnd.github+json",
              'X-GitHub-Api-Version': '2022-11-28'
            },
            contentType: "application/json",
          ));
      if (response.statusCode != 200) {
        throw DioException(requestOptions: response.requestOptions);
      }
      latestTimeTable = jsonDecode(response.data);
      isError = false.obs;

      update();
      !isWorking.value ? null : isWorking.toggle();
      return;
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };
      isError = true.obs;
      update();
      !isWorking.value ? null : isWorking.toggle();
      throw Exception(e.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      isError = true.obs;
      update();
      !isWorking.value ? null : isWorking.toggle();
      throw Exception(e.toString());
    }
  }

  Future<void> getElectives() async {
    isElectivesError.value ? isElectivesError.toggle() : null;
    isWorking.value ? null : isWorking.toggle();
    update();
    final url =
        "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/$year/SEM1/electives-scheme-${filterController.activeElectiveSchemeCode}.json";
    try {
      final response = await dio.get(url,
          options: Options(
            headers: {
              "accept": "application/vnd.github+json",
              'X-GitHub-Api-Version': '2022-11-28'
            },
            contentType: "application/json",
          ));
      if (response.statusCode != 200) {
        throw DioException(requestOptions: response.requestOptions);
      }
      if (response.data == "") {
        latestElectives = null;
        update();
        return;
      }
      latestElectives = RxMap.from(jsonDecode(response.data));
      isElectivesError = false.obs;

      !isWorking.value ? null : isWorking.toggle();
      update();
      return;
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };
      isElectivesError = true.obs;
      !isWorking.value ? null : isWorking.toggle();
      update();
      throw Exception(e.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      isElectivesError = true.obs;
      !isWorking.value ? null : isWorking.toggle();
      update();
      throw Exception(e.toString());
    }
  }

  Future<void> getElectiveSemesters() async {
    try {
      isElectivesError.value ? isElectivesError.toggle() : null;
      isWorking.value ? null : isWorking.toggle();
      update();
      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      electivesSemesters = RxList.from(data["$year"].keys);
      print("Fetched elective semesters: $electivesSemesters");

      !isWorking.value ? null : isWorking.toggle();
      update();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };
      isElectivesError = true.obs;
      !isWorking.value ? null : isWorking.toggle();
      update();
      return;
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      isElectivesError = true.obs;
      !isWorking.value ? null : isWorking.toggle();
      update();
      return;
    }
  }

  Future<void> getElectiveSchemes() async {
    isElectivesError.value ? isElectivesError.toggle() : null;
    try {
      isWorking.value ? null : isWorking.toggle();
      update();
      FilterController filterController = Get.find();
      String activeSemester = filterController.activeElectiveSemester!;

      final url =
          "https://gitlab.com/delwinn/plan-sync/-/raw/$branch/res/electives.json";

      final response = await dio.get(url);
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      electiveSchemes = RxMap.from(data["$year"][activeSemester]);
      print("Fetched electives schemes: $electiveSchemes");
      !isWorking.value ? null : isWorking.toggle();
      update();
    } on DioException catch (e) {
      errorDetails = {
        "error": "DioException",
        "data": e.message,
        "code": e.response?.statusCode,
      };
      isElectivesError = true.obs;
      !isWorking.value ? null : isWorking.toggle();
      update();
      throw Exception(e.toString());
    } catch (e) {
      errorDetails = {"error": "CatchException"};
      isElectivesError = true.obs;
      !isWorking.value ? null : isWorking.toggle();
      update();
      throw Exception(e.toString());
    }
  }
}
