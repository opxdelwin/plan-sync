enum Weekday {
  sunday(weekdayIndex: 0, key: 'SUNDAY'),
  monday(weekdayIndex: 1, key: 'MONDAY'),
  tuesday(weekdayIndex: 2, key: 'TUESDAY'),
  wednesday(weekdayIndex: 3, key: 'WEDNESDAY'),
  thursday(weekdayIndex: 4, key: 'THURSDAY'),
  friday(weekdayIndex: 5, key: 'FRIDAY'),
  saturday(weekdayIndex: 6, key: 'SATURDAY');

  final int weekdayIndex;
  final String key;

  const Weekday({
    required this.weekdayIndex,
    required this.key,
  });

  factory Weekday.today() {
    final datetimeWeekday =
        DateTime.now().weekday == 7 ? 0 : DateTime.now().weekday;
    return Weekday.values.firstWhere(
      (weekday) => weekday.weekdayIndex == datetimeWeekday,
    );
  }

  factory Weekday.fromIndex(int index) {
    return Weekday.values.firstWhere(
      (weekday) => weekday.weekdayIndex == index,
    );
  }
}

// for login page only
enum LoginProvider { google, apple }

// to identify type of schedule
enum ScheduleType {
  regular(displayName: 'Regular Schedule'),
  electives(displayName: 'Elective Schedule');

  final String displayName;

  const ScheduleType({
    required this.displayName,
  });
}
