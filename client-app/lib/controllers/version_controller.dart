import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    versionCheck();
  }

  versionCheck() {
    Logger.i("App version: v${packageInfo.version}");
    appVersion = "v${packageInfo.version}";
  }

  Future<bool> isUpdateAvailable() async {
    isError = false;
    try {
      final response = await Dio().get(
          "https://api.github.com/repos/opxdelwin/plan-sync/releases/latest",
          options: Options(
            headers: {
              "accept": "application/vnd.github+json",
              'X-GitHub-Api-Version': '2022-11-28'
            },
          ));
      return appVersion == response.data["tag_name"];
    } catch (e) {
      isError = true;
      throw Exception("DioException, $e");
    }
  }
}
