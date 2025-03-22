import 'package:flutter/material.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/services/message_service.dart';
import 'package:gotify_client/models/auth_models.dart';

class MessageProvider extends ChangeNotifier {
  MessageService? _messageService;
  List<Message> _messages = [];
  bool _loading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _loading;
  String? get error => _error;

  void initialize(AuthState authState) {
    if (authState.isAuthenticated) {
      _messageService = MessageService(authState);
      _messageService!.connect(onMessage: _handleNewMessage);
      loadMessages();
    }
  }

  @override
  void dispose() {
    _messageService?.disconnect();
    super.dispose();
  }

  void _handleNewMessage(Message message) {
    _messages.insert(0, message);
    notifyListeners();
  }

  Future<void> loadMessages() async {
    if (_messageService == null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _messageService!.getMessages();
    } catch (e) {
      _error = 'Failed to load messages: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> sendMessage({
    required String title,
    required String message,
    required int priority,
    required int applicationId,
  }) async {
    if (_messageService == null) return false;

    _loading = true;
    notifyListeners();

    final success = await _messageService!.sendMessage(
      title: title,
      message: message,
      priority: priority,
      applicationId: applicationId,
    );

    if (!success) {
      _error = 'Failed to send message';
    }

    _loading = false;
    notifyListeners();
    return success;
  }
}
