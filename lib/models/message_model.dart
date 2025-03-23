class Message {
  // Constants for defaults
  static const int defaultId = 0;
  static const int defaultPriority = 0;
  static const int defaultAppId = 0;
  static const String defaultString = '';

  final int id;
  final String title;
  final String message;
  final int priority;
  final String date;
  final int appid;
  final Map<String, dynamic>? extras;

  const Message({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.date,
    required this.appid,
    this.extras,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: _parseIntSafely(json['id'], defaultId),
      title: json['title'] as String? ?? defaultString,
      message: json['message'] as String? ?? defaultString,
      priority: _parseIntSafely(json['priority'], defaultPriority),
      date: json['date'] as String? ?? defaultString,
      appid: _parseIntSafely(json['appid'], defaultAppId),
      extras: json['extras'] as Map<String, dynamic>?,
    );
  }

  /// Safely parses integer values from various types
  static int _parseIntSafely(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'priority': priority,
        'date': date,
        'appid': appid,
        if (extras != null) 'extras': extras,
      };

  Message copyWith({
    int? id,
    String? title,
    String? message,
    int? priority,
    String? date,
    int? appid,
    Map<String, dynamic>? extras,
  }) {
    return Message(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      appid: appid ?? this.appid,
      extras: extras ?? this.extras,
    );
  }

  @override
  String toString() =>
      'Message(id: $id, title: $title, priority: $priority, appid: $appid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.appid == appid &&
        other.date == date;
  }

  @override
  int get hashCode => id.hashCode ^ appid.hashCode ^ date.hashCode;
}
