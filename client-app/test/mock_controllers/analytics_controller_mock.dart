import 'package:get/get.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:mockito/mockito.dart';

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
    print('mocking logOpenApp');
  }

  @override
  Future<void> setUserData() async {
    print('mocking logOpenApp');
  }
}
