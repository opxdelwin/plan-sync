import 'package:plan_sync/backend/models/timetable_meta.dart';
import 'package:plan_sync/backend/models/timetable_schedule_entry.dart';
import 'dart:convert';

class Timetable {
  final TimetableMeta meta;
  final Map<String, List<ScheduleEntry>> data;

  Timetable({required this.meta, required this.data});

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
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
      'data': data.map((key, value) =>
          MapEntry(key, value.map((entry) => entry.toJson()).toList())),
    };
  }

  static Timetable parse(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return Timetable.fromJson(jsonMap);
  }
}
