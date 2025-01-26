import 'package:flutter/material.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_action_model.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:provider/provider.dart';

class HudNoticeModel {
  final int id;
  final String title;
  final String description;
  final ActionModel? action;

  const HudNoticeModel({
    required this.id,
    required this.title,
    required this.description,
    this.action,
  });

  factory HudNoticeModel.fromMap(Map data) => HudNoticeModel(
        id: data['id'],
        title: data['title'],
        description: data['description'],

        // include this only if data contains action
        action: data['action'] != null
            ? ActionModel.fromJson(data['action'])
            : null,
      );

  // helper functions
  bool shouldShow(BuildContext context) {
    return Provider.of<AppPreferencesController>(context, listen: false)
        .shouldShowNotice(id);
  }

  Future<void> dismissNotice(BuildContext context) async {
    return await Provider.of<AppPreferencesController>(context, listen: false)
        .dismissNotice(id);
  }
}
