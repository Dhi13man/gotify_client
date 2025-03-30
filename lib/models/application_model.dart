/// Application model representing a Gotify application that can send messages
class Application {
  /// The application ID
  final int id;

  /// The application token for authentication
  final String token;

  /// The application name
  final String name;

  /// The application description
  final String description;

  /// Whether this is an internal application
  final bool internal;

  /// Path to the application image
  final String image;

  /// Default priority for messages sent by this application
  final int? defaultPriority;

  /// When the application token was last used
  final DateTime? lastUsed;

  /// Creates a new application instance
  Application({
    required this.id,
    required this.token,
    required this.name,
    required this.description,
    required this.internal,
    required this.image,
    this.defaultPriority,
    this.lastUsed,
  });

  /// Create an Application from JSON data
  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      token: json['token'],
      name: json['name'],
      description: json['description'],
      internal: json['internal'],
      image: json['image'],
      defaultPriority: json['defaultPriority'],
      lastUsed:
          json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

  /// Convert application to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'name': name,
      'description': description,
      'internal': internal,
      'image': image,
      if (defaultPriority != null) 'defaultPriority': defaultPriority,
      if (lastUsed != null) 'lastUsed': lastUsed!.toIso8601String(),
    };
  }
}
