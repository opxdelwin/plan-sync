class ScheduleEntry {
  final String? subject;
  final String? room;
  final String? time;
  final DateTime? startTime;
  final DateTime? endTime;

  ScheduleEntry({
    this.subject,
    this.room,
    this.time,
    this.startTime,
    this.endTime,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    ScheduleEntry entry = ScheduleEntry(
      subject: json['subject'],
      room: json['room'],
      time: json['time'],
    );
    final span = entry.time?.split('-');

    DateTime? endtime;
    DateTime? starttime;

    if (span != null && span.length == 2) {
      final now = DateTime.now();
      starttime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(span[0].split(':')[0]),
        int.parse(
          span[0].split(':')[1],
        ),
      );
      endtime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(span[1].split(':')[0]),
        int.parse(span[1].split(':')[1]),
      );
    }
    final newEntry = ScheduleEntry(
      subject: entry.subject,
      room: entry.room,
      time: entry.time,
      startTime: starttime,
      endTime: endtime,
    );
    return newEntry;
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'room': room,
      'time': time,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ScheduleEntry(subject: $subject, room: $room, time: $time'
        ', startTime: $startTime, endTime: $endTime)';
  }
}
