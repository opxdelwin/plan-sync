class StudentSchedule {
  int? id;
  DateTime createdAt;
  String branch;
  String program;
  String academicYear;
  String? subject;
  String startTime;
  String endTime;
  String? classroom;
  String semester;
  String day;
  String authority;
  String? section;

  StudentSchedule({
    this.id,
    required this.createdAt,
    required this.branch,
    required this.program,
    required this.academicYear,
    this.subject,
    required this.startTime,
    required this.endTime,
    this.classroom,
    required this.semester,
    required this.day,
    required this.authority,
    this.section,
  });

  factory StudentSchedule.fromJson(Map<String, dynamic> json) {
    return StudentSchedule(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      branch: json['branch'],
      program: json['program'],
      academicYear: json['academic_year'],
      subject: json['subject'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      classroom: json['classroom'],
      semester: json['semester'],
      day: json['day'],
      authority: json['authority'],
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'branch': branch,
      'program': program,
      'academic_year': academicYear,
      'subject': subject,
      'start_time': startTime,
      'end_time': endTime,
      'classroom': classroom,
      'semester': semester,
      'day': day,
      'authority': authority,
      'section': section,
    };
  }

  @override
  String toString() {
    return 'StudentSchedule{id: $id, createdAt: $createdAt, branch: $branch, program: $program, academicYear: $academicYear, subject: $subject, startTime: $startTime, endTime: $endTime, classroom: $classroom, semester: $semester, day: $day, authority: $authority, section: $section}';
  }
}
