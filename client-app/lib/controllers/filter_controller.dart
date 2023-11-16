import 'package:get/get.dart';
import 'package:plan_sync/controllers/git_service.dart';
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
  onReady() async {
    super.onReady();
    preferences = await SharedPreferences.getInstance();
    service = Get.find();
  }

  String? get primarySection {
    return preferences.getString('primary-section');
  }

  Future<void> storePrimarySection() async {
    if (activeSectionCode == null) {
      //TODO:popup
      print("select a section to set as primary.");
      return;
    }
    await preferences.setString('primary-section', activeSectionCode!);
    print("set ${activeSectionCode!} as primary");
    update();
  }

  Future<void> setPrimarySection() async {
    final String? primarySection = preferences.getString('primary-section');
    print("primary section: $primarySection");

    if (primarySection != null &&
        service.sections!.containsKey(primarySection) &&
        service.sections != null) {
      activeSectionCode = service.sections![primarySection];
    }
  }

  String? get primarySemester {
    return preferences.getString('primary-semester');
  }

  Future<void> storePrimarySemester() async {
    if (activeSemester == null) {
      //TODO:popup
      print("select a semester to be set as primary.");
      return;
    }
    await preferences.setString('primary-semester', activeSemester!);
    print("set ${activeSemester!} as primary semester");
    update();
  }

  Future<void> setPrimarySemester() async {
    final String? primarySection = preferences.getString('primary-semester');
    print("primary semester: $primarySection");

    activeSemester = primarySemester;
  }
}
