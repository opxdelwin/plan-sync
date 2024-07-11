import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/logger.dart';

class VersionController extends GetxController {
  late PackageInfo packageInfo;

  RxString? _appVersion;
  String? get appVersion => _appVersion?.value;
  set appVersion(String? newVersion) {
    if (newVersion == null) return;
    _appVersion = newVersion.obs;
    update();
  }

  RxString? _appBuild;
  String? get appBuild => _appBuild?.value;
  set appBuild(String? newVersion) {
    if (newVersion == null) return;
    _appBuild = newVersion.obs;
    update();
  }

  RxBool _isError = false.obs;
  bool get isError => _isError.value;
  set isError(bool newValue) {
    _isError = newValue.obs;
    update();
  }

  @override
  void onReady() async {
    super.onReady();
    packageInfo = await PackageInfo.fromPlatform();
    printCurrentVersion();
    triggerPlayUpdate();
    verifyMinimumVersion();
  }

  printCurrentVersion() {
    Logger.i("App version: v${packageInfo.version}");
    appVersion = packageInfo.version;
    appBuild = packageInfo.buildNumber;
  }

  void openStore() => ExternalLinks.store();

  Future<bool> checkForUpdate() async {
    isError = false;
    try {
      final AppUpdateInfo result = await InAppUpdate.checkForUpdate();
      return result.updateAvailability == UpdateAvailability.updateAvailable;
    } catch (e) {
      isError = true;
      throw Exception("VersionController.checkForUpdate Exception, $e");
    }
  }

  Future<void> triggerPlayUpdate() async {
    final updateAvail = await InAppUpdate.checkForUpdate();

    if (updateAvail.immediateUpdateAllowed &&
        immediateUpdateCondition(updateAvail)) {
      Logger.i('starting immediate upadte');
      await InAppUpdate.performImmediateUpdate();
      Logger.i('flex update package installed');
    } else if (updateAvail.flexibleUpdateAllowed) {
      Logger.i('starting flex upadte');
      AppUpdateResult appUpdateResult = await InAppUpdate.startFlexibleUpdate();
      Logger.i('flex update package downloaded');

      if (appUpdateResult == AppUpdateResult.success) {
        await InAppUpdate.completeFlexibleUpdate();
        Logger.i('flex update package installed');
      }
    }
    return;
  }

  // wanted to use updateAvail.updatePriority but it's API has been
  // stale for over 4 years. using updateAvail.availableVersionCode
  // and performing immediate update if difference in current buildNumber
  // and incoming buildNumber is greater than 5
  bool immediateUpdateCondition(AppUpdateInfo info) {
    int difference =
        info.availableVersionCode! - int.parse(packageInfo.buildNumber);

    return difference > 5;
  }

  /// Verifies if the current app version is less than the
  /// version code mentioned in the remote version file.
  /// This is used to ensure that a minimum app version is maintained
  /// to ensure incompatible apps do not break with live version of
  /// remote data.
  Future<void> verifyMinimumVersion() async {
    final git = Get.find<GitService>();
    final perfs = Get.find<AppPreferencesController>();

    final minVersion = await git.fetchMininumVersion();
    if (minVersion == null || appVersion == null) {
      Logger.w('min.version from remote retuned null!');
      perfs.saveIsAppBelowMinVersion(false);
      return;
    }

    // check major version
    if (int.parse(appVersion!.split('.')[0]) <
        int.parse(minVersion.split('.')[0])) {
      Logger.e('Current App Version is unsupported with database!');
      perfs.saveIsAppBelowMinVersion(true);
      Get.context?.go('/forced_update');
      return;
    }

    perfs.saveIsAppBelowMinVersion(false);
    return;
  }
}
