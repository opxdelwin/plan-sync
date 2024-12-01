class Program {
  final int? id;
  final DateTime? createdAt;
  final String name;
  final String authority;

  Program({
    this.id,
    this.createdAt,
    required this.name,
    this.authority = '',
  });

  // Convert a Program object into a Map (to insert into the database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'name': name,
      'authority': authority,
    };
  }

  // Convert a Map object (retrieved from the database) into a Program object
  factory Program.fromJson(Map<String, dynamic> map) {
    return Program(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      name: map['name'] as String,
      authority: map['authority'] as String? ?? '',
    );
  }

  // Override toString for easy debugging
  @override
  String toString() {
    return 'Program(id: $id, createdAt: $createdAt, name: $name, authority: $authority)';
  }
}
