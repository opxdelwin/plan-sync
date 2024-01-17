import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAppPreferencesController extends GetxController
    with Mock
    implements AppPreferencesController {
  Future<bool> resetPreferencesToNull() async {
    final res = await perfs.clear();
    return res;
  }

  @override
  late SharedPreferences perfs;

  @override
  Future<void> onInit() async {
    perfs = await SharedPreferences.getInstance();
    super.onInit();
  }

  @override
  String? getPrimarySectionPreference() => perfs.getString('primary-section');

  @override
  Future<bool> savePrimarySectionPreference(String data) async =>
      await perfs.setString('primary-section', data);

  @override
  String? getPrimarySemesterPreference() => perfs.getString('primary-semester');

  @override
  Future<bool> savePrimarySemesterPreference(String data) async =>
      await perfs.setString('primary-semester', data);

  @override
  String? getPrimaryYearPreference() => perfs.getString('primary-year');

  @override
  Future<bool> savePrimaryYearPreference(String data) async =>
      await perfs.setString('primary-year', data);

  // In app tutorial
  /// Returns `true` if tutorial has already been completed.
  @override
  bool? getTutorialStatus() => perfs.getBool('app-tutorial-status');

  /// Save tutorial status as `true` if completed.
  @override
  Future<bool> saveTutorialStatus(bool status) async =>
      await perfs.setBool('app-tutorial-status', status);
}
