import 'package:flutter/material.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/services/message_service.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:logging/logging.dart';

class MessageProvider extends ChangeNotifier {
  // Static logger instead of dependency injected
  static final _logger = Logger('MessageProvider');

  MessageService? _messageService;
  List<Message> _messages = [];
  bool _loading = false;
  String? _error;

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isInitialized => _messageService != null;

  /// Initializes the message service with authentication state
  void initialize(AuthState authState) {
    if (!authState.isAuthenticated) {
      _error = 'Cannot initialize: Not authenticated';
      notifyListeners();
      return;
    }

    // Cleanup previous connection if any
    _messageService?.disconnect();

    try {
      _messageService = MessageService(authState);
      _messageService!.connect(onMessage: _handleNewMessage);
      loadMessages();
    } catch (e) {
      _logger.severe('Failed to initialize message service', e);
      _error = 'Failed to initialize message service: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageService?.disconnect();
    _messageService = null;
    super.dispose();
  }

  /// Handles incoming messages from the websocket
  void _handleNewMessage(Message message) {
    _messages = [message, ..._messages];
    notifyListeners();
  }

  /// Loads messages from the server
  Future<void> loadMessages() async {
    if (_messageService == null) {
      _error = 'Message service not initialized';
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _messages = await _messageService!.getMessages();
      _error = null;
    } catch (e) {
      _logger.warning('Failed to load messages', e);
      _error = 'Failed to load messages: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Sends a new message
  Future<bool> sendMessage({
    required String title,
    required String message,
    required int priority,
    required int applicationId,
  }) async {
    if (_messageService == null) {
      _error = 'Message service not initialized';
      notifyListeners();
      return false;
    }

    if (title.isEmpty || message.isEmpty) {
      _error = 'Title and message cannot be empty';
      notifyListeners();
      return false;
    }

    if (priority < 0 || priority > 10) {
      _error = 'Priority must be between 0 and 10';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      final success = await _messageService!.sendMessage(
        title: title,
        message: message,
        priority: priority,
        applicationId: applicationId,
      );
      _error = success ? null : 'Failed to send message';
      return success;
    } catch (e) {
      _logger.warning('Error sending message', e);
      _error = 'Error sending message: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Helper to set loading state and notify listeners
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }
}
