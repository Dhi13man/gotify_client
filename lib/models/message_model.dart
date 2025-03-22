class Message {
  final int id;
  final String title;
  final String message;
  final int priority;
  final String date;
  final int appid;
  final Map<String, dynamic>? extras;

  Message({
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
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 0,
      date: json['date'],
      appid: json['appid'],
      extras: json['extras'],
    );
  }
}
