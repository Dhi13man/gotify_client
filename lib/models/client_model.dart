/// Client model representing a device that can receive notifications
class Client {
  /// The client ID
  final int id;

  /// The client token for authentication
  final String token;

  /// The client name
  final String name;

  /// When the client token was last used
  final DateTime? lastUsed;

  /// Creates a new client instance
  Client({
    required this.id,
    required this.token,
    required this.name,
    this.lastUsed,
  });

  /// Create a Client from JSON data
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      token: json['token'],
      name: json['name'],
      lastUsed:
          json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

  /// Convert client to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'name': name,
      if (lastUsed != null) 'lastUsed': lastUsed!.toIso8601String(),
    };
  }
}
