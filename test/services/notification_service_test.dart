import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotify_client/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

void main() {
  late MockFlutterLocalNotificationsPlugin notificationsPlugin;
  late LocalNotificationService notificationService;

  setUpAll(() {
    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeNotificationDetails());
  });

  setUp(() {
    notificationsPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = LocalNotificationService(
      notificationsPlugin: notificationsPlugin,
    );
  });

  group('LocalNotificationService', () {
    test('initialize_whenPluginSucceeds_thenMarksServiceInitialized', () async {
      // Arrange
      when(
        () => notificationsPlugin.initialize(settings: any(named: 'settings')),
      ).thenAnswer((_) async => true);

      // Act
      final bool result = await notificationService.initialize();

      // Assert
      expect(result, isTrue);
      expect(notificationService.isInitialized, isTrue);
      verify(
        () => notificationsPlugin.initialize(settings: any(named: 'settings')),
      ).called(1);
    });

    test('initialize_whenCalledTwice_thenInvokesPluginOnce', () async {
      // Arrange
      when(
        () => notificationsPlugin.initialize(settings: any(named: 'settings')),
      ).thenAnswer((_) async => true);

      // Act
      final bool firstResult = await notificationService.initialize();
      final bool secondResult = await notificationService.initialize();

      // Assert
      expect(firstResult, isTrue);
      expect(secondResult, isTrue);
      verify(
        () => notificationsPlugin.initialize(settings: any(named: 'settings')),
      ).called(1);
    });

    test('showNotification_whenInitialized_thenForwardsNotification', () async {
      // Arrange
      when(
        () => notificationsPlugin.initialize(settings: any(named: 'settings')),
      ).thenAnswer((_) async => true);
      when(
        () => notificationsPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});
      await notificationService.initialize();

      // Act
      final bool result = await notificationService.showNotification(
        id: 7,
        title: 'Build complete',
        body: 'The dependency update passed.',
        payload: 'message-7',
      );

      // Assert
      expect(result, isTrue);
      verify(
        () => notificationsPlugin.show(
          id: 7,
          title: 'Build complete',
          body: 'The dependency update passed.',
          notificationDetails: any(named: 'notificationDetails'),
          payload: 'message-7',
        ),
      ).called(1);
    });
  });
}
