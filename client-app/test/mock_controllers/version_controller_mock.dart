import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/controllers/version_controller.dart';

class MockVersionController extends GetxController
    with Mock
    implements VersionController {
  bool updateResult = true;

  @override
  Future<bool> checkForUpdate() async {
    return updateResult;
  }
}
