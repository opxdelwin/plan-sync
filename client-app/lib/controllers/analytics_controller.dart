import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/util/logger.dart';

class AnalyticsController extends GetxController {
  late FirebaseAnalytics _analytics;
  late Auth auth;
  late FilterController filters;

  @override
  void onReady() async {
    super.onReady();
    filters = Get.find();
    auth = Get.find();
    Logger.i("Analytics controller ready");
    _analytics = FirebaseAnalytics.instance;
    await setUserData();
    Future.delayed(const Duration(seconds: 2), () => logOpenApp());
  }

  Future<void> setUserData() async {
    await _analytics.setUserId(id: auth.activeUser?.uid);
    await _analytics.setUserProperty(
      name: "userp_primary_year",
      value: filters.primaryYear ?? "null",
    );
    await _analytics.setUserProperty(
      name: "userp_primary_section",
      value: filters.primarySection ?? "null",
    );
    await _analytics.setUserProperty(
      name: "userp_primary_semester",
      value: filters.primarySemester ?? "null",
    );
    Logger.i("user property reported in analytics.");
  }

  void logOpenApp() async {
    VersionController version = Get.find();
    final parameters = {
      'app_version': version.appVersion ?? "unknown",
      'primary_section': filters.primarySection ?? "null",
      'primary_semester': filters.primarySemester ?? "null",
    };
    try {
      await _analytics.logAppOpen();
      await _analytics.logEvent(
        name: 'app_opened',
        parameters: parameters,
      );
      Logger.i("Logged Analytics");
      Logger.i(parameters);
    } catch (e) {
      Logger.i("Failed logging analytics. \n ${e.toString()}");
    }
  }

  void logShareSheetOpen() async {
    await _analytics.logEvent(name: 'share-bottomsheet-open');
  }

  void logShareViaExternalApps() async {
    await _analytics.logEvent(name: 'share-via-external-apps-open');
  }
}
