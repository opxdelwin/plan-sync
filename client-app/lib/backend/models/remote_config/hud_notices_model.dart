class HudNoticeModel {
  final String title;
  final String description;

  const HudNoticeModel({
    required this.title,
    required this.description,
  });

  factory HudNoticeModel.fromMap(Map data) => HudNoticeModel(
        title: data['title'],
        description: data['description'],
      );
}
