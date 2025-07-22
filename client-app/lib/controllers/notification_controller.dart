import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/util/snackbar.dart';

class NotificationController extends ChangeNotifier {
  // Store initial route from notification when app launches from terminated state
  static String? initialNotificationRoute;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;

    // Check current permission status
    final settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      if (!context.mounted) {
        CustomSnackbar.error(
          'Notification Permission Disabled',
          'Unable to request permission, restart app and try again.',
          context,
        );
        return;
      }

      // Show dialog before requesting permission
      final shouldRequest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'Notifications will be sent for class alerts. Would you like to enable notifications?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      if (shouldRequest == true) {
        if (Platform.isAndroid) {
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
        } else if (Platform.isIOS) {
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );
        }

        final InitializationSettings initializationSettings =
            InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
        await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        );
      }
    }

    print('FCM Token: ${await _messaging.getToken()}');

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(message.notification!.title ?? 'Notification'),
            content: Text(message.notification!.body ?? ''),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _handleNotificationTap(context, message);
                },
                child: const Text('Open'),
              ),
            ],
          ),
        );
      }
    });

    FirebaseMessaging.instance.subscribeToTopic('core_notifications').then(
          (e) => log('Subscribed to core_notifications'),
        );

    log('Setting up foreground message handler');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message recieved: ${message.messageId}');
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'Default channel for notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });

    // Background & terminated state handler
    log('Setting up background launch handler');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!context.mounted) return;

      log('Message clicked!');
      _handleNotificationTap(context, message);
    });

    // Background message handler (must be a top-level function)
    log('Setting up background message handler');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleNotificationTap(BuildContext context, RemoteMessage message) {
    // Parse message and navigate to route
    final route = message.data['route'];
    if (route != null) {
      context.go(route);
    }
  }
}

void onDidReceiveNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null) {
    // Navigate to specific route based on payload
    log('Notification tapped with payload: $payload');
    // Store the route for use after context is available
    NotificationController.initialNotificationRoute = response.data['route'];
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
