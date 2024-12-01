import 'package:flutter/material.dart';
import 'package:plan_sync/backend/supabase_models/branches.dart';
import 'package:plan_sync/backend/supabase_models/programs.dart';
import 'package:plan_sync/backend/supabase_models/section.dart';
import 'package:plan_sync/backend/supabase_models/semesters.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/enums.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

class FilterController extends ChangeNotifier {
  // program selection
  Program? _selectedProgram;
  Program? get selectedProgram => _selectedProgram;
  set selectedProgram(Program? newProgram) {
    if (newProgram == null || selectedProgram == newProgram) {
      return;
    }
    _selectedProgram = newProgram;
    notifyListeners();
  }

  // branch selection
  Branches? _selectedBranch;
  Branches? get selectedBranch => _selectedBranch;
  set selectedBranch(Branches? newBranch) {
    if (selectedBranch == newBranch) {
      return;
    }
    _selectedBranch = newBranch;
    if (_selectedBranch == null) {
      service.semesters = null;
      service.sections = null;
    }
    notifyListeners();
  }

  Section? _activeSection;
  Section? get activeSection => _activeSection;
  set activeSection(Section? newSection) {
    if (_activeSection == newSection) {
      return;
    }

    _activeSection = newSection;
    notifyListeners();
  }

  // String? _activeSectionCode;
  // String? get activeSectionCode => _activeSectionCode;
  // set activeSectionCode(String? newSectionCode) {
  //   String? code = service.sections?
  //       .firstWhereOrNull((key) => service.sections![key] == newSectionCode);
  //   code != null ? _activeSectionCode = code : _activeSectionCode = null;
  //   Logger.i('new section code: $code');
  //   notifyListeners();
  // }

  Semesters? _activeSemester;
  Semesters? get activeSemester => _activeSemester;
  set activeSemester(Semesters? newValue) {
    if (activeSemester == newValue) {
      return;
    }
    _activeSemester = newValue;
    notifyListeners();
  }

  String? _activeElectiveSemester;
  String? get activeElectiveSemester => _activeElectiveSemester;
  set activeElectiveSemester(String? newValue) {
    // if (newValue == null) return;
    _activeElectiveSemester = newValue;
    _activeElectiveScheme = null;
    _activeElectiveSchemeCode = null;
    service.getElectiveSchemes(filterController: this);
    notifyListeners();
  }

  String? _activeElectiveSchemeCode;
  String? get activeElectiveSchemeCode => _activeElectiveSchemeCode;
  set activeElectiveSchemeCode(String? newValue) {
    if (newValue == null) return;
    _activeElectiveSchemeCode = newValue;
    notifyListeners();
  }

  String? _activeElectiveScheme;
  String? get activeElectiveScheme => _activeElectiveScheme;
  set activeElectiveScheme(String? newValue) {
    if (newValue == null) return;
    _activeElectiveScheme = newValue;
    notifyListeners();
  }

  late Weekday _weekday;
  Weekday get weekday => _weekday;
  set weekday(Weekday newWeekday) {
    _weekday = newWeekday;
    notifyListeners();
  }

  late GitService service;
  late AppPreferencesController preferences;

  void onInit(BuildContext context) {
    service = Provider.of<GitService>(context, listen: false);
    preferences = Provider.of<AppPreferencesController>(context, listen: false);
    _weekday = Weekday.today();
  }

  /// Returns a short code for selected noraml schedule configuration
  String getShortCode() {
    Section? section = activeSection;
    Semesters? semester = activeSemester;

    if (section == null && semester == null) {
      return 'Select Sections';
    } else if (section == null && semester != null) {
      return semester.semesterName;
    } else if (semester == null && section != null) {
      return section.sectionName;
    }

    return '${section!.sectionName} | ${semester!.semesterName}'.toUpperCase();
  }

