import 'package:get/get.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class FilterController extends GetxController {
  RxString? _activeSection;
  String? get activeSection => _activeSection?.value;
  set activeSection(String? newSection) {
    if (_activeSection?.value == newSection) {
      return;
    }
    if (newSection == null) {
      activeSectionCode = null;
      _activeSection = null;
      return;
    }
    _activeSection = newSection.obs;
    activeSectionCode = newSection;
    update();
  }

  RxString? _activeSectionCode;
  String? get activeSectionCode => _activeSectionCode?.value;
  set activeSectionCode(String? newSectionCode) {
    String? code = service.sections?.keys
        .firstWhereOrNull((key) => service.sections![key] == newSectionCode);
    code != null ? _activeSectionCode = code.obs : _activeSectionCode = null;
    Logger.i('new section code: $code');
    update();
  }

  String? _activeSemester;
  String? get activeSemester => _activeSemester;
  set activeSemester(String? newValue) {
    if (activeSemester == newValue) {
      return;
    }
    _activeSemester = newValue;
    activeSectionCode = null;
    service.getSections();
    update();
  }

  RxString? _activeElectiveSemester;
  String? get activeElectiveSemester => _activeElectiveSemester?.value;
  set activeElectiveSemester(String? newValue) {
    // if (newValue == null) return;
    _activeElectiveSemester = newValue?.obs;
    _activeElectiveScheme = null;
    _activeElectiveSchemeCode = null;
    service.getElectiveSchemes();
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
    activeSection = null;
    final String? primarySection = preferences.getString('primary-section');
    Logger.i("primary section: $primarySection");

    if (primarySection != null &&
        service.sections!.containsKey(primarySection) &&
        service.sections != null) {
      activeSection = service.sections![primarySection];
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
    // activeSemester = null;
    final String? primarySemester = preferences.getString('primary-semester');
    Logger.i("primary semester: $primarySemester");

    if (service.semesters?.contains(primarySemester) != false &&
        primarySemester != null) {
      activeSemester = primarySemester;
    }
  }

  /// returns primary semester from shared-preferences
  String? get primaryYear {
    return preferences.getString('primary-year');
  }

  /// saves the semester code into shared-preferences
  Future<void> storePrimaryYear() async {
    if (service.selectedYear == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a year to be saved as default',
      );
      Logger.i("select a year to be set as primary.");
      return;
    }
    await preferences.setString(
      'primary-year',
      service.selectedYear!.toString(),
    );
    Logger.i("set ${service.selectedYear!} as primary year");
    update();
  }

  /// sets the semester code while runtime
  Future<void> setPrimaryYear() async {
    // activeSemester = null;
    final String? primaryYear = preferences.getString('primary-year');
    Logger.i("primary year: $primaryYear");

    if (service.years?.contains(primaryYear) != false && primaryYear != null) {
      service.selectedYear = int.parse(primaryYear);
    }
  }
}
