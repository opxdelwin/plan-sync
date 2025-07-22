import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:plan_sync/controllers/notification_controller.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream() {
    notifyListeners();

    log('GoRouterRefreshStream getting initial message');
    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        // Handle navigation, e.g.:
        final route = initialMessage.data['route'];
        NotificationController.initialNotificationRoute = route;
        log('Route from initial message: $route');
        notifyListeners();
      }
    });

    FirebaseAuth.instance.authStateChanges().listen((event) {
      notifyListeners();
    });
  }
}
