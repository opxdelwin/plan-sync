import 'package:plan_sync/util/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundAppPreferences {
  late SharedPreferences _prefs;

  /// Initializes the SharedPreferences instance. Must be called before
  /// attempting to retrieve any preferences.
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    Logger.i('BackgroundAppPreferences: SharedPreferences initialized.');
  }

  /// Retrieves the saved primary year preference.
  String? getPrimaryYearPreference() {
    final year = _prefs.getString('primary-year');
    Logger.i('BackgroundAppPreferences: Fetched primary-year: $year');
    return year;
  }

  /// Retrieves the saved primary semester preference.
  String? getPrimarySemesterPreference() {
    final semester = _prefs.getString('primary-semester');
    Logger.i('BackgroundAppPreferences: Fetched primary-semester: $semester');
    return semester;
  }

  /// Retrieves the saved primary section preference.
  String? getPrimarySectionPreference() {
    final section = _prefs.getString('primary-section');
    Logger.i('BackgroundAppPreferences: Fetched primary-section: $section');
    return section;
  }
}
