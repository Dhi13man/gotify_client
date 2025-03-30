/// Message model representing a notification sent by an application
class Message {
  /// The message id
  final int id;

  /// The application id that sent this message
  final int applicationId;

  /// The message content (may contain markdown)
  final String message;

  /// The message title (optional)
  final String? title;

  /// The priority level of the message (0-10)
  final int? priority;

  /// The date the message was created
  final DateTime date;

  /// Extra data associated with the message
  final Map<String, dynamic>? extras;

  /// Creates a new message instance
  Message({
    required this.id,
    required this.applicationId,
    required this.message,
    this.title,
    this.priority,
    required this.date,
    this.extras,
  });

  /// Create a Message from JSON data
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      applicationId: json['appid'],
      message: json['message'],
      title: json['title'],
      priority: json['priority'],
      date: DateTime.parse(json['date']),
      extras: json['extras'] as Map<String, dynamic>?,
    );
  }

  /// Convert message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appid': applicationId,
      'message': message,
      if (title != null) 'title': title,
      if (priority != null) 'priority': priority,
      'date': date.toIso8601String(),
      if (extras != null) 'extras': extras,
    };
  }
}

/// Paging information for message lists
class Paging {
  /// The number of messages in the current response
  final int size;

  /// The starting point for the next page
  final int since;

  /// The limit applied to the current request
  final int limit;

  /// URL for the next page of messages
  final String? next;

  /// Creates a new paging instance
  Paging({
    required this.size,
    required this.since,
    required this.limit,
    this.next,
  });

  /// Create a Paging from JSON data
  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      size: json['size'],
      since: json['since'],
      limit: json['limit'],
      next: json['next'],
    );
  }

  /// Convert paging to JSON
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'since': since,
      'limit': limit,
      if (next != null) 'next': next,
    };
  }
}

/// Container for paged message responses
class PagedMessages {
  /// Messages in the current page
  final List<Message> messages;

  /// Paging information
  final Paging paging;

  /// Creates a new paged messages instance
  PagedMessages({
    required this.messages,
    required this.paging,
  });

  /// Create PagedMessages from JSON data
  factory PagedMessages.fromJson(Map<String, dynamic> json) {
    final List<dynamic> messagesJson = json['messages'];

    return PagedMessages(
      messages: messagesJson
          .map((messageJson) => Message.fromJson(messageJson))
          .toList(),
      paging: Paging.fromJson(json['paging']),
    );
  }

  /// Convert paged messages to JSON
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'paging': paging.toJson(),
    };
  }
}
