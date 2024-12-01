class Branches {
  final int id;
  final DateTime createdAt;
  final String branchName;
  final String program;
  final String authority;

  Branches({
    required this.id,
    required this.createdAt,
    required this.branchName,
    required this.program,
    required this.authority,
  });

  factory Branches.fromJson(Map<String, dynamic> json) {
    return Branches(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      branchName: json['branch_name'],
      program: json['program'],
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'branch_name': branchName,
      'program': program,
      'authority': authority,
    };
  }

  @override
  String toString() {
    return 'Branches{id: $id, createdAt: $createdAt, branchName: $branchName, program: $program, authority: $authority}';
  }
}
