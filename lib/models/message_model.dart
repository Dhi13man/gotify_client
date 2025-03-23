class Message {
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      priority: json['priority'] is int
          ? json['priority']
          : int.tryParse(json['priority'].toString()) ?? 0,
      date: json['date'] as String? ?? '',
      appid: json['appid'] is int
          ? json['appid']
          : int.tryParse(json['appid'].toString()) ?? 0,
      extras: json['extras'] as Map<String, dynamic>?,
    );
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
