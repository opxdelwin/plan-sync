class CampusNavigationModel {
  final int id;
  final String? title;
  final String? mapsLink;
  final String? imagePath;

  CampusNavigationModel({
    required this.id,
    this.title,
    this.mapsLink,
    this.imagePath,
  });

  factory CampusNavigationModel.fromJson(Map<String, dynamic> json) {
    return CampusNavigationModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      mapsLink: json['maps_link'] as String?,
      imagePath: json['image_path'] as String?,
    );
  }
}
