import 'package:gotify_client/services/notification_service.dart';

/// Mock notification service for testing
class MockNotificationService implements NotificationService {
  bool _isInitialized = false;
  final List<Map<String, dynamic>> notifications = [];
  bool shouldSucceed = true;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<bool> initialize() async {
    if (shouldSucceed) {
      _isInitialized = true;
      return true;
    } else {
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized || !shouldSucceed) {
      return false;
    }

    notifications.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });

    return true;
  }

  void reset() {
    _isInitialized = false;
    notifications.clear();
    shouldSucceed = true;
  }
}
