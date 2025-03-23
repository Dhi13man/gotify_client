import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:web_socket_channel/io.dart';
import 'package:logging/logging.dart';

class MessageService {
  final AuthState _authState;
  IOWebSocketChannel? _channel;
  Function(Message)? onMessageCallback;
  final Logger _logger = Logger('MessageService');

  MessageService(this._authState);

  void connect({Function(Message)? onMessage}) {
    if (!_authState.isAuthenticated || _authState.token == null) {
      throw Exception('Not authenticated');
    }

    onMessageCallback = onMessage;

    final wsUrl = _authState.serverUrl
        .replaceFirst('https', 'ws')
        .replaceFirst('http', 'ws');
    _channel = IOWebSocketChannel.connect(
      '$wsUrl/stream?token=${_authState.token}',
    );

    _channel!.stream.listen(
      (dynamic message) {
        if (message is String) {
          final data = jsonDecode(message);
          final receivedMessage = Message.fromJson(data);
          if (onMessageCallback != null) {
            onMessageCallback!(receivedMessage);
          }
        }
      },
      onError: (error) {
        _logger.warning('WebSocket error: $error');
        _reconnect();
      },
      onDone: () {
        _logger.info('WebSocket connection closed');
        _reconnect();
      },
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void _reconnect() {
    disconnect();
    Future.delayed(const Duration(seconds: 5), () {
      connect(onMessage: onMessageCallback);
    });
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('${_authState.serverUrl}/message'),
        headers: {'X-Gotify-Key': _authState.token ?? ''},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['messages'];
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      _logger.severe('Error getting messages: $e');
      return [];
    }
  }

  Future<bool> sendMessage({
    required String title,
    required String message,
    required int priority,
    required int applicationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_authState.serverUrl}/message'),
        headers: {
          'X-Gotify-Key': _authState.token ?? '',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'title': title,
          'message': message,
          'priority': priority,
          'extras': {'client': 'flutter'},
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.severe('Error sending message: $e');
      return false;
    }
  }
}
