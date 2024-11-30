import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesController extends ChangeNotifier {
  late SharedPreferences perfs;

  Future<void> onInit() async {
    perfs = await SharedPreferences.getInstance();
  }

  String? getPrimarySectionPreference() => perfs.getString('primary-section');

  Future<bool> savePrimarySectionPreference(String data) async =>
      await perfs.setString('primary-section', data);

  String? getPrimarySemesterPreference() => perfs.getString('primary-semester');

  Future<bool> savePrimarySemesterPreference(String data) async =>
      await perfs.setString('primary-semester', data);

  String? getPrimaryYearPreference() => perfs.getString('primary-year');

  Future<bool> savePrimaryYearPreference(String data) async =>
      await perfs.setString('primary-year', data);

  // In app tutorial
  /// Returns `true` if tutorial has already been completed.
  bool? getTutorialStatus() => perfs.getBool('app-tutorial-status');

  /// Save tutorial status as `true` if completed.
  Future<bool> saveTutorialStatus(bool status) async =>
      await perfs.setBool('app-tutorial-status', status);

  // elective config
  String? getPrimaryElectiveSchemePreference() =>
      perfs.getString('elective-primary-section');

  Future<bool> savePrimaryElectiveSchemePreference(String data) async =>
      await perfs.setString('elective-primary-section', data);

  String? getPrimaryElectiveSemesterPreference() =>
      perfs.getString('elective-primary-semester');

  Future<bool> savePrimaryElectiveSemesterPreference(String data) async =>
      await perfs.setString('elective-primary-semester', data);

  String? getPrimaryElectiveYearPreference() =>
      perfs.getString('elective-primary-year');

  Future<bool> savePrimaryElectiveYearPreference(String data) async =>
      await perfs.setString('elective-primary-year', data);

  Future<bool> saveIsAppBelowMinVersion(bool status) async =>
      await perfs.setBool('is-app-below-minVersion', status);

  bool isAppBelowMinVersion() =>
      perfs.getBool('is-app-below-minVersion') ?? false;

  // regarding HUD Notices
  static const String _noticesDismissalPerfKey = 'dismissed_notices';

  Future<void> dismissNotice(int noticeId) async {
    Map<String, dynamic> dismissed =
        json.decode(perfs.getString(_noticesDismissalPerfKey) ?? '{}');
    dismissed[noticeId.toString()] = DateTime.now().toIso8601String();
    await perfs.setString(_noticesDismissalPerfKey, json.encode(dismissed));
  }

  bool shouldShowNotice(int noticeId) {
    Map<String, dynamic> dismissed =
        json.decode(perfs.getString(_noticesDismissalPerfKey) ?? '{}');
    return !dismissed.containsKey(noticeId.toString());
  }

  Future<void> cleanupOldNoticeDismissals() async {
    Map<String, dynamic> dismissed =
        json.decode(perfs.getString(_noticesDismissalPerfKey) ?? '{}');

    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    dismissed.removeWhere((key, value) {
      DateTime dismissedDate = DateTime.parse(value);
      return dismissedDate.isBefore(yesterday);
    });

    await perfs.setString(_noticesDismissalPerfKey, json.encode(dismissed));
  }
}
