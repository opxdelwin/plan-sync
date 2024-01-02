import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  }

  printCurrentVersion() {
    Logger.i("App version: v${packageInfo.version}");
    appVersion = "v${packageInfo.version}";
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
      throw Exception("DioException, $e");
    }
  }

  Future<void> triggerPlayUpdate() async {
    final updateAvail = await InAppUpdate.checkForUpdate();

    if (updateAvail.flexibleUpdateAllowed) {
      Logger.i('starting flex upadte');
      await InAppUpdate.startFlexibleUpdate();
      Logger.i('flex update package downloaded');
      await InAppUpdate.completeFlexibleUpdate();
      Logger.i('flex update package installed');
    }
    return;
  }
}
