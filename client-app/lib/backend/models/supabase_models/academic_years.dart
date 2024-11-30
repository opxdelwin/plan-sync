class AcademicYear {
  final int id;
  final DateTime createdAt;
  final String year;

  AcademicYear({
    required this.id,
    required this.createdAt,
    required this.year,
  });

  /// Factory method to create an AcademicYear from JSON
  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      year: json['year'] as String,
    );
  }

  /// Method to convert an AcademicYear to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'year': year,
    };
  }
}
