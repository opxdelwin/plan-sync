import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

enum MockGitServiceStages {
  /// success request
  success,

  /// raises no internet exception
  noInternet,

  /// sets updating to `true`
  scheduleUpdating,

  /// No section is selected
  noneSelected,
}

class MockGitService extends GetxController with Mock implements GitService {
  MockGitServiceStages stage = MockGitServiceStages.success;

  RxInt? _selectedElectiveYear;
  @override
  int? get selectedElectiveYear => _selectedElectiveYear?.value;
  @override
  set selectedElectiveYear(int? newYear) {
    if (newYear == null || selectedElectiveYear == newYear) {
      return;
    }
    _selectedElectiveYear = newYear.obs;
    update();
    return;
  }

  RxList<String>? _electiveYears = ["2024", "2023", "2022"].obs;
  @override
  set electiveYears(List<String>? newElectiveYears) {
    if (newElectiveYears == null) {
      _electiveYears = null;
      update();
      return;
    }
    _electiveYears = newElectiveYears.obs;
    update();
    return;
  }

  @override
  List<String>? get electiveYears => _electiveYears?.value;

  RxMap? _electivesSchemes;
  @override
  set electiveSchemes(RxMap? newElectiveSchemes) {
    if (newElectiveSchemes == null) {
      _electivesSchemes = null;
      update();
      return;
    }
    _electivesSchemes = newElectiveSchemes;
    update();
    return;
  }

  @override
  RxMap? get electiveSchemes => _electivesSchemes;

  RxList? _electivesSemesters = ["SEM1", "SEM2"].obs;
  @override
  set electivesSemesters(List? newElectivesSemesters) {
    if (newElectivesSemesters == null) {
      _electivesSemesters = null;
      update();
      return;
    }
    _electivesSemesters = newElectivesSemesters.obs;
    update();
    return;
  }

  @override
  List? get electivesSemesters => _electivesSemesters;

  RxMap? _sections;
  set sections(Map? newvalue) {
    if (newvalue == null) {
      _sections = null;
      update();
      return;
    }
    _sections = newvalue.obs;
    update();
    return;
  }

  @override
  RxMap<dynamic, dynamic>? get sections => _sections;

  RxList? _semesters = ["SEM1", "SEM2"].obs;

  @override
  set semesters(List? newSemesters) {
    if (newSemesters == null) {
      _semesters = null;
      update();
      return;
    }
    _semesters = newSemesters.obs;
    update();
  }

  @override
  List? get semesters => _semesters?.value;

  RxInt? _selectedYear;
  @override
  set selectedYear(int? newYear) {
    if (newYear == null) {
      return;
    }
    _selectedYear = newYear.obs;
    update();
  }

  @override
  int? get selectedYear => _selectedYear?.value;

  @override
  List<String>? get years => ["2024", "2023", "2022"];

