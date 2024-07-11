class TimetableMeta {
  final String? section;
  final String? type;
  final String? revision;
  final String? effectiveDate;
  final String? contributor;
  final String? name;
  final bool? isTimetableUpdating;

  TimetableMeta({
    this.section,
    this.type,
    this.revision,
    this.effectiveDate,
    this.contributor,
    this.isTimetableUpdating,
    this.name,
  });

  factory TimetableMeta.fromJson(Map<String, dynamic> json) {
    return TimetableMeta(
      section: json['section'],
      type: json['type'],
      revision: json['revision'],
      effectiveDate: json['effective-date'],
      contributor: json['contributor'],
      isTimetableUpdating: json['isTimetableUpdating'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section': section,
      'type': type,
      'revision': revision,
      'effective-date': effectiveDate,
      'contributor': contributor,
      'isTimetableUpdating': isTimetableUpdating,
      'name': name,
    };
  }
}
