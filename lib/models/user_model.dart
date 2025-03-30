/// User model representing a Gotify user
class User {
  /// The user ID
  final int id;

  /// The user's name
  final String name;

  /// Whether this user has admin privileges
  final bool admin;

  /// Creates a new user instance
  User({
    required this.id,
    required this.name,
    required this.admin,
  });

  /// Create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      admin: json['admin'],
    );
  }

  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'admin': admin,
    };
  }
}