  /// Returns a short code for selected elective configuration
  String getElectiveShortCode() {
    String? section = activeElectiveSchemeCode;
    String? semester = activeElectiveSemester;

    if (section == null && semester == null) {
      return 'Select Elective';
    } else if (section == null && semester != null) {
      return semester;
    } else if (semester == null && section != null) {
      return section;
    }

    return '$section | $semester'.toUpperCase();
  }

  Future<void> setPrimaryProgram() async {
    final String? programPerf = await preferences.getPrimaryProgramPreference();
    Logger.i("primary program: $programPerf");

    if (programPerf == null) {
      return;
    }

    final program = service.programs?.firstWhereOrNull(
      (item) => item.name == programPerf,
    );
    selectedProgram = program;
    notifyListeners();
  }

  /// saves the year into shared-preferences
  Future<void> storePrimaryProgram(BuildContext context) async {
    if (selectedProgram == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a program to be saved as default',
        context,
      );
      Logger.i("select a program to be set as primary.");
      return;
    }
    final res = await preferences.savePrimaryProgramPreference(
      selectedProgram!.name,
    );

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Program wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${selectedProgram!.name} as primary program");
    notifyListeners();
  }

  Future<void> setPrimaryBranch() async {
    final String? branchPerf = await preferences.getPrimaryBranchPreference();
    Logger.i("primary branch: $branchPerf");

    if (branchPerf == null) {
      return;
    }

    final branch = service.branches?.firstWhereOrNull(
      (item) => item.branchName == branchPerf,
    );
    selectedBranch = branch;
    notifyListeners();
  }

  /// saves the year into shared-preferences
  Future<void> storePrimaryBranch(BuildContext context) async {
    if (selectedBranch == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a branch to be saved as default',
        context,
      );
      Logger.i("select a branch to be set as primary.");
      return;
    }
    final res = await preferences.savePrimaryBranchPreference(
      selectedBranch!.branchName,
    );

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Branch wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${selectedBranch!.branchName} as primary branch");
    notifyListeners();
  }

  /// returns primary section from shared-preferences
  String? get primarySection => preferences.getPrimarySectionPreference();

  /// saves the section code into shared-preferences
  Future<void> storePrimarySection(BuildContext context) async {
    if (activeSection == null) {
      Logger.i("select a section to set as primary.");
      CustomSnackbar.error('Not Selected',
          'Please select a section to be saved as default', context);
      return;
    }

    final res = await preferences.savePrimarySectionPreference(
      activeSection!.sectionName,
    );

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Section wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${activeSection!.sectionName} as primary");
    notifyListeners();
  }

  /// sets the section code while runtime
  Future<void> setPrimarySection() async {
    activeSection = null;
    final String? primarySection = preferences.getPrimarySectionPreference();
    Logger.i("primary section: $primarySection");

    if (primarySection != null) {
      activeSection = service.sections?.firstWhereOrNull(
        (item) => item.sectionName == primarySection,
      );
    }
    notifyListeners();
  }

  /// returns primary semester from shared-preferences
  String? get primarySemester => preferences.getPrimarySemesterPreference();

  /// saves the semester code into shared-preferences
  Future<void> storePrimarySemester(BuildContext context) async {
    if (activeSemester == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a semester to be saved as default',
        context,
      );
      Logger.i("select a semester to be set as primary.");
      return;
    }
    final res = await preferences
        .savePrimarySemesterPreference(activeSemester!.semesterName);

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Semester wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${activeSemester!.semesterName} as primary semester");
    notifyListeners();
  }

  /// sets the semester code while runtime
  void setPrimarySemester(BuildContext context) {
    // activeSemester = null;
    final String? primarySemester = preferences.getPrimarySemesterPreference();
    Logger.i("primary semester: $primarySemester");

    activeSemester = service.semesters?.firstWhereOrNull(
      (item) => item.semesterName == primarySemester,
    );
    service.getSections(context);
  }

  /// returns primary semester from shared-preferences
  String? get primaryYear => preferences.getPrimaryYearPreference();

  /// saves the year into shared-preferences
  Future<void> storePrimaryYear(BuildContext context) async {
    if (service.selectedYear == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a year to be saved as default',
        context,
      );
      Logger.i("select a year to be set as primary.");
      return;
    }
    final res = await preferences.savePrimaryYearPreference(
      service.selectedYear!.toString(),
    );

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Year wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${service.selectedYear!} as primary year");
    notifyListeners();
  }

  /// sets the semester code while runtime
  Future<void> setPrimaryYear() async {
    // activeSemester = null;
    final String? primaryYear = preferences.getPrimaryYearPreference();
    Logger.i("primary year: $primaryYear");

    if (service.years?.any((item) => item.year == primaryYear) != false &&
        primaryYear != null) {
      service.selectedYear = primaryYear;
    }
  }

  String? get primaryElectiveScheme =>
      preferences.getPrimaryElectiveSchemePreference();

  /// saves the section code into shared-preferences
  Future<void> storePrimaryElectiveScheme(BuildContext context) async {
    if (activeElectiveSchemeCode == null) {
      Logger.i("select a section to set as primary.");
      CustomSnackbar.error(
        'Not Selected',
        'Please select a section to be saved as default',
        context,
      );
      return Future.error('error');
    }

    final res = await preferences
        .savePrimaryElectiveSchemePreference(activeElectiveSchemeCode!);

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Section wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${activeElectiveSchemeCode!} as primary");
    notifyListeners();
  }

  /// sets the section code while runtime
  Future<void> setPrimaryElectiveScheme() async {
    activeElectiveScheme = null;
    Logger.i("primary elective scheme: $primaryElectiveScheme");

    if (primaryElectiveScheme != null &&
        service.electiveSchemes!.containsKey(primaryElectiveScheme) &&
        service.electiveSchemes != null) {
      activeElectiveScheme = service.electiveSchemes![primaryElectiveScheme];
      activeElectiveSchemeCode = primaryElectiveScheme;
    }
  }

  String? get primaryElectiveSemester =>
      preferences.getPrimaryElectiveSemesterPreference();

  /// saves the semester code into shared-preferences
  Future<void> storePrimaryElectiveSemester(BuildContext context) async {
    if (activeElectiveSemester == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a semester to be saved as default',
        context,
      );
      Logger.i("select a semester to be set as primary.");
      return Future.error('error');
    }
    final res = await preferences
        .savePrimaryElectiveSemesterPreference(activeElectiveSemester!);

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Semester wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${activeElectiveSemester!} as primary elective-semester");
    notifyListeners();
  }

  /// sets the semester code while runtime
  Future<void> setPrimaryElectiveSemester() async {
    Logger.i("primary semester: $primaryElectiveSemester");

    if (service.electivesSemesters?.contains(primaryElectiveSemester) !=
            false &&
        primaryElectiveSemester != null) {
      activeElectiveSemester = primaryElectiveSemester;
    }
  }

  String? get primaryElectiveYear =>
      preferences.getPrimaryElectiveYearPreference();

  /// saves the elective year into shared-preferences
  Future<void> storePrimaryElectiveYear(BuildContext context) async {
    if (service.selectedElectiveYear == null) {
      CustomSnackbar.error(
        'Not Selected',
        'Please select a year to be saved as default',
        context,
      );
      Logger.i("select a year to be set as primary.");
      return Future.error('error');
    }
    final res = await preferences.savePrimaryElectiveYearPreference(
      service.selectedElectiveYear!.toString(),
    );

    if (res == false) {
      Logger.i("Could not save preference");
      CustomSnackbar.error(
        'Error',
        'Primary Year wasn\'t saved. Try again',
        context,
      );
      return;
    }

    Logger.i("set ${service.selectedElectiveYear!} as primary year");
    notifyListeners();
  }

  /// sets the semester code while runtime
  Future<void> setPrimaryElectiveYear() async {
    Logger.i("primary elective year: $primaryElectiveYear");

    if (service.electiveYears?.contains(primaryElectiveYear) != false &&
        primaryElectiveYear != null) {
      service.selectedElectiveYear = primaryElectiveYear!;
    }
  }
}
