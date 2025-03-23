import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

/// Service responsible for managing local notifications across the application.
class NotificationService {
  static const String _defaultIconPath = '@mipmap/ic_launcher';
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final Logger _logger = Logger('NotificationService');
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Private constructor for singleton pattern
  NotificationService._internal();

  /// Returns whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize notification settings for all supported platforms
  ///
  /// Returns true if initialization was successful, false otherwise
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

  /// Show a notification with the given title and body
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
