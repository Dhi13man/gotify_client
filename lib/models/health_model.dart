/// Health model representing server health status
class Health {
  /// Overall health of the application ('green', 'yellow', 'red')
  final String health;

  /// Database connection health ('green', 'yellow', 'red')
  final String database;

  /// Creates a new health instance
  Health({
    required this.health,
    required this.database,
  });

  /// Create a Health from JSON data
  factory Health.fromJson(Map<String, dynamic> json) {
    return Health(
      health: json['health'],
      database: json['database'],
    );
  }

  /// Convert health to JSON
  Map<String, dynamic> toJson() {
    return {
      'health': health,
      'database': database,
    };
  }
}
