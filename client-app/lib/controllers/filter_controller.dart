import 'package:get/get.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterController extends GetxController {
  RxString? _activeSection;
  String? get activeSection => _activeSection?.value;
  set activeSection(String? newSection) {
    if (newSection == null || _activeSection?.value == newSection) {
      return;
    }
    _activeSection = newSection.obs;
    activeSectionCode = newSection;
    update();
  }

  RxString? _activeSectionCode;
  String? get activeSectionCode => _activeSectionCode?.value;
  set activeSectionCode(String? newSectionCode) {
    String code = service.sections?.keys
        .firstWhere((key) => service.sections![key] == newSectionCode);
    _activeSectionCode = code.obs;
    activeSection = service.sections?[code];

    update();
  }

  String? _activeSemester;
  String? get activeSemester => _activeSemester;
  set activeSemester(String? newValue) {
    if (newValue == null) return;
    _activeSemester = newValue;
    service.getSections();
    update();
  }

  RxString? _activeElectiveSemester;
  String? get activeElectiveSemester => _activeElectiveSemester?.value;
  set activeElectiveSemester(String? newValue) {
    if (newValue == null) return;
    _activeElectiveSemester = newValue.obs;
    update();
  }

  String? _activeElectiveSchemeCode;
  String? get activeElectiveSchemeCode => _activeElectiveSchemeCode;
  set activeElectiveSchemeCode(String? newValue) {
    if (newValue == null) return;
    _activeElectiveSchemeCode = newValue;
    update();
  }

  String? _activeElectiveScheme;
  String? get activeElectiveScheme => _activeElectiveScheme;
  set activeElectiveScheme(String? newValue) {
    if (newValue == null) return;
    _activeElectiveScheme = newValue;
    update();
  }

  late GitService service;
  late SharedPreferences preferences;

  @override
  onInit() async {
    super.onInit();
    preferences = await SharedPreferences.getInstance();
    service = Get.find();
  }

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

  /// returns primary section from shared-preferences
  String? get primarySection {
    return preferences.getString('primary-section');
  }

  /// saves the section code into shared-preferences
  Future<void> storePrimarySection() async {
    if (activeSectionCode == null) {
      Logger.i("select a section to set as primary.");
      CustomSnackbar.error(
        'Not Selected',
        'Please select a section to be saved as default',
      );
      return;
    }

    await preferences.setString('primary-section', activeSectionCode!);
    Logger.i("set ${activeSectionCode!} as primary");
    update();
  }

  /// sets the section code while runtime
  Future<void> setPrimarySection() async {
    final String? primarySection = preferences.getString('primary-section');
    Logger.i("primary section: $primarySection");

    if (primarySection != null &&
        service.sections!.containsKey(primarySection) &&
        service.sections != null) {
      activeSectionCode = service.sections![primarySection];
    }
  }

  /// returns primary semester from shared-preferences
  String? get primarySemester {
    return preferences.getString('primary-semester');
  }

  /// saves the semester code into shared-preferences
  Future<void> storePrimarySemester() async {
    if (activeSemester == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a semester to be saved as default',
      );
      Logger.i("select a semester to be set as primary.");
      return;
    }
    await preferences.setString('primary-semester', activeSemester!);
    Logger.i("set ${activeSemester!} as primary semester");
    update();
  }

  /// sets the semester code while runtime
  Future<void> setPrimarySemester() async {
    final String? primarySection = preferences.getString('primary-semester');
    Logger.i("primary semester: $primarySection");

    activeSemester = primarySemester;
  }
}
