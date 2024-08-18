import 'package:get/get.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';

class HudNoticeModel {
  final int id;
  final String title;
  final String description;

  const HudNoticeModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory HudNoticeModel.fromMap(Map data) => HudNoticeModel(
        id: data['id'],
        title: data['title'],
        description: data['description'],
      );

  // helper functions
  bool shouldShow() {
    return Get.find<AppPreferencesController>().shouldShowNotice(id);
  }

  Future<void> dismissNotice() async {
    return await Get.find<AppPreferencesController>().dismissNotice(id);
  }
}
