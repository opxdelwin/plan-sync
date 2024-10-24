import 'package:dio/dio.dart';
import 'package:plan_sync/backend/models/timetable.dart';
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

  @override
  Future<void> onReady() async {}

  RxString? _selectedElectiveYear;
  @override
  String? get selectedElectiveYear => _selectedElectiveYear?.value;
  @override
  set selectedElectiveYear(String? newYear) {
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
  // ignore: invalid_use_of_protected_member
  List<String>? get electiveYears => _electiveYears?.value;

  RxMap? _electivesSchemes = {
    "a": "Sch. A (BTECH-CSE)",
    "b": "Sch. B (BTECH-CSE)",
  }.obs;

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
  // ignore: invalid_use_of_protected_member
  List? get semesters => _semesters?.value;

  RxString? _selectedYear;
  @override
  set selectedYear(String? newYear) {
    if (newYear == null) {
      return;
    }
    _selectedYear = newYear.obs;
    update();
  }

  @override
  String? get selectedYear => _selectedYear?.value;

  @override
  List<String>? get years => ["2024", "2023", "2022"];

  @override
  Stream<Timetable?> getTimeTable() async* {
    bool isTimetableUpdating = false;

    if (stage == MockGitServiceStages.scheduleUpdating) {
      isTimetableUpdating = true;
    }

    if (stage == MockGitServiceStages.noInternet) {
      yield* Stream.error(
        DioException.connectionError(
            requestOptions: RequestOptions(), reason: 'No Internet'),
      );
    }

    if (stage == MockGitServiceStages.noneSelected) {
      yield* const Stream.empty();
      return;
    }

    yield Timetable.fromJson(json: {
      "meta": {
        "section": "b16",
        "type": "norm-class",
        "revision": "Revision 1.03",
        "effective-date": "Jan 15, 2024 (Satrudays' valid till Apr 13)",
        "contributor": "PlanSync Admin :)",
        "isTimetableUpdating": isTimetableUpdating
      },
      "data": {
        "monday": [
          {"time": "08:00 - 09:00", "subject": "Electives", "room": "301"},
          {"time": "09:00 - 09:20", "subject": "***", "room": "301"},
          {"time": "09:20 - 10:20", "subject": "EVS", "room": "301"},
          {"time": "10:20 - 11:20", "subject": "Physics", "room": "301"},
          {"time": "11:20 - 13:20", "subject": "T & NM.", "room": "301"},
          {"time": "13:20 - 14:20", "subject": "Sc LS.", "room": "301"}
        ],
        "tuesday": [
          {"time": "08:00 - 09:00", "subject": "Electives", "room": "306"},
          {"time": "09:00 - 09:20", "subject": "***", "room": "306"},
          {"time": "09:20 - 10:20", "subject": "Physics", "room": "306"},
          {"time": "10:20 - 11:00", "subject": "***", "room": "306"},
          {
            "time": "11:00 - 14:00",
            "subject": "PL(T) & Programming Lab",
            "room": "306"
          }
        ],
        "wednesday": [
          {"time": "08:00 - 09:00", "subject": "Electives", "room": "404"},
          {"time": "09:00 - 10:00", "subject": "***", "room": "404"},
          {"time": "10:00 - 12:00", "subject": "Physics Lab", "room": "404"},
          {"time": "12:00 - 12:20", "subject": "***", "room": "404"},
          {"time": "12:20 - 13:20", "subject": "T & NM.", "room": "404"},
          {"time": "13:20 - 14:20", "subject": "EVS", "room": "404"}
        ],
        "thursday": [
          {"time": "08:00 - 09:00", "subject": "Electives", "room": "402"},
          {"time": "09:00 - 10:00", "subject": "***", "room": "402"},
          {"time": "10:00 - 12:00", "subject": "ED & Graphics", "room": "402"},
          {"time": "12:00 - 12:20", "subject": "***", "room": "402"},
          {"time": "12:20 - 13:20", "subject": "T & NM.", "room": "402"},
          {"time": "13:20 - 14:20", "subject": "Physics", "room": "402"}
        ],
        "friday": [
          {"time": "08:00 - 09:00", "subject": "Electives", "room": "403"},
          {"time": "09:00 - 09:20", "subject": "***", "room": "403"},
          {"time": "09:20 - 10:20", "subject": "Sc LS.", "room": "403"},
          {"time": "10:20 - 11:00", "subject": "***", "room": "403"},
          {
            "time": "11:00 - 14:00",
            "subject": "PL(T) & Programming Lab",
            "room": "403"
          }
        ],
        "saturday": [
          {"time": "08:00 - 09:00", "subject": "Electives", "room": "301"},
          {"time": "09:00 - 09:20", "subject": "***", "room": "301"},
          {"time": "09:20 - 10:20", "subject": "EVS", "room": "301"},
          {"time": "10:20 - 11:20", "subject": "Physics", "room": "301"},
          {"time": "11:20 - 13:20", "subject": "T & NM.", "room": "301"},
          {"time": "13:20 - 14:20", "subject": "Sc LS.", "room": "301"}
        ]
      }
    });
  }

  @override
  Stream<Timetable?> getElectives() async* {
    yield Timetable.fromJson(json: {
      "meta": {
        "type": "electives",
        "revision": "Revision 1.01",
        "effective-date": "Jan 15, 2024\n(Satrudays' valid till Apr 13)",
        "name": "Electives Configuration for Scheme A",
        "isTimetableUpdating": false
      },
      "data": {
        "monday": [
          {"subject": "EM01", "room": "Room 102"},
          {"subject": "EM02", "room": "Room 103"},
          {"subject": "EM03", "room": "Room 104"},
          {"subject": "CIE01", "room": "Room 105"},
          {"subject": "CIE02", "room": "Room CLA2"},
          {"subject": "CIE03", "room": "Room CLA3"},
          {"subject": "CIE04", "room": "Room CLA4"},
          {"subject": "EM07", "room": "Room C-18"},
          {"subject": "EM08", "room": "Room C-19"},
          {"subject": "CIE07", "room": "Room C-13"},
          {"subject": "CIE08", "room": "Room C-20"},
          {"subject": "CIE09", "room": "Room C-14"},
          {"subject": "SST03", "room": "Room CLA5"},
          {"subject": "EM10", "room": "Room CLA6"},
          {"subject": "EM11", "room": "Room CLA19"},
          {"subject": "EM12", "room": "Room CLA3"},
          {"subject": "CIE12", "room": "Room CL4"},
          {"subject": "CIE13", "room": "Room CL16"},
          {"subject": "CIE14", "room": "Room E105"}
        ],
        "tuesday": [
          {"subject": "***", "room": "***"}
        ],
        "wednesday": [
          {"subject": "SST01", "room": "Room C-23"},
          {"subject": "EM03", "room": "Room C-18"},
          {"subject": "EM04", "room": "Room C-19"},
          {"subject": "CIE01", "room": "Room 103"},
          {"subject": "CIE02", "room": "Room 104"},
          {"subject": "CIE05", "room": "Room CR-1"},
          {"subject": "CIE06", "room": "Room CR-2"},
          {"subject": "SST02", "room": "Room C-15"},
          {"subject": "EM05", "room": "Room C-13"},
          {"subject": "EM06", "room": "Room C-14"},
          {"subject": "EM08", "room": "Room CLA3"},
          {"subject": "CIE09", "room": "Room CLA4"},
          {"subject": "CIE10", "room": "Room 105"},
          {"subject": "CIE11", "room": "Room CLA2"},
          {"subject": "EM09", "room": "Room CLA2"},
          {"subject": "EM10", "room": "Room CLA3"},
          {"subject": "EM11", "room": "Room CLA4"},
          {"subject": "CIE12", "room": "Room CLA5"},
          {"subject": "CIE15", "room": "Room CLA6"},
          {"subject": "CIE16", "room": "Room CLA19"}
        ],
        "thursday": [
          {"subject": "***", "room": "***"}
        ],
        "friday": [
          {"subject": "SST01", "room": "Room CLA4"},
          {"subject": "EM01", "room": "Room 103"},
          {"subject": "EM02", "room": "Room 104"},
          {"subject": "EM04", "room": "Room 105"},
          {"subject": "CIE03", "room": "Room CR-1"},
          {"subject": "CIE04", "room": "Room CR-2"},
          {"subject": "CIE05", "room": "Room CLA5"},
          {"subject": "CIE06", "room": "Room CLA6"},
          {"subject": "SST02", "room": "Room C-13"},
          {"subject": "EM05", "room": "Room C-14"},
          {"subject": "EM06", "room": "Room C-12"},
          {"subject": "EM07", "room": "Room C-15"},
          {"subject": "CIE07", "room": "Room C-16"},
          {"subject": "CIE08", "room": "Room CLA19"},
          {"subject": "CIE10", "room": "Room CL3"},
          {"subject": "CIE11", "room": "Room CL4"},
          {"subject": "SST03", "room": "Room C-20"},
          {"subject": "EM09", "room": "Room C-21"},
          {"subject": "EM12", "room": "Room CLA19"},
          {"subject": "CIE13", "room": "Room CL3"},
          {"subject": "CIE14", "room": "Room CL4"},
          {"subject": "CIE15", "room": "Room CL16"},
          {"subject": "CIE16", "room": "Room E105"}
        ],
        "saturday": [
          {"subject": "EM01", "room": "Room 102"},
          {"subject": "EM02", "room": "Room 103"},
          {"subject": "EM03", "room": "Room 104"},
          {"subject": "CIE01", "room": "Room 105"},
          {"subject": "CIE02", "room": "Room CLA2"},
          {"subject": "CIE03", "room": "Room CLA3"},
          {"subject": "CIE04", "room": "Room CLA4"},
          {"subject": "EM07", "room": "Room C-18"},
          {"subject": "EM08", "room": "Room C-19"},
          {"subject": "CIE07", "room": "Room C-13"},
          {"subject": "CIE08", "room": "Room C-20"},
          {"subject": "CIE09", "room": "Room C-14"},
          {"subject": "SST03", "room": "Room CLA5"},
          {"subject": "EM10", "room": "Room CLA6"},
          {"subject": "EM11", "room": "Room CLA19"},
          {"subject": "EM12", "room": "Room CLA3"},
          {"subject": "CIE12", "room": "Room CL4"},
          {"subject": "CIE13", "room": "Room CL16"},
          {"subject": "CIE14", "room": "Room E105"}
        ]
      }
    });
  }
}
