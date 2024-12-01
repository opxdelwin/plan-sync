class Semesters {
  int? id;
  DateTime createdAt;
  String semesterName;
  String branchName;
  String programName;
  String academicYear;
  String authority;

  Semesters({
    this.id,
    required this.createdAt,
    required this.semesterName,
    required this.branchName,
    required this.programName,
    required this.academicYear,
    required this.authority,
  });

  // Convert a Semesters object into a Map object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'semester_name': semesterName,
      'branch_name': branchName,
      'program_name': programName,
      'academic_year': academicYear,
      'authority': authority,
    };
  }

  // Extract a Semesters object from a Map object
  factory Semesters.fromJson(Map<String, dynamic> map) {
    return Semesters(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      semesterName: map['semester_name'],
      branchName: map['branch_name'],
      programName: map['program_name'],
      academicYear: map['academic_year'],
      authority: map['authority'],
    );
  }

  @override
  String toString() {
    return 'Semesters{id: $id, createdAt: $createdAt, semesterName: $semesterName, branchName: $branchName, programName: $programName, academicYear: $academicYear, authority: $authority}';
  }
}
