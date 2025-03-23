import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

/// Service responsible for managing local notifications across the application.
class NotificationService {
  static const String _defaultIconPath = '@mipmap/ic_launcher';

  final Logger _logger = Logger('NotificationService');
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification settings for all supported platforms
  ///
  /// Returns true if initialization was successful, false otherwise
  Future<bool> initialize() async {
    _logger.info('Initializing notification service');

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings(_defaultIconPath);

      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      final bool? success = await _notificationsPlugin.initialize(initSettings);
      if (success ?? false) {
        _logger.info('Notification service initialized successfully');
        return true;
      } else {
        _logger.warning('Notification service initialization returned false');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.severe(
        'Failed to initialize notification service',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
