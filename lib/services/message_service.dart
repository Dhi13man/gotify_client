import 'dart:async';
import 'dart:convert';
import 'package:gotify_client/models/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:logging/logging.dart';

/// Service that handles message operations with the Gotify server
class MessageService {
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const Duration httpTimeout = Duration(seconds: 10);
  static const String messageEndpoint = '/message';
  static const String streamEndpoint = '/stream';
  static const int maxReconnectAttempts = 5;
  static const Map<String, String> jsonContentType = {
    'Content-Type': 'application/json'
  };

  final AuthState _authState;
  IOWebSocketChannel? _channel;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;

  Function(Message)? _onMessageCallback;
  final Logger _logger = Logger('MessageService');

  MessageService(this._authState) {
    if (!_authState.isAuthenticated || _authState.token == null) {
      throw ArgumentError('MessageService requires authenticated AuthState');
    }
  }

  /// Connect to the WebSocket stream
  void connect({Function(Message)? onMessage}) {
    if (_isConnecting) {
      _logger.info('Connection attempt already in progress');
      return;
    }

    if (!_authState.isAuthenticated || _authState.token == null) {
      throw StateError('Not authenticated');
    }

    _onMessageCallback = onMessage;
    _shouldReconnect = true;
    _reconnectAttempts = 0;
    _connectWebSocket();
  }

