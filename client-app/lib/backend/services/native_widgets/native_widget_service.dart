import 'dart:convert';
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:plan_sync/backend/models/timetable_schedule_entry.dart';

class NativeWidgetService {
  static Future<void> _initializeWidget() async {
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId("group.in.plansync.widget");
    }
  }

  static Future<void> _updateWidget() async {
    await HomeWidget.updateWidget(
      name: 'ScheduleWidget',
      iOSName: 'com.plansync.widget',
      androidName: 'ScheduleWidget',
    );
  }

  static Future<void> setUnconfigured() async {
    await _initializeWidget();

    final widgetData = {
      'widgetState': 'unconfigured',
    };

    await HomeWidget.saveWidgetData<String>(
      'scheduleData',
      jsonEncode(widgetData),
    );

    await _updateWidget();
  }

  static Future<void> noClassesToday() async {
    await _initializeWidget();

    final widgetData = {
      'widgetState': 'empty',
    };

    await HomeWidget.saveWidgetData<String>(
      'scheduleData',
      jsonEncode(widgetData),
    );

    await _updateWidget();
  }

  static Future<void> setClasses({
    ScheduleEntry? currentClass,
    ScheduleEntry? nextClass,
  }) async {
    await _initializeWidget();

    // Create the data structure that matches your Android widget expectations
    final widgetData = <String, dynamic>{
      'widgetState': 'data',
    };

    // Add current subject data if available
    if (currentClass != null) {
      widgetData['currentSubject'] = {
        'name': currentClass.subject ?? 'N/A',
        'room': currentClass.room ?? 'N/A',
        'time': _formatTimeRange(currentClass),
      };
    }

    // Add next subject data if available
    if (nextClass != null) {
      widgetData['nextSubject'] = {
        'name': nextClass.subject ?? 'N/A',
        'room': nextClass.room ?? 'N/A',
        'time': _formatTimeRange(nextClass),
      };
    }

    // Save as single JSON object with 'scheduleData' key
    await HomeWidget.saveWidgetData<String>(
      'scheduleData',
      jsonEncode(widgetData),
    );

    await _updateWidget();
  }

  static Future<void> setLoadingState() async {
    await _initializeWidget();

    final widgetData = {
      'widgetState': 'loading',
    };

    await HomeWidget.saveWidgetData<String>(
      'scheduleData',
      jsonEncode(widgetData),
    );

    await _updateWidget();
  }

  static String _formatTimeRange(ScheduleEntry entry) {
    if (entry.startTime == null || entry.endTime == null) {
      return 'Time N/A';
    }

    final startTime = _formatTime(entry.startTime!);
    final endTime = _formatTime(entry.endTime!);
    return '$startTime - $endTime';
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
