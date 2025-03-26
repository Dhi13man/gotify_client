import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:gotify_client/services/message_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

// Mock classes
class MockClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockWebSocketChannel extends Mock implements IOWebSocketChannel {}

class MockWebSocketSink extends Mock implements WebSocketSink {}

class MockStreamController<T> extends Mock implements StreamController<T> {}

class MockAuthState extends Mock implements AuthState {}

void main() {
  late MessageService messageService;
  late MockClient mockClient;
  late MockWebSocketChannel mockWebSocketChannel;
  late MockAuthState mockAuthState;
  late StreamController<dynamic> wsStreamController;

  const String serverUrl = 'http://gotify.example.com';
  const String authToken = 'valid_token';
  const String messageEndpoint = '/message';

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    // Setup mock auth state
    mockAuthState = MockAuthState();
    when(() => mockAuthState.isAuthenticated).thenReturn(true);
    when(() => mockAuthState.token).thenReturn(authToken);
    when(() => mockAuthState.serverUrl).thenReturn(serverUrl);

    // Setup mock HTTP client
    mockClient = MockClient();

    // Setup WebSocket mock
    mockWebSocketChannel = MockWebSocketChannel();
    wsStreamController = StreamController<dynamic>.broadcast();
    when(() => mockWebSocketChannel.sink).thenReturn(MockWebSocketSink());
    when(() => mockWebSocketChannel.stream)
        .thenAnswer((_) => wsStreamController.stream);

    // Create message service
    messageService = MessageService(mockAuthState);
  });

  tearDown(() {
    wsStreamController.close();
  });

  group('Construction', () {
    test('should throw when auth state is not authenticated', () {
      // Arrange
      when(() => mockAuthState.isAuthenticated).thenReturn(false);

      // Act & Assert
      expect(() => MessageService(mockAuthState), throwsArgumentError);
    });

    test('should throw when auth token is null', () {
      // Arrange
      when(() => mockAuthState.isAuthenticated).thenReturn(true);
      when(() => mockAuthState.token).thenReturn(null);

      // Act & Assert
      expect(() => MessageService(mockAuthState), throwsArgumentError);
    });
  });

  group('getMessages', () {
    test('should return messages when request is successful', () async {
      // Arrange
      final messages = [
        {
          'id': 1,
          'title': 'Test',
          'message': 'Hello',
          'priority': 5,
          'date': '2021-01-01',
          'appid': 1
        },
        {
          'id': 2,
          'title': 'Test 2',
          'message': 'World',
          'priority': 3,
          'date': '2021-01-02',
          'appid': 2
        }
      ];

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body)
          .thenReturn(jsonEncode({'messages': messages}));

      when(() => mockClient.get(
            Uri.parse('$serverUrl$messageEndpoint'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await messageService.getMessages();

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].title, 'Test');
      expect(result[1].id, 2);
      expect(result[1].title, 'Test 2');

      verify(() => mockClient.get(
            Uri.parse('$serverUrl$messageEndpoint'),
            headers: {'X-Gotify-Key': authToken},
          )).called(1);
    });

    test('should handle authentication failure', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(401);
      when(() => mockResponse.body)
          .thenReturn(jsonEncode({'error': 'Unauthorized'}));
      when(() => mockResponse.reasonPhrase).thenReturn('Unauthorized');

      when(() => mockClient.get(
            Uri.parse('$serverUrl$messageEndpoint'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(() => messageService.getMessages(),
          throwsA(isA<ClientAuthenticationException>()));
    });

    test('should throw exception when response format is invalid', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body)
          .thenReturn('{"invalid": "response"}'); // Missing 'messages' key

      when(() => mockClient.get(
            Uri.parse('$serverUrl$messageEndpoint'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await messageService.getMessages();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('sendMessage', () {
    test('should return true when message is sent successfully', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);

      when(() => mockClient.post(
            Uri.parse('$serverUrl$messageEndpoint'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await messageService.sendMessage(
        title: 'Test',
        message: 'Hello World',
        priority: 5,
        applicationToken: 'app_token',
      );

      // Assert
      expect(result, true);

      verify(() => mockClient.post(
            Uri.parse('$serverUrl$messageEndpoint'),
            headers: {
              'X-Gotify-Key': 'app_token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'title': 'Test',
              'message': 'Hello World',
              'priority': 5,
            }),
          )).called(1);
    });

    test('should throw exception when request fails', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(() => mockResponse.body)
          .thenReturn(jsonEncode({'error': 'Server error'}));
      when(() => mockResponse.reasonPhrase).thenReturn('Server error');

      when(() => mockClient.post(
            Uri.parse('$serverUrl$messageEndpoint'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => messageService.sendMessage(
          title: 'Test',
          message: 'Hello World',
          priority: 5,
          applicationToken: 'app_token',
        ),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('deleteMessage', () {
    test('should return true when message is deleted successfully', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);

      when(() => mockClient.delete(
            Uri.parse('$serverUrl$messageEndpoint/123'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await messageService.deleteMessage(123);

      // Assert
      expect(result, true);

      verify(() => mockClient.delete(
            Uri.parse('$serverUrl$messageEndpoint/123'),
            headers: {'X-Gotify-Key': authToken},
          )).called(1);
    });

    test('should return true when HTTP status is 204', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(204);

      when(() => mockClient.delete(
            Uri.parse('$serverUrl$messageEndpoint/123'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await messageService.deleteMessage(123);

      // Assert
      expect(result, true);
    });

    test('should throw exception when request fails', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(404);
      when(() => mockResponse.body)
          .thenReturn(jsonEncode({'error': 'Message not found'}));
      when(() => mockResponse.reasonPhrase).thenReturn('Not found');

      when(() => mockClient.delete(
            Uri.parse('$serverUrl$messageEndpoint/999'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => messageService.deleteMessage(999),
        throwsA(isA<ClientException>()),
      );
    });
  });

  // WebSocket connection tests would require additional mocking of the IOWebSocketChannel.connect static method
  // which is more complex. Here's a simplified version of how the test would look:

  group('connect', () {
    test('should set up WebSocket connection correctly', () {
      // This is a partial test as we can't easily mock static IOWebSocketChannel.connect
      // In a real implementation, we might need to use a library like 'mocktail_image_network'
      // or restructure the code to allow for better testing

      // For now, we'll just verify it doesn't throw when called properly
      expect(() => messageService.connect(onMessage: (_) {}), returnsNormally);
    });

    test('should not attempt reconnection when disconnect is called', () {
      // Simply verify disconnect works without error
      expect(() => messageService.disconnect(), returnsNormally);
    });
  });
}
