import 'package:get/get.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/util/logger.dart';

import 'auth_mock.dart';
import 'filter_controller_mock.dart';

class MockAnalyticsController extends GetxController
    with Mock
    implements AnalyticsController {
  @override
  Auth auth = MockAuth();

  @override
  FilterController filters = MockFilterController();

  @override
  void logOpenApp() {
    Logger.i('mocking logOpenApp');
  }

  @override
  Future<void> setUserData() async {
    Logger.i('mocking logOpenApp');
  }
}
