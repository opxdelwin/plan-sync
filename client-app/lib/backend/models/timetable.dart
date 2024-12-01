import 'package:plan_sync/backend/models/timetable_meta.dart';
import 'package:plan_sync/backend/models/timetable_schedule_entry.dart';
import 'dart:convert';

import 'package:plan_sync/backend/supabase_models/student_schedule.dart';
import 'package:plan_sync/util/extensions.dart';

class Timetable {
  final TimetableMeta meta;
  final Map<String, List<ScheduleEntry>> data;
  final bool isFresh;

  Timetable({
    required this.meta,
    required this.data,
    this.isFresh = true,
  });

  //TODO: (fixme) This should no longer be used.
  // migrate after electives are migrated to supabase
  factory Timetable.fromJson({
    required Map json,
    bool isFresh = true,
  }) {
    return Timetable(
      isFresh: isFresh,
      meta: TimetableMeta(),
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

  factory Timetable.fromStudentScheduleModel({
    required List<StudentSchedule> scheduleList,
    bool isFresh = true,
  }) {
    //TODO: Figure out a way to add existing
    // metadata to the timetable, as supabase
    // isn't configured with the metadata.

    return scheduleList.toTimetable(isFresh: isFresh);
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
}
