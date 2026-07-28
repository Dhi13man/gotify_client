import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotify_client/clients/gotify_client.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:gotify_client/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockGotifyClient extends Mock implements GotifyClient {}

void main() {
  late AuthService authService;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockGotifyClient mockClient;
  late List<String> requestedServerUrls;

  const String serverUrl = 'https://gotify.example.com';
  const String validToken = 'valid_token';
  const String username = 'testuser';
  const String password = 'testpass';

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockClient = MockGotifyClient();
    requestedServerUrls = <String>[];
    authService = AuthService(
      secureStorage: mockSecureStorage,
      clientFactory: (String requestedServerUrl) {
        requestedServerUrls.add(requestedServerUrl);
        return mockClient;
      },
    );
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('AuthService', () {
    test('loadAuth_whenNoDataIsStored_thenReturnsInitialState', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{});

      // Act
      final AuthState result = await authService.loadAuth();

      // Assert
      expect(result, AuthState.initial());
      expect(requestedServerUrls, isEmpty);
      verifyNever(() => mockSecureStorage.read(key: any(named: 'key')));
    });

    test(
      'loadAuth_whenStoredCredentialsAreValid_thenReturnsAuthenticatedState',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues(<String, Object>{
          'gotify_auth': jsonEncode(<String, Object>{
            'isAuthenticated': true,
            'serverUrl': serverUrl,
          }),
        });
        when(
          () => mockSecureStorage.read(key: 'gotify_token'),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockClient.verifyToken(validToken),
        ).thenAnswer((_) async => true);

        // Act
        final AuthState result = await authService.loadAuth();
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(result, AuthState.authenticated(serverUrl, validToken));
        expect(requestedServerUrls, <String>[serverUrl]);
        verify(() => mockClient.verifyToken(validToken)).called(1);
      },
    );

    test(
      'loadAuth_whenSilentVerificationRejectsToken_'
      'thenReturnsStoredStateAndClearsCredentials',
      () async {
        // Arrange
        final Completer<void> tokenDeleted = Completer<void>();
        SharedPreferences.setMockInitialValues(<String, Object>{
          'gotify_auth': jsonEncode(<String, Object>{
            'isAuthenticated': true,
            'serverUrl': serverUrl,
          }),
        });
        when(
          () => mockSecureStorage.read(key: 'gotify_token'),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockClient.verifyToken(validToken),
        ).thenAnswer((_) async => false);
        when(
          () => mockSecureStorage.delete(key: 'gotify_token'),
        ).thenAnswer((_) async => tokenDeleted.complete());

        // Act
        final AuthState result = await authService.loadAuth();
        await tokenDeleted.future;
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(result, AuthState.authenticated(serverUrl, validToken));
        expect(requestedServerUrls, <String>[serverUrl]);
        verify(() => mockClient.verifyToken(validToken)).called(1);
        verify(
          () => mockSecureStorage.delete(key: 'gotify_token'),
        ).called(1);
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        expect(preferences.getString('gotify_auth'), isNull);
      },
    );

    test(
      'loadAuth_whenSilentVerificationThrows_'
      'thenReturnsStoredStateWithoutClearingCredentials',
      () async {
        // Arrange
        final String storedAuth = jsonEncode(<String, Object>{
          'isAuthenticated': true,
          'serverUrl': serverUrl,
        });
        SharedPreferences.setMockInitialValues(<String, Object>{
          'gotify_auth': storedAuth,
        });
        when(
          () => mockSecureStorage.read(key: 'gotify_token'),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockClient.verifyToken(validToken),
        ).thenThrow(const ClientNetworkException('Server unavailable'));

        // Act
        final AuthState result = await authService.loadAuth();
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(result, AuthState.authenticated(serverUrl, validToken));
        expect(requestedServerUrls, <String>[serverUrl]);
        verify(() => mockClient.verifyToken(validToken)).called(1);
        verifyNever(
          () => mockSecureStorage.delete(key: any(named: 'key')),
        );
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        expect(preferences.getString('gotify_auth'), storedAuth);
      },
    );

    test('loadAuth_whenTokenIsMissing_thenReturnsInitialState', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{
        'gotify_auth': jsonEncode(<String, Object>{
          'isAuthenticated': true,
          'serverUrl': serverUrl,
        }),
      });
      when(
        () => mockSecureStorage.read(key: 'gotify_token'),
      ).thenAnswer((_) async => null);

      // Act
      final AuthState result = await authService.loadAuth();

      // Assert
      expect(result, AuthState.initial());
      expect(requestedServerUrls, isEmpty);
      verifyNever(() => mockClient.verifyToken(any()));
    });

    test(
      'login_whenClientTokenIsValid_thenAuthenticatesAndPersistsToken',
      () async {
        // Arrange
        const AuthConfig config = AuthConfig(
          serverUrl: serverUrl,
          clientToken: validToken,
        );
        when(
          () => mockClient.verifyToken(validToken),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final AuthState result = await authService.login(config);

        // Assert
        expect(result, AuthState.authenticated(serverUrl, validToken));
        expect(requestedServerUrls, <String>[serverUrl]);
        verify(() => mockClient.verifyToken(validToken)).called(1);
        verifyNever(() => mockClient.createClientToken(any(), any(), any()));
        verify(
          () => mockSecureStorage.write(key: 'gotify_token', value: validToken),
        ).called(1);
      },
    );

    test(
      'login_whenCredentialsAreValid_thenCreatesClientAndAuthenticates',
      () async {
        // Arrange
        const AuthConfig config = AuthConfig(
          serverUrl: serverUrl,
          username: username,
          password: password,
        );
        when(
          () => mockClient.createClientToken(
            username,
            password,
            'Flutter Client',
          ),
        ).thenAnswer((_) async => validToken);
        when(
          () => mockClient.verifyToken(validToken),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final AuthState result = await authService.login(config);

        // Assert
        expect(result, AuthState.authenticated(serverUrl, validToken));
        expect(requestedServerUrls, <String>[serverUrl]);
        verifyInOrder(<void Function()>[
          () => mockClient.createClientToken(
            username,
            password,
            'Flutter Client',
          ),
          () => mockClient.verifyToken(validToken),
        ]);
        verify(
          () => mockSecureStorage.write(key: 'gotify_token', value: validToken),
        ).called(1);
      },
    );

    test(
      'login_whenServerUrlIsInvalid_thenReturnsValidationErrorWithoutClient',
      () async {
        // Arrange
        const AuthConfig config = AuthConfig(
          serverUrl: 'invalid-url',
          clientToken: validToken,
        );

        // Act
        final AuthState result = await authService.login(config);

        // Assert
        expect(result.isAuthenticated, isFalse);
        expect(result.serverUrl, 'invalid-url');
        expect(result.error, 'Server URL cannot be empty');
        expect(requestedServerUrls, isEmpty);
        verifyNever(() => mockClient.verifyToken(any()));
      },
    );

    test(
      'login_whenTokenVerificationFails_thenReturnsVerificationError',
      () async {
        // Arrange
        const AuthConfig config = AuthConfig(
          serverUrl: serverUrl,
          clientToken: 'invalid_token',
        );
        when(
          () => mockClient.verifyToken('invalid_token'),
        ).thenAnswer((_) async => false);

        // Act
        final AuthState result = await authService.login(config);

        // Assert
        expect(result.isAuthenticated, isFalse);
        expect(result.serverUrl, serverUrl);
        expect(result.error, 'Token verification failed');
        expect(requestedServerUrls, <String>[serverUrl]);
        verify(() => mockClient.verifyToken('invalid_token')).called(1);
        verifyNever(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      },
    );

    test(
      'logout_whenCredentialsAreStored_thenClearsAuthenticationData',
      () async {
        // Arrange
        when(
          () => mockSecureStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});
        SharedPreferences.setMockInitialValues(<String, Object>{
          'gotify_auth': jsonEncode(<String, Object>{
            'isAuthenticated': true,
            'serverUrl': serverUrl,
          }),
        });

        // Act
        await authService.logout();

        // Assert
        verify(() => mockSecureStorage.delete(key: 'gotify_token')).called(1);
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        expect(preferences.getString('gotify_auth'), isNull);
      },
    );
  });
}