  @override
  Future<Map<String, dynamic>?> getTimeTable() async {
    bool isTimetableUpdating = false;

    if (stage == MockGitServiceStages.scheduleUpdating) {
      isTimetableUpdating = true;
    }

    if (stage == MockGitServiceStages.noInternet) {
      return Future.error(
        DioException.connectionError(
            requestOptions: RequestOptions(), reason: 'No Internet'),
      );
    }

    if (stage == MockGitServiceStages.noneSelected) {
      return null;
    }

    return {
      "meta": {
        "section": "b16",
        "type": "norm-class",
        "revision": "Revision 1.02",
        "effective-date": "Jan 15, 2024",
        "contributor": "PlanSync Admin :)",
        "isTimetableUpdating": isTimetableUpdating,
        "room": {
          "monday": 301,
          "tuesday": 306,
          "wednesday": 404,
          "thursday": 402,
          "friday": 403
        }
      },
      "data": {
        "monday": {
          "08:00 - 09:00": "Electives",
          "09:00 - 09:20": "***",
          "09:20 - 10:20": "EVS",
          "10:20 - 11:20": "Physics",
          "11:20 - 13:20": "T & NM.",
          "13:20 - 14:20": "Sc LS."
        },
        "tuesday": {
          "08:00 - 09:00": "Electives",
          "09:00 - 09:20": "***",
          "09:20 - 10:20": "Physics",
          "10:20 - 11:00": "***",
          "11:00 - 14:00": "PL(T) & Programming Lab"
        },
        "wednesday": {
          "08:00 - 09:00": "Electives",
          "09:00 - 10:00": "***",
          "10:00 - 12:00": "Physics Lab",
          "12:00 - 12:20": "***",
          "12:20 - 13:20": "T & NM.",
          "13:20 - 14:20": "EVS"
        },
        "thursday": {
          "08:00 - 09:00": "Electives",
          "09:00 - 10:00": "***",
          "10:00 - 12:00": "ED & Graphics",
          "12:00 - 12:20": "***",
          "12:20 - 13:20": "T & NM.",
          "13:20 - 14:20": "Physics"
        },
        "friday": {
          "08:00 - 09:00": "Electives",
          "09:00 - 09:20": "***",
          "09:20 - 10:20": "Sc LS.",
          "10:20 - 11:00": "***",
          "11:00 - 14:00": "PL(T) & Programming Lab"
        }
      }
    };
  }

  @override
  Future<Map<String, dynamic>?> getElectives() async {
    return {
      "meta": {
        "type": "electives",
        "revision": "Revision 1.01",
        "effective-date": "Jan 15, 2024",
        "name": "Electives Configuration for Scheme A",
        "isTimetableUpdating": false
      },
      "data": {
        "monday": {
          "EM01": "Room 102",
          "EM02": "Room 103",
          "EM03": "Room 104",
          "CIE01": "Room 105",
          "CIE02": "Room CLA2",
          "CIE03": "Room CLA3",
          "CIE04": "Room CLA4",
          "EM07": "Room C-18",
          "EM08": "Room C-19",
          "CIE07": "Room C-13",
          "CIE08": "Room C-20",
          "CIE09": "Room C-14",
          "SST03": "Room CLA5",
          "EM10": "Room CLA6",
          "EM11": "Room CLA19",
          "EM12": "Room CLA3",
          "CIE12": "Room CL4",
          "CIE13": "Room CL16",
          "CIE14": "Room E105"
        },
        "tuesday": {"***": "***"},
        "wednesday": {
          "SST01": "Room C-23",
          "EM03": "Room C-18",
          "EM04": "Room C-19",
          "CIE01": "Room 103",
          "CIE02": "Room 104",
          "CIE05": "Room CR-1",
          "CIE06": "Room CR-2",
          "SST02": "Room C-15",
          "EM05": "Room C-13",
          "EM06": "Room C-14",
          "EM08": "Room CLA3",
          "CIE09": "Room CLA4",
          "CIE10": "Room 105",
          "CIE11": "Room CLA2",
          "EM09": "Room CLA2",
          "EM10": "Room CLA3",
          "EM11": "Room CLA4",
          "CIE12": "Room CLA5",
          "CIE15": "Room CLA6",
          "CIE16": "Room CLA19"
        },
        "thursday": {"***": "***"},
        "friday": {
          "SST01": "Room CLA4",
          "EM01": "Room 103",
          "EM02": "Room 104",
          "EM04": "Room 105",
          "CIE03": "Room CR-1",
          "CIE04": "Room CR-2",
          "CIE05": "Room CLA5",
          "CIE06": "Room CLA6",
          "SST02": "Room C-13",
          "EM05": "Room C-14",
          "EM06": "Room C-12",
          "EM07": "Room C-15",
          "CIE07": "Room C-16",
          "CIE08": "Room CLA19",
          "CIE10": "Room CL3",
          "CIE11": "Room CL4",
          "SST03": "Room C-20",
          "EM09": "Room C-21",
          "EM12": "Room CLA19",
          "CIE13": "Room CL3",
          "CIE14": "Room CL4",
          "CIE15": "Room CL16",
          "CIE16": "Room E105"
        }
      }
    };
  }
}
