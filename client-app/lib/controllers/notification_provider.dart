import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// // TODO(delwin) : remove or use as required
// void onDidReceiveNotificationResponse(
//     NotificationResponse notificationResponse) async {
//   final String? payload = notificationResponse.payload;
//   if (notificationResponse.payload != null) {
//     debugPrint('notification payload: $payload');
//   }
//   await Navigator.push(
//     context,
//     MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
//   );
// }

class NotificationProvider extends ChangeNotifier {
  // AndroidFlutterNotificationsPlugin.requestExactAlarmsPermission()

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AndroidInitializationSettings initializationSettingsAndroid;
  late DarwinInitializationSettings initializationSettingsDarwin;

  late InitializationSettings initializationSettings;

  void init() async {
    initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    initializationSettingsDarwin = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> checkPermissions() async {
    bool? granted;
    debugPrint('Checking notification permissions...');
    if (Platform.isAndroid) {
      granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      debugPrint('Android notification permission status: $granted');
    } else if (Platform.isIOS) {
      granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint('iOS notification permission status: $granted');
    }

    if (granted == null || !granted) {
      debugPrint('Requesting notification permissions...');
      await requestPermissions();
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
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
  }

  Future<bool> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    return true;
  }

  Future<bool> createReminder({
    required String subject,
    required String time,
    required String classroom,
  }) async {
    await checkPermissions();

    tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local);
    if (scheduledDate.isBefore(DateTime.now())) {
      scheduledDate = scheduledDate.add(const Duration(seconds: 15));
    }

    List<String> timeRange = time.split(" - ");

    const title = "Class Reminder";
    final body =
        "$subject from ${timeRange[0].trim()} to ${timeRange[1].trim()} in $classroom";

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.microsecondsSinceEpoch % 1000000,
      title,
      body,
      scheduledDate,
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'reminders'),
        iOS: DarwinNotificationDetails(),
      ),
    );
    return true;
  }
}
