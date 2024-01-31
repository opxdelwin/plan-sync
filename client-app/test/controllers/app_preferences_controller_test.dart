import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppPreferencesController perfs;

  WidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    Get.put(AppPreferencesController());
    perfs = Get.find();
  });

  test('CRU for section preferences', () {
    // read
    expect(perfs.getPrimarySectionPreference(), null);

    // create
    perfs.savePrimarySectionPreference("B16");
    expect(perfs.getPrimarySectionPreference(), "B16");

    // update
    perfs.savePrimarySectionPreference("A16");
    expect(perfs.getPrimarySectionPreference(), "A16");
  });

  test('CRU for semester preferences', () {
    // read
    expect(perfs.getPrimarySemesterPreference(), null);

    // create
    perfs.savePrimarySemesterPreference("SEM1");
    expect(perfs.getPrimarySemesterPreference(), "SEM1");

    // update
    perfs.savePrimarySemesterPreference("SEM2");
    expect(perfs.getPrimarySemesterPreference(), "SEM2");
  });

  test('CRU for year preferences', () {
    // read
    expect(perfs.getPrimaryYearPreference(), null);

    // create
    perfs.savePrimaryYearPreference("2024");
    expect(perfs.getPrimaryYearPreference(), "2024");

    // update
    perfs.savePrimaryYearPreference("2023");
    expect(perfs.getPrimaryYearPreference(), "2023");
  });

  test('CRU for tutorial status', () {
    // read
    expect(perfs.getTutorialStatus(), null);

    // create
    perfs.saveTutorialStatus(true);
    expect(perfs.getTutorialStatus(), true);

    // update
    perfs.saveTutorialStatus(false);
    expect(perfs.getTutorialStatus(), false);
  });
}
