import 'package:plan_sync/backend/models/timetable_meta.dart';
import 'package:plan_sync/backend/models/timetable_schedule_entry.dart';
import 'package:plan_sync/util/enums.dart';
import 'dart:convert';

import 'package:plan_sync/util/logger.dart';

class Timetable {
  final TimetableMeta meta;
  final Map<String, List<ScheduleEntry>> data;
  final bool isFresh;

  Timetable({
    required this.meta,
    required this.data,
    this.isFresh = true,
  });

  factory Timetable.fromJson({
    required Map<String, dynamic> json,
    bool isFresh = true,
  }) {
    return Timetable(
      isFresh: isFresh,
      meta: TimetableMeta.fromJson(json['meta']),
      data: (json['data'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((e) => ScheduleEntry.fromJson(e))
              .toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.map((key, value) => MapEntry(
            key,
            value.map((entry) => entry.toJson()).toList(),
          )),
    };
  }

  static Timetable parse(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return Timetable.fromJson(json: jsonMap);
  }

  ScheduleEntry? getCurrentClass() {
    // final now = DateTime.now();
    final now = DateTime(2025, 7, 29, 11, 31, 0);
    final today = Weekday.fromIndex(now.weekday).name;
    final entries = data[today];
    if (entries == null) return null;

    for (final entry in entries) {
      if (entry.startTime == null || entry.endTime == null) {
        Logger.e("[Timetable] Invalid entry time: $entry");
        continue;
      }

      if (entry.startTime!.isBefore(now) && entry.endTime!.isAfter(now)) {
        Logger.w("[Timetable] Current class found: $entry");
        return entry;
      }
    }
    return null;
  }

  ScheduleEntry? getNextClass() {
    // final now = DateTime.now();
    final now = DateTime(2025, 7, 29, 11, 31, 0);
    final today = Weekday.fromIndex(now.weekday).name;
    final entries = data[today];

    if (entries == null || entries.isEmpty) {
      Logger.i("[Timetable] No entries found for $today");
      return null;
    }

    ScheduleEntry? nextClass;

    for (final entry in entries) {
      // Skip entries with invalid start time
      if (entry.startTime == null) {
        Logger.e("[Timetable] Invalid entry start time: $entry");
        continue;
      }

      // Skip classes that have already started or ended
      if (entry.startTime!.isBefore(now) ||
          entry.startTime!.isAtSameMomentAs(now)) {
        continue;
      }

      // Find the earliest upcoming class
      if (nextClass == null ||
          entry.startTime!.isBefore(nextClass.startTime!)) {
        nextClass = entry;
      }
    }

    if (nextClass != null) {
      Logger.i("[Timetable] Next class found: ${nextClass.toString()}");
    } else {
      Logger.i("[Timetable] No upcoming classes found for today");
    }

    return nextClass;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
