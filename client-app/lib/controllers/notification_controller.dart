import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationController extends ChangeNotifier {
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
      if (message.notification != null) {
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

    print('Setting up foreground message handler');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.messageId}');
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.notification!.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(),
          payload: message.data['route'],
        );
      }
      print('Received message: ${message.messageId}');
    });

    // Background & terminated state handler
    print('Setting up background message handler');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      _handleNotificationTap(context, message);
    });

    // Background message handler (must be a top-level function)
    print('Setting up background message handler');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleNotificationTap(BuildContext context, RemoteMessage message) {
    // Parse message and navigate to route
    final route = message.data['route'];
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification response
    print('Notification tapped: ${response.id}');
    final payload = response.payload;
    if (payload != null) {
      // Navigate to specific route based on payload
      print('Notification tapped with payload: $payload');
    }
  }
}

// Static instance for background handler
final FlutterLocalNotificationsPlugin
    _backgroundFlutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final AndroidInitializationSettings _backgroundInitializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');
final DarwinInitializationSettings _backgroundInitializationSettingsDarwin =
    DarwinInitializationSettings();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize plugin for background
  final InitializationSettings initializationSettings = InitializationSettings(
    android: _backgroundInitializationSettingsAndroid,
    iOS: _backgroundInitializationSettingsDarwin,
  );
  await _backgroundFlutterLocalNotificationsPlugin
      .initialize(initializationSettings);

  // Show local notification
  final notification = message.notification;
  if (notification != null) {
    await _backgroundFlutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ?? 'Notification',
      notification.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'background_channel',
          'Background Notifications',
          channelDescription: 'Notifications shown when app is in background',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['route'],
    );
  }
  print('Handling a background message: ${message.messageId}');
}
