class ActionModel {
  final String label;
  final String iosUrl;
  final String androidUrl;

  ActionModel({
    required this.label,
    required this.androidUrl,
    required this.iosUrl,
  });

  factory ActionModel.fromJson(Map data) {
    return ActionModel(
      label: data['label'],
      androidUrl: data['androidUrl'],
      iosUrl: data['iosUrl'],
    );
  }
}
