import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/backend/models/timetable_schedule_entry.dart';
import 'package:plan_sync/backend/services/background_app_preferences_service.dart';
import 'package:plan_sync/backend/services/background_git_service.dart';
import 'package:plan_sync/backend/services/native_widgets/native_widget_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:workmanager/workmanager.dart';

Future<void> getSchedule() async {
  // Hardcoded date for testing - DO NOT CHANGE
  final DateTime now = DateTime(2025, 7, 29, 11, 5, 14);

  final BackgroundAppPreferences appPreferencesController =
      BackgroundAppPreferences();
  await appPreferencesController.onInit();

  final year = appPreferencesController.getPrimaryYearPreference();
  final semester = appPreferencesController.getPrimarySemesterPreference();
  final section = appPreferencesController.getPrimarySectionPreference();

  // Check initial preferences and set "open app to configure" if any are missing
  if (year == null ||
      year.isEmpty ||
      semester == null ||
      semester.isEmpty ||
      section == null ||
      section.isEmpty) {
    Logger.w(
      "[NativeWidget] Preferences missing. "
      "Showing 'open app to configure'.",
    );
    await NativeWidgetService.setUnconfigured();
    return;
  }
  Logger.i(
    "[NativeWidget] Preferences: Year=$year, "
    "Semester=$semester, Section=$section",
  );

  // Show loading state initially
  await NativeWidgetService.setLoadingState();

  final BackgroundGitService gitService = BackgroundGitService();
  await gitService.init();
  Timetable? timetable;
  try {
    timetable = await gitService.pullTimetable(
      sectionCode: section,
      semester: semester,
      year: year,
    );
  } catch (e, stack) {
    Logger.e("[NativeWidget] Error fetching timetable: $e\n$stack");
    await NativeWidgetService.setUnconfigured();
    rethrow;
  }

  // If timetable is null after fetch (e.g., no data for the combination)
  if (timetable == null) {
    Logger.w(
      "[NativeWidget] Timetable is null after fetch. "
      "Showing 'no classes today'.",
    );
    await NativeWidgetService.noClassesToday();
    return;
  }

  // Get current and next classes based on the hardcoded `now`
  final ScheduleEntry? currentClass = timetable.getCurrentClass();
  final ScheduleEntry? nextClass = timetable.getNextClass();

  DateTime? nextUpdateTargetTime;

  if (currentClass != null || nextClass != null) {
    Logger.i(
      "[NativeWidget] Current class: ${currentClass?.subject ?? 'None'},"
      " Next class: ${nextClass?.subject ?? 'None'}",
    );

    // Case: Current & Next Class Available OR Current Available
    // & Next Null OR Current Null & Next Available
    // In all these "data" scenarios, we display content and
    // schedule based on the next relevant time.
    await NativeWidgetService.setClasses(
      currentClass: currentClass,
      nextClass: nextClass,
    );

    // Determine the next update time
    if (currentClass != null && currentClass.endTime != null) {
      String dat = jsonDecode(
          await HomeWidget.getWidgetData<String>('scheduleData') ??
              '{}')['widgetState'];

      if (dat == "unconfigured" || dat == "loading") {
        nextUpdateTargetTime = now;
        Logger.i(
          "[NativeWidget] Scheduling immediate update as widget is not configured.",
        );
      } else {
        // If there's a current class, schedule update for 1 minute after its end
        nextUpdateTargetTime =
            currentClass.endTime!.add(const Duration(minutes: 1));
        Logger.i(
          "[NativeWidget] Scheduling update after current "
          "class ends at: $nextUpdateTargetTime",
        );
      }
    } else if (nextClass != null && nextClass.startTime != null) {
      // If no current class but there's a next class, schedule
      // update 5 minutes before it starts
      nextUpdateTargetTime = nextClass.startTime!.subtract(
        const Duration(minutes: 5),
      );
      Logger.i(
        "[NativeWidget] Scheduling update 5 min before "
        "next class starts at: $nextUpdateTargetTime",
      );
    } else {
      // This case should ideally not be reached if currentClass || nextClass is true,
      // but as a fallback, schedule for start of next day if some data was displayed.
      Logger.w(
        "[NativeWidget] No clear next update point, "
        "scheduling for next day's 7 AM.",
      );
      final nextDay = now.add(const Duration(days: 1));
      nextUpdateTargetTime =
          DateTime(nextDay.year, nextDay.month, nextDay.day, 7, 0, 0);
    }
  } else {
    // Case: Both unavailable for the day (no current and no next for today)
    Logger.i("[NativeWidget] No classes found for today. Showing empty state.");
    await NativeWidgetService.noClassesToday();

    // Schedule next update for 7:00 AM next day
    final nextDay = now.add(const Duration(days: 1));
    nextUpdateTargetTime =
        DateTime(nextDay.year, nextDay.month, nextDay.day, 7, 0, 0);
    Logger.i(
      "[NativeWidget] Scheduling next update for "
      "7:00 AM next day: $nextUpdateTargetTime",
    );
  }

  // Schedule Workmanager task if a target time was determined
  final Duration initialDelay = nextUpdateTargetTime.difference(now);
  if (initialDelay.isNegative) {
    Logger.w(
      "[NativeWidget] Initial delay is negative, scheduling "
      "for immediate update or next day's 7 AM.",
    );

    nextUpdateTargetTime = now.add(const Duration(minutes: 1));
    if (initialDelay.inHours < -1) {
      final nextDay = now.add(const Duration(days: 1));
      nextUpdateTargetTime =
          DateTime(nextDay.year, nextDay.month, nextDay.day, 7, 0, 0);
    }
    Logger.i(
      "[NativeWidget] Adjusted next update "
      "target time: $nextUpdateTargetTime",
    );
  }

  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    await Workmanager().cancelAll();
    await Workmanager().registerOneOffTask(
      "getSchedule-${DateTime.now().millisecondsSinceEpoch}",
      "getSchedule",
      initialDelay: nextUpdateTargetTime.difference(now),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    Logger.i(
      "[NativeWidget] Workmanager task 'getSchedule' "
      "registered with delay: ${nextUpdateTargetTime.difference(now)}",
    );
  } catch (e) {
    Logger.e("[NativeWidget] Error scheduling Workmanager task: $e");
  }
}
