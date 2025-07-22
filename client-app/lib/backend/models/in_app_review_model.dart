import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:provider/provider.dart';

class InAppReviewCacheModel {
  int? lastRequested;
  int firstOpen;
  String? lastAppVersion;

  InAppReviewCacheModel({
    this.lastRequested,
    required this.firstOpen,
    this.lastAppVersion,
  });

  factory InAppReviewCacheModel.fromJson(Map<String, dynamic> json) {
    return InAppReviewCacheModel(
      lastRequested: json['lastRequested'] as int?,
      firstOpen: json['firstOpen'] as int,
      lastAppVersion: json['lastAppVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastRequested': lastRequested,
      'firstOpen': firstOpen,
      'lastAppVersion': lastAppVersion,
    };
  }

  Future<bool> shouldRequestReview(BuildContext context) async {
    final now = DateTime.now();
    DateTime firstOpenDate = DateTime.fromMillisecondsSinceEpoch(
      firstOpen,
    );
    final versionController = Provider.of<VersionController>(
      context,
      listen: false,
    );
    final currentAppVersion = versionController.clientVersion;

    // If app version has changed (major update), allow prompt again
    if (lastAppVersion != null && lastAppVersion != currentAppVersion) {
      // Reset lastRequested so prompt can show again after update
      lastRequested = null;
      firstOpen = DateTime.now().millisecondsSinceEpoch;
    }

    // If never requested before
    if (lastRequested == null) {
      // Only request if it's been at least 7 days since first open
      if (now.difference(firstOpenDate).inDays >= 7) {
        await updateLastRequested(context);
        return true;
      }
      return false;
    }

    // If already requested before, only request every 30 days
    DateTime lastRequestedDate =
        DateTime.fromMillisecondsSinceEpoch(lastRequested!);
    if (now.difference(lastRequestedDate).inDays >= 30) {
      await updateLastRequested(context);
      return true;
    }
    return false;
  }

  Future<void> updateLastRequested(BuildContext context) async {
    final versionController =
        Provider.of<VersionController>(context, listen: false);
    final currentAppVersion = versionController.clientVersion;
    lastRequested = DateTime.now().millisecondsSinceEpoch;
    lastAppVersion = currentAppVersion;
    Provider.of<AppPreferencesController>(
      context,
      listen: false,
    ).saveAppReviewRequest(this);
  }
}
