import 'package:plan_sync/backend/models/timetable.dart';
import 'package:plan_sync/backend/models/timetable_meta.dart';
import 'package:plan_sync/backend/models/timetable_schedule_entry.dart';
import 'package:plan_sync/backend/supabase_models/student_schedule.dart';

extension PSString on String {
  String capitalizeFirst() => this[0].toUpperCase() + substring(1);
}

extension PSList on List<StudentSchedule> {
  Timetable toTimetable({bool isFresh = true}) {
    final distinctDays = map((e) => e.day).toSet();
    Map<String, List<ScheduleEntry>> data = {};

    for (var day in distinctDays) {
      data[day] = where((e) => e.day == day)
          .map(
            (e) => ScheduleEntry(
              subject: e.subject,
              room: e.classroom,
              // substring(0, 5) to remove the seconds from the time
              time:
                  "${e.startTime.substring(0, 5)} - ${e.endTime.substring(0, 5)}",
            ),
          )
          .toList();
    }

    return Timetable(
      // TODO: (fixme) Figure out a way to add metadata
      meta: TimetableMeta(type: 'norm-class'),
      isFresh: isFresh,
      data: data,
    );
  }
}
