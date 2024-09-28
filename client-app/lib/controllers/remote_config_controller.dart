import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:plan_sync/backend/models/remote_config/hud_notices_model.dart';
import 'package:plan_sync/util/logger.dart';

class RemoteConfigController extends GetxController {
  final remoteConfig = FirebaseRemoteConfig.instance;

  @override
  Future<void> onReady() async {
    super.onReady();
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: const Duration(minutes: kReleaseMode ? 60 : 1),
      ),
    );
    await remoteConfig.setDefaults({
      'hud_notice': '[]',
      'latest_ios_version': '',
    });

    // Probable solution for an internal error by remote_config
    // see https://github.com/firebase/flutterfire/issues/6196#issuecomment-927751667
    try {
      await remoteConfig.activate();
      await Future.delayed(const Duration(seconds: 1));
      await remoteConfig.fetchAndActivate();
    } catch (exception, stack) {
      FirebaseCrashlytics.instance.recordError(exception, stack);
      Logger.w("Error activating remoteConfig.");
    }
  }

  /// fetches all configs from firebase, and makes models only
  /// for notices shown in-app
  Future<List<HudNoticeModel>> getNotices() async {
    final val = remoteConfig.getString('hud_notice');

    // data comes as a string
    if (val == '[]') {
      Logger.i('No HUD notices');
      return [];
    }

    List<HudNoticeModel> result = [];
    List data = jsonDecode(val) ?? [];

    for (Map instance in data) {
      result.add(HudNoticeModel.fromMap(instance));
    }

    return result;
  }

  /// get latest ios version from remoteConfig
  Future<String?> latestIosVersion() async {
    final value = remoteConfig.getString('latest_ios_version');
    return value == '' ? null : value;
  }
}
