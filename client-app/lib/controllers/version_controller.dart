import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:plan_sync/util/app_version.dart';
import 'package:plan_sync/util/external_links.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/widgets/popups/popups_wrapper.dart';

class VersionController extends GetxController {
  late PackageInfo packageInfo;

  RxString? _clientVersion;
  String? get clientVersion => _clientVersion?.value;
  set clientVersion(String? newVersion) {
    if (newVersion == null) return;
    _clientVersion = newVersion.obs;
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
    clientVersion = packageInfo.version;
    appBuild = packageInfo.buildNumber;
  }

  void openStore() => ExternalLinks.store();

  /// returns true if an ios update is available,
  /// uses remote config.
  Future<bool> checkIosUpdate() async {
    final latestValue =
        await Get.find<RemoteConfigController>().latestIosVersion();

    if (latestValue == null) {
      // maybe due to internet connectivity
      return false;
    }
    clientVersion ??= (await PackageInfo.fromPlatform()).version;

    final latestVersion = AppVersion(latestValue);
    final currentVersion = AppVersion(clientVersion!);

    Logger.i('Latest Remote App version: ${latestVersion.parts}');
    Logger.i('Current Client App version: ${currentVersion.parts}');

    return latestVersion.isGreaterThan(currentVersion);
  }

  Future<bool> checkForUpdate() async {
    // handle iOS case separately
    if (Platform.isIOS) {
      return await checkIosUpdate();
    }

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
    // not supported in ios, will use remote config to
    // track versions
    if (Platform.isIOS) {
      return;
    }

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
        await InAppUpdate.completeFlexibleUpdate().onError((err, trace) {
          FirebaseCrashlytics.instance.recordError(err, trace);
          PopupsWrapper.showInAppUpateFailedPopup();
          return;
        });
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

  //TODO: verifyMinimumVersion still uses git, migrate
  // to remoteConfig

  /// Verifies if the current app version is less than the
  /// version code mentioned in the remote version file.
  /// This is used to ensure that a minimum app version is maintained
  /// to ensure incompatible apps do not break with live version of
  /// remote data.
  Future<void> verifyMinimumVersion() async {
    final git = Get.find<GitService>();
    final perfs = Get.find<AppPreferencesController>();

    final minVersion = await git.fetchMininumVersion();
    if (minVersion == null || clientVersion == null) {
      Logger.w('min.version from remote retuned null!');
      perfs.saveIsAppBelowMinVersion(false);
      return;
    }

    // check major version
    if (int.parse(clientVersion!.split('.')[0]) <
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
