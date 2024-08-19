import 'package:get/get.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/app_tour_controller.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'mock_controllers/analytics_controller_mock.dart';
import 'mock_controllers/app_preferences_controller_mock.dart';
import 'mock_controllers/app_tour_controller_mock.dart';
import 'mock_controllers/auth_mock.dart';
import 'mock_controllers/filter_controller_mock.dart';
import 'mock_controllers/git_service_mock.dart';
import 'mock_controllers/remote_config_controller_mock.dart';
import 'mock_controllers/version_controller_mock.dart';

void injectMockDependencies() {
  Get.put<Auth>(MockAuth());
  Get.put<AppPreferencesController>(MockAppPreferencesController());
  Get.put<GitService>(MockGitService());
  Get.put<FilterController>(MockFilterController());
  Get.put<VersionController>(MockVersionController());
  Get.put<AnalyticsController>(MockAnalyticsController());
  Get.put<AppTourController>(MockAppTourController());
  Get.put<RemoteConfigController>(MockRemoteConfigController());
}
