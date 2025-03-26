import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AuthService authService;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockClient mockClient;

  const String serverUrl = 'https://gotify.example.com';
  const String validToken = 'valid_token';
  const String username = 'testuser';
  const String password = 'testpass';
  const String clientEndpoint = '/client';
  const String applicationEndpoint = '/application';

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockClient = MockClient();

    authService = AuthService(secureStorage: mockSecureStorage);

    // Reset SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  group('loadAuth', () {
    test('should return initial state when no data is stored', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      // Act
      final result = await authService.loadAuth();

      // Assert
      expect(result.isAuthenticated, false);
      expect(result.serverUrl, '');
      expect(result.token, isNull);
      expect(result.error, isNull);
    });

    test('should load auth state from storage', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'gotify_auth': jsonEncode({
          'isAuthenticated': true,
          'serverUrl': serverUrl,
        }),
      });

      when(() => mockSecureStorage.read(key: 'gotify_token'))
          .thenAnswer((_) async => validToken);

      // Act
      final result = await authService.loadAuth();

      // Assert
      expect(result.isAuthenticated, true);
      expect(result.serverUrl, serverUrl);
      expect(result.token, validToken);
      expect(result.error, isNull);
    });

    test('should return unauthenticated state when token is missing', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'gotify_auth': jsonEncode({
          'isAuthenticated': true,
          'serverUrl': serverUrl,
        }),
      });

      when(() => mockSecureStorage.read(key: 'gotify_token'))
          .thenAnswer((_) async => null);

      // Act
      final result = await authService.loadAuth();

      // Assert
      expect(result.isAuthenticated, false);
      expect(result.serverUrl, serverUrl);
      expect(result.token, isNull);
      expect(result.error, isNull);
    });
  });

  group('login', () {
    test('should authenticate with client token', () async {
      // Arrange
      final config = AuthConfig(
        serverUrl: serverUrl,
        clientToken: validToken,
      );

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('[]');

      when(() => mockClient.get(
            Uri.parse('$serverUrl$applicationEndpoint'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Mock secure storage and shared preferences
      when(() => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      // Act
      final result = await authService.login(config);

      // Assert
      expect(result.isAuthenticated, true);
      expect(result.serverUrl, serverUrl);
      expect(result.token, validToken);
      expect(result.error, isNull);

      verify(() =>
              mockSecureStorage.write(key: 'gotify_token', value: validToken))
          .called(1);
    });

    test('should authenticate with username/password', () async {
      // Arrange
      final config = AuthConfig(
        serverUrl: serverUrl,
        username: username,
        password: password,
      );

      // Create client response
      final clientResponse = MockResponse();
      when(() => clientResponse.statusCode).thenReturn(200);
      when(() => clientResponse.body)
          .thenReturn(jsonEncode({'token': validToken}));

      // Verification response
      final verifyResponse = MockResponse();
      when(() => verifyResponse.statusCode).thenReturn(200);
      when(() => verifyResponse.body).thenReturn('[]');

      // Mock client POST for getting token
      when(() => mockClient.post(
            Uri.parse('$serverUrl$clientEndpoint'),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
            encoding: any(named: 'encoding'),
          )).thenAnswer((_) async => clientResponse);

      // Mock client GET for verification
      when(() => mockClient.get(
            Uri.parse('$serverUrl$applicationEndpoint'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => verifyResponse);

      // Mock secure storage
      when(() => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      // Act
      final result = await authService.login(config);

      // Assert
      expect(result.isAuthenticated, true);
      expect(result.serverUrl, serverUrl);
      expect(result.token, validToken);
      expect(result.error, isNull);

      verify(() =>
              mockSecureStorage.write(key: 'gotify_token', value: validToken))
          .called(1);
    });

    test('should handle invalid server URL', () async {
      // Arrange
      final config = AuthConfig(
        serverUrl: 'invalid-url',
        clientToken: validToken,
      );

      // Act
      final result = await authService.login(config);

      // Assert
      expect(result.isAuthenticated, false);
      expect(result.error, contains('Invalid'));
      verifyNever(() => mockClient.get(any(), headers: any(named: 'headers')));
    });

    test('should handle authentication failure', () async {
      // Arrange
      final config = AuthConfig(
        serverUrl: serverUrl,
        clientToken: 'invalid_token',
      );

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(401);
      when(() => mockResponse.body)
          .thenReturn(jsonEncode({'error': 'Invalid token'}));
      when(() => mockResponse.reasonPhrase).thenReturn('Unauthorized');

      when(() => mockClient.get(
            Uri.parse('$serverUrl$applicationEndpoint'),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.login(config);

      // Assert
      expect(result.isAuthenticated, false);
      expect(result.error, contains('Invalid token'));
    });
  });

  group('logout', () {
    test('should clear stored authentication data', () async {
      // Arrange
      when(() => mockSecureStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      SharedPreferences.setMockInitialValues({
        'gotify_auth': jsonEncode({
          'isAuthenticated': true,
          'serverUrl': serverUrl,
        }),
      });

      // Act
      await authService.logout();

      // Assert
      verify(() => mockSecureStorage.delete(key: 'gotify_token')).called(1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('gotify_auth'), null);
    });
  });
}
