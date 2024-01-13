import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesController extends GetxController {
  late SharedPreferences perfs;

  @override
  Future<void> onInit() async {
    perfs = await SharedPreferences.getInstance();
    super.onInit();
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
}
