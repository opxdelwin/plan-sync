class AppVersion {
  final List<int> parts;

  AppVersion(String version)
      : parts = version.split('.').map(int.parse).toList();

  bool isGreaterThan(AppVersion other) {
    for (int i = 0; i < parts.length; i++) {
      if (i >= other.parts.length) return true;
      if (parts[i] > other.parts[i]) return true;
      if (parts[i] < other.parts[i]) return false;
    }
    return false;
  }
}
