/// Plugin configuration model
class PluginConfig {
  /// The plugin ID
  final int id;

  /// The plugin name
  final String name;

  /// The plugin token
  final String token;

  /// The module path of the plugin
  final String modulePath;

  /// Whether the plugin is enabled
  final bool enabled;

  /// Plugin capabilities (e.g., webhook, display)
  final List<String> capabilities;

  /// The plugin author
  final String? author;

  /// The plugin license
  final String? license;

  /// The plugin website
  final String? website;

  /// Creates a new plugin config instance
  PluginConfig({
    required this.id,
    required this.name,
    required this.token,
    required this.modulePath,
    required this.enabled,
    required this.capabilities,
    this.author,
    this.license,
    this.website,
  });

  /// Create a PluginConfig from JSON data
  factory PluginConfig.fromJson(Map<String, dynamic> json) {
    return PluginConfig(
      id: json['id'],
      name: json['name'],
      token: json['token'],
      modulePath: json['modulePath'],
      enabled: json['enabled'],
      capabilities: (json['capabilities'] as List<dynamic>).cast<String>(),
      author: json['author'],
      license: json['license'],
      website: json['website'],
    );
  }

  /// Convert plugin config to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'token': token,
      'modulePath': modulePath,
      'enabled': enabled,
      'capabilities': capabilities,
      if (author != null) 'author': author,
      if (license != null) 'license': license,
      if (website != null) 'website': website,
    };
  }
}
