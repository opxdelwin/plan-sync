import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';

import 'app_preferences_controller_mock.dart';
import 'git_service_mock.dart';

class MockFilterController extends GetxController
    with Mock
    implements FilterController {
  @override
  final preferences =
      Get.find<AppPreferencesController>() as MockAppPreferencesController;
  @override
  final service = Get.find<GitService>() as MockGitService;

  RxString? _activeSectionCode;
  @override
  set activeSectionCode(String? newSectionCode) {
    newSectionCode != null
        ? _activeSectionCode = newSectionCode.obs
        : _activeSectionCode = null;
    update();
  }

  @override
  String? get activeSectionCode => _activeSectionCode?.value;

  RxString? _activeElectiveScheme;
  @override
  set activeElectiveScheme(String? newValue) {
    if (newValue == null) {
      _activeElectiveScheme = null;
      update();
      return;
    }
    _activeElectiveScheme = newValue.obs;
    update();
    return;
  }

  @override
  String? get activeElectiveScheme => _activeElectiveScheme?.value;

  RxString? _activeElectiveSemester;

  @override
  set activeElectiveSemester(String? newValue) {
    if (newValue == null) {
      _activeElectiveSemester = null;
      update();
      return;
    }
    _activeElectiveSemester = newValue.obs;
    update();
    return;
  }

  @override
  String? get activeElectiveSemester => _activeElectiveSemester?.value;

  RxString? _activeSection;
  @override
  set activeSection(String? newSection) {
    if (newSection == null) {
      _activeSection = null;
      update();
      return;
    }
    _activeSection = newSection.obs;
    update();
    return;
  }

  @override
  String? get activeSection => _activeSection?.value;

  RxString? _activeSemester;
  @override
  set activeSemester(String? newValue) {
    if (activeSemester == newValue) {
      return;
    }
    _activeSemester = newValue?.obs;
    update();
  }

  @override
  String? get activeSemester => _activeSemester?.value;

  @override
  Future<String> getShortCode() async {
    String? section = activeSectionCode;
    String? semester = activeSemester;

    if (section == null && semester == null) {
      return 'Select Sections';
    } else if (section == null && semester != null) {
      return semester;
    } else if (semester == null && section != null) {
      return section;
    }

    return '$section | $semester'.toUpperCase();
  }

  @override
  Future<void> storePrimarySection() async {
    if (activeSectionCode == null) {
      return;
    }

    final res =
        await preferences.savePrimarySectionPreference(activeSectionCode!);

    if (res == false) {
      return Future.error('Couldnt save');
    }

    update();
  }

  @override
  Future<void> storePrimarySemester() async {
    if (activeSemester == null) {
      return;
    }
    final res =
        await preferences.savePrimarySemesterPreference(activeSemester!);

    if (res == false) {
      return Future.error('Couldnt save');
    }

    update();
  }

  @override
  Future<void> storePrimaryYear() async {
    if (service.selectedYear == null) {
      return;
    }
    final res = await preferences.savePrimaryYearPreference(
      service.selectedYear!.toString(),
    );

    if (res == false) {
      return Future.error('Couldnt save');
    }

    update();
  }
}
