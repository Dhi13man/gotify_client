/// Version information for the Gotify server
class VersionInfo {
  /// The server version
  final String version;

  /// The git commit hash
  final String commit;

  /// When the server binary was built
  final String buildDate;

  /// Creates a new version info instance
  VersionInfo({
    required this.version,
    required this.commit,
    required this.buildDate,
  });

  /// Create a VersionInfo from JSON data
  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'],
      commit: json['commit'],
      buildDate: json['buildDate'],
    );
  }

  /// Convert version info to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'commit': commit,
      'buildDate': buildDate,
    };
  }
}
