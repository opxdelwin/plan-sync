import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';

class MockRemoteConfigController extends GetxController
    with Mock
    implements RemoteConfigController {
  /// fetches all configs from firebase, and makes models only
  /// for notices shown in-app
  @override
  Future<List<HudNoticeModel>> getNotices() async {
    return [];
  }
}
