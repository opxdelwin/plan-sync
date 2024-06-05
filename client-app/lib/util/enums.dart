enum Weekday {
  sunday(weekdayIndex: 0, key: 'sunday'),
  monday(weekdayIndex: 1, key: 'monday'),
  tuesday(weekdayIndex: 2, key: 'tuesday'),
  wednesday(weekdayIndex: 3, key: 'wednesday'),
  thursday(weekdayIndex: 4, key: 'thursday'),
  friday(weekdayIndex: 5, key: 'friday'),
  saturday(weekdayIndex: 6, key: 'saturday');

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
