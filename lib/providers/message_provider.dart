import 'package:flutter/material.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/services/message_service.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:logging/logging.dart';

/// Constants for message validation
class MessageValidation {
  static const int minPriority = 0;
  static const int maxPriority = 10;
}

class MessageProvider extends ChangeNotifier {
  static final _logger = Logger('MessageProvider');

  final MessageService? Function(AuthState) _messageServiceFactory;
  MessageService? _messageService;
  List<Message> _messages = [];
  bool _loading = false;
  String? _error;

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isInitialized => _messageService != null;

  /// Constructor with dependency injection for testability
  MessageProvider({
    MessageService? Function(AuthState)? messageServiceFactory,
  }) : _messageServiceFactory =
            messageServiceFactory ?? ((authState) => MessageService(authState));

  /// Initializes the message service with authentication state
  void initialize(AuthState authState) {
    if (!authState.isAuthenticated) {
      _setError('Cannot initialize: Not authenticated');
      return;
    }

    // Cleanup previous connection if any
    _disconnect();

    try {
      _messageService = _messageServiceFactory(authState);
      _messageService!.connect(onMessage: _handleNewMessage);
      loadMessages();
    } catch (e) {
      _logger.severe('Failed to initialize message service', e);
      _setError('Failed to initialize message service: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  /// Disconnects the message service
  void _disconnect() {
    _messageService?.disconnect();
    _messageService = null;
  }

  /// Handles incoming messages from the websocket
  void _handleNewMessage(Message message) {
    _messages = [message, ..._messages];
    notifyListeners();
  }

  /// Loads messages from the server
  Future<void> loadMessages() async {
    if (!_checkServiceInitialized()) return;

    _setLoading(true);

    try {
      _messages = await _messageService!.getMessages();
      _clearError();
    } catch (e) {
      _logger.warning('Failed to load messages', e);
      _setError('Failed to load messages: ${e.toString()}');
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
    // Validate service initialization
    if (!_checkServiceInitialized()) return false;

    // Input validation
    final validationError = _validateMessageInput(
        title: title, message: message, priority: priority);

    if (validationError != null) {
      _setError(validationError);
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

      if (success) {
        _clearError();
      } else {
        _setError('Failed to send message');
      }
      return success;
    } catch (e) {
      _logger.warning('Error sending message', e);
      _setError('Error sending message: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Validates message input parameters
  String? _validateMessageInput(
      {required String title, required String message, required int priority}) {
    if (title.isEmpty) {
      return 'Title cannot be empty';
    }

    if (message.isEmpty) {
      return 'Message cannot be empty';
    }

    if (priority < MessageValidation.minPriority ||
        priority > MessageValidation.maxPriority) {
      return 'Priority must be between ${MessageValidation.minPriority} and ${MessageValidation.maxPriority}';
    }

    return null;
  }

  /// Checks if service is initialized and sets error if not
  bool _checkServiceInitialized() {
    if (_messageService == null) {
      _setError('Message service not initialized');
      return false;
    }
    return true;
  }

  /// Helper to set loading state and notify listeners
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  /// Helper to set error state
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Helper to clear error state
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
