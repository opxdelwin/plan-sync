class ScheduleEntry {
  final String? subject;
  final String? room;
  final String? time;

  ScheduleEntry({
    this.subject,
    this.room,
    this.time,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      subject: json['subject'],
      room: json['room'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'room': room,
      'time': time,
    };
  }
}
