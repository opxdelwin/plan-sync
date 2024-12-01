class Section {
  final int? id;
  final DateTime createdAt;
  final String sectionName;
  final String semesterName;
  final String branch;
  final String program;
  final String academicYear;
  final String? authority;

  Section({
    this.id,
    DateTime? createdAt,
    required this.sectionName,
    required this.semesterName,
    required this.branch,
    required this.program,
    required this.academicYear,
    this.authority,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'section_name': sectionName,
        'semester_name': semesterName,
        'branch': branch,
        'program': program,
        'academic_year': academicYear,
        'authority': authority,
      };

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        id: json['id'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        sectionName: json['section_name'] as String,
        semesterName: json['semester_name'] as String,
        branch: json['branch'] as String,
        program: json['program'] as String,
        academicYear: json['academic_year'] as String,
        authority: json['authority'] as String?,
      );

  @override
  String toString() {
    return 'Section(id: $id, createdAt: $createdAt, sectionName: $sectionName, '
        'semesterName: $semesterName, branch: $branch, program: $program, '
        'academicYear: $academicYear, authority: $authority)';
  }
}
