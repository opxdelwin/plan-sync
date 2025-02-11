import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/analytics_controller.dart';
import 'package:plan_sync/controllers/app_tour_controller.dart';
import 'package:plan_sync/controllers/app_preferences_controller.dart';
import 'package:plan_sync/controllers/auth.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/controllers/remote_config_controller.dart';
import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:provider/provider.dart';
import 'package:plan_sync/controllers/notification_provider.dart';

class AppInitializer {
  static Future<void> initializeApp(BuildContext context) async {
    try {
      // First initialize sync operations
      Provider.of<Auth>(context, listen: false).onInit();
      await Provider.of<GitService>(context, listen: false).onInit();
      Provider.of<AppTourController>(context, listen: false).onInit(context);
      Provider.of<FilterController>(context, listen: false).onInit(context);
      Provider.of<AppPreferencesController>(context, listen: false).onInit();
      Provider.of<AppThemeController>(context, listen: false).onInit();
      Provider.of<NotificationProvider>(context, listen: false).init();

      // Then handle async operations
      Future.wait([
        Provider.of<VersionController>(context, listen: false).onReady(context),
        Provider.of<GitService>(context, listen: false).onReady(context),
        Provider.of<RemoteConfigController>(context, listen: false).onReady(),
      ]);

      // Handle operations that depend on other initializations
      final auth = Provider.of<Auth>(context, listen: false);
      final analytics =
          Provider.of<AnalyticsController>(context, listen: false);
      await analytics.onReady(context);
      auth.addUserStatusListener(() => analytics.setUserData());
    } catch (e, stackTrace) {
      if (kReleaseMode) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
      rethrow;
    }
  }
}
