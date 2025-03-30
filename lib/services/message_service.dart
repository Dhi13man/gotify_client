import 'dart:async';
import 'package:gotify_client/clients/client_factory.dart';
import 'package:gotify_client/clients/gotify_client.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:logging/logging.dart';

/// Service that handles message operations with the Gotify server
class MessageService {
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts = 5;

  final AuthState _authState;
  final GotifyClient _client;

  StreamSubscription<Message>? _streamSubscription;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;

  Function(Message)? _onMessageCallback;
  final Logger _logger = Logger('MessageService');

  /// Creates a new MessageService with the given AuthState
  MessageService(this._authState)
      : _client = ClientFactory.getClient(_authState.serverUrl) {
    _validateAuthentication();
  }

  /// Connect to the WebSocket stream to receive messages
  void connect({Function(Message)? onMessage}) {
    if (_isConnecting) {
      _logger.info('Connection attempt already in progress');
      return;
    }

    _validateAuthentication();

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
      _logger.info('Connecting to WebSocket stream');

      if (_authState.token != null) {
        _client.setToken(_authState.token!, AuthType.clientToken);

        final stream = _client.streamMessages();
        _streamSubscription = stream.listen(
          _handleWebSocketMessage,
          onError: _handleWebSocketError,
          onDone: _handleWebSocketDone,
        );
      }

      // Reset reconnect attempts on successful connection
      _reconnectAttempts = 0;
    } catch (e, stackTrace) {
      _logger.severe('Error connecting to WebSocket', e, stackTrace);
      _attemptReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  /// Handles messages from WebSocket
  void _handleWebSocketMessage(Message receivedMessage) {
    try {
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
    _closeWebSocket();

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

  /// Close the WebSocket connection safely
  void _closeWebSocket() {
    if (_streamSubscription != null) {
      try {
        _streamSubscription!.cancel();
      } catch (e, stackTrace) {
        _logger.warning('Error closing WebSocket stream', e, stackTrace);
      } finally {
        _streamSubscription = null;
      }
    }
  }

  /// Disconnect from the WebSocket
  void disconnect() {
    _shouldReconnect = false;
    _closeWebSocket();
  }

  /// Get messages from the server
  ///
  /// Returns the list of messages
  Future<List<Message>> getMessages() async {
    _validateAuthentication();

    try {
      _client.setToken(_authState.token!, AuthType.clientToken);
      final pagedMessages = await _client.getMessages();
      return pagedMessages.messages;
    } on ClientAuthenticationException {
      _handleAuthenticationFailure();
      rethrow;
    }
  }

  /// Send a message to the server
  ///
  /// Returns true if the message was sent successfully, false otherwise
  Future<bool> sendMessage({
    required String title,
    required String message,
    required int priority,
    required String applicationToken,
  }) async {
    try {
      // Set application token temporarily
      _client.setToken(applicationToken, AuthType.appToken);

      // Create the message
      await _client.createMessage(
        title: title,
        message: message,
        priority: priority,
      );

      return true;
    } on ClientException catch (e) {
      _logger.warning('Error sending message', e);
      return false;
    } finally {
      // Restore client token if available
      if (_authState.token != null) {
        _client.setToken(_authState.token!, AuthType.clientToken);
      }
    }
  }

  /// Delete a message from the server
  ///
  /// Returns true if the message was deleted successfully, false otherwise
  Future<bool> deleteMessage(int messageId) async {
    _validateAuthentication();

    try {
      _client.setToken(_authState.token!, AuthType.clientToken);
      await _client.deleteMessage(messageId);
      return true;
    } on ClientException catch (e) {
      _logger.warning('Error deleting message', e);
      return false;
    }
  }

  /// Handle authentication failures
  void _handleAuthenticationFailure() {
    // Disconnect the websocket as the token is no longer valid
    disconnect();
  }

  /// Validate authentication state before making API calls
  void _validateAuthentication() {
    if (!_authState.isAuthenticated || _authState.token == null) {
      throw const ClientAuthenticationException('Not authenticated');
    }
  }
}
