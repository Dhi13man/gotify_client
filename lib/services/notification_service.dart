import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

/// Interface for notification services
abstract class NotificationService {
  /// Returns whether the service has been initialized
  bool get isInitialized;
  
  /// Initialize notification settings for all supported platforms
  ///
  /// Returns true if initialization was successful, false otherwise
  Future<bool> initialize();
  
  /// Show a notification with the given title and body
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
}

/// Default implementation of NotificationService using FlutterLocalNotifications
class LocalNotificationService implements NotificationService {
  static const String _defaultIconPath = '@mipmap/ic_launcher';
  
  final Logger _logger;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  /// Constructor with explicit dependency injection
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    Logger? logger,
  }) : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin(),
       _logger = logger ?? Logger('LocalNotificationService');

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) {
      _logger.info('Notification service already initialized');
      return true;
    }

    _logger.info('Initializing notification service');

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings(_defaultIconPath);

      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      final bool? success = await _notificationsPlugin.initialize(initSettings);

      if (success ?? false) {
        _logger.info('Notification service initialized successfully');
        _isInitialized = true;
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

  @override
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      _logger.warning('Attempted to show notification before initialization');
      return false;
    }

    try {
      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          'gotify_channel',
          'Gotify Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error showing notification', e, stackTrace);
      return false;
    }
  }
}