  /// Attempts to establish a WebSocket connection
  void _connectWebSocket() {
    if (_isConnecting) return;

    _isConnecting = true;

    try {
      final wsUrl = _getWebSocketUrl();
      _logger.info('Connecting to WebSocket at: $wsUrl');

      _channel = IOWebSocketChannel.connect(
        Uri.parse('$wsUrl$streamEndpoint?token=${_authState.token}'),
        pingInterval: const Duration(seconds: 30),
      );

      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
        cancelOnError: false,
      );

      // Reset reconnect attempts on successful connection
      _reconnectAttempts = 0;
    } catch (e, stackTrace) {
      _logger.severe('Error creating WebSocket connection', e, stackTrace);
      _handleWebSocketError(e);
    } finally {
      _isConnecting = false;
    }
  }

  /// Converts HTTP URL to WebSocket URL
  String _getWebSocketUrl() {
    return _authState.serverUrl.replaceFirst('http', 'ws');
  }

  /// Handles messages from WebSocket
  void _handleWebSocketMessage(dynamic message) {
    if (message is! String) {
      _logger.warning('Received non-string message: $message');
      return;
    }

    try {
      final data = jsonDecode(message);
      final receivedMessage = Message.fromJson(data);
      _onMessageCallback?.call(receivedMessage);
    } catch (e, stackTrace) {
      _logger.warning('Error processing WebSocket message', e, stackTrace);
    }
  }

  /// Handles WebSocket errors
  void _handleWebSocketError(Object error, [StackTrace? stackTrace]) {
    _logger.warning('WebSocket error', error, stackTrace ?? StackTrace.current);
    _attemptReconnect();
  }

  /// Handles WebSocket connection closure
  void _handleWebSocketDone() {
    _logger.info('WebSocket connection closed');
    _attemptReconnect();
  }

  /// Attempts to reconnect to the WebSocket
  void _attemptReconnect() {
    _closeChannel();

    if (!_shouldReconnect || _reconnectAttempts >= maxReconnectAttempts) {
      _logger
          .warning('Max reconnect attempts reached or reconnection disabled');
      return;
    }

    _reconnectAttempts++;
    _logger
        .info('Reconnect attempt $_reconnectAttempts of $maxReconnectAttempts');

    Future.delayed(reconnectDelay, () {
      if (_shouldReconnect) {
        _connectWebSocket();
      }
    });
  }

  /// Close the WebSocket channel safely
  void _closeChannel() {
    if (_channel != null) {
      try {
        _channel?.sink.close(ws_status.normalClosure);
      } catch (e, stackTrace) {
        _logger.warning('Error closing WebSocket', e, stackTrace);
      } finally {
        _channel = null;
      }
    }
  }

  /// Disconnect from the WebSocket
  void disconnect() {
    _shouldReconnect = false;
    _closeChannel();
  }

  /// Get messages from the server
  Future<List<Message>> getMessages() async {
    _validateAuthentication();

    try {
      final response = await http.get(
        Uri.parse('${_authState.serverUrl}$messageEndpoint'),
        headers: {'X-Gotify-Key': _authState.token!},
      ).timeout(httpTimeout);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is! Map<String, dynamic> ||
            !responseBody.containsKey('messages')) {
          _logger.warning(
              'Unexpected response format: ${response.body.substring(0, 100)}...');
          return [];
        }

        final List<dynamic> data = responseBody['messages'];
        return data.map((json) => Message.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        _handleAuthenticationFailure();
        throw ClientAuthenticationException('Authentication failed');
      } else {
        throw _createMessageException('Failed to load messages', response);
      }
    } on TimeoutException {
      throw ClientTimeoutException('Request timed out');
    } on ClientException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.severe('Error getting messages', e, stackTrace);
      throw ClientException(
        'Failed to retrieve messages: ${e.toString()}',
      );
    }
  }

  /// Send a message to the server
  Future<bool> sendMessage({
    required String title,
    required String message,
    required int priority,
    required String applicationToken,
  }) async {
    _validateAuthentication();

    try {
      final response = await http
          .post(
            Uri.parse('${_authState.serverUrl}$messageEndpoint'),
            headers: {'X-Gotify-Key': applicationToken, ...jsonContentType},
            body: jsonEncode({
              'title': title,
              'message': message,
              'priority': priority,
            }),
          )
          .timeout(httpTimeout);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        _logger
            .warning('Authentication failure (HTTP 401) when sending message');
        _handleAuthenticationFailure();
        throw ClientAuthenticationException('Authentication failed');
      } else {
        _logger.warning('Failed to send message: HTTP ${response.statusCode}');
        throw _createMessageException('Failed to send message', response);
      }
    } on TimeoutException {
      throw ClientTimeoutException('Request timed out');
    } on ClientException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.severe('Error sending message', e, stackTrace);
      throw ClientException('Failed to send message: ${e.toString()}');
    }
  }

  /// Delete a message from the server
  Future<bool> deleteMessage(int messageId) async {
    _validateAuthentication();

    try {
      final response = await http.delete(
        Uri.parse('${_authState.serverUrl}$messageEndpoint/$messageId'),
        headers: {'X-Gotify-Key': _authState.token!},
      ).timeout(httpTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        _logger
            .warning('Authentication failure (HTTP 401) when deleting message');
        _handleAuthenticationFailure();
        throw ClientAuthenticationException('Authentication failed');
      } else {
        _logger
            .warning('Failed to delete message: HTTP ${response.statusCode}');
        throw _createMessageException('Failed to delete message', response);
      }
    } on TimeoutException {
      throw ClientTimeoutException('Request timed out');
    } on ClientException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.severe('Error deleting message', e, stackTrace);
      throw ClientException('Failed to delete message: ${e.toString()}');
    }
  }

  /// Handle authentication failures
  void _handleAuthenticationFailure() {
    // Disconnect the websocket as the token is no longer valid
    disconnect();
  }

  /// Create exception with details from HTTP response
  ClientException _createMessageException(
    String message,
    http.Response response,
  ) {
    String errorDetails = response.reasonPhrase ?? 'Unknown error';
    try {
      final body = jsonDecode(response.body);
      errorDetails = body['error'] ?? body['message'] ?? errorDetails;
    } catch (e) {
      // Use the default error message if JSON parsing fails
    }

    return ClientException(
      '$message: $errorDetails',
      statusCode: response.statusCode,
    );
  }

  void _validateAuthentication() {
    if (!_authState.isAuthenticated || _authState.token == null) {
      throw ClientAuthenticationException('Not authenticated');
    }
  }
}
