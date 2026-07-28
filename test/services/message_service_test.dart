import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gotify_client/clients/client_factory.dart';
import 'package:gotify_client/clients/gotify_client.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/services/message_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGotifyClient extends Mock implements GotifyClient {}

void main() {
  late MessageService messageService;
  late MockGotifyClient mockClient;
  late StreamController<Message> messageStreamController;

  const String serverUrl = 'http://gotify.example.com';
  const String authToken = 'valid_token';

  setUp(() {
    mockClient = MockGotifyClient();
    messageStreamController = StreamController<Message>.broadcast();
    when(
      () => mockClient.streamMessages(),
    ).thenAnswer((_) => messageStreamController.stream);

    messageService = MessageService(
      AuthState.authenticated(serverUrl, authToken),
      client: mockClient,
    );
  });

  tearDown(() async {
    messageService.disconnect();
    await messageStreamController.close();
    await ClientFactory.clearClients();
  });

  group('MessageService', () {
    test(
        'constructor_whenAuthStateIsUnauthenticated_'
        'thenThrowsAuthenticationException', () {
      // Arrange
      const AuthState authState = AuthState(
        serverUrl: serverUrl,
        token: authToken,
        isAuthenticated: false,
      );

      // Act
      void constructService() => MessageService(authState);

      // Assert
      expect(
        constructService,
        throwsA(
          isA<ClientAuthenticationException>().having(
            (ClientAuthenticationException exception) => exception.message,
            'message',
            'Not authenticated',
          ),
        ),
      );
    });

    test(
      'constructor_whenAuthTokenIsNull_thenThrowsAuthenticationException',
      () {
        // Arrange
        const AuthState authState = AuthState(
          serverUrl: serverUrl,
          isAuthenticated: true,
        );

        // Act
        void constructService() =>
            MessageService(authState, client: mockClient);

        // Assert
        expect(
          constructService,
          throwsA(
            isA<ClientAuthenticationException>().having(
              (ClientAuthenticationException exception) => exception.message,
              'message',
              'Not authenticated',
            ),
          ),
        );
      },
    );

    test('getMessages_whenClientSucceeds_thenReturnsMessages', () async {
      // Arrange
      final List<Message> messages = <Message>[
        Message(
          id: 1,
          applicationId: 1,
          message: 'Hello',
          title: 'Test',
          priority: 5,
          date: DateTime.utc(2021),
        ),
        Message(
          id: 2,
          applicationId: 2,
          message: 'World',
          title: 'Test 2',
          priority: 3,
          date: DateTime.utc(2021, 1, 2),
        ),
      ];
      final PagedMessages pagedMessages = PagedMessages(
        messages: messages,
        paging: Paging(size: 2, since: 0, limit: 100),
      );
      when(
        () => mockClient.getMessages(),
      ).thenAnswer((_) async => pagedMessages);

      // Act
      final List<Message> result = await messageService.getMessages();

      // Assert
      expect(result, same(messages));
      verifyInOrder(<void Function()>[
        () => mockClient.setToken(authToken, AuthType.clientToken),
        () => mockClient.getMessages(),
      ]);
    });

    test(
        'getMessages_whenAuthenticationFails_'
        'thenPropagatesAuthenticationException', () async {
      // Arrange
      when(() => mockClient.getMessages()).thenThrow(
        const ClientAuthenticationException('Invalid token', statusCode: 401),
      );

      // Act
      final Future<List<Message>> result = messageService.getMessages();

      // Assert
      await expectLater(
        result,
        throwsA(isA<ClientAuthenticationException>()),
      );
      verifyInOrder(<void Function()>[
        () => mockClient.setToken(authToken, AuthType.clientToken),
        () => mockClient.getMessages(),
      ]);
    });

    test(
        'getMessages_whenClientCannotParseResponse_'
        'thenPropagatesFormatException', () async {
      // Arrange
      when(
        () => mockClient.getMessages(),
      ).thenThrow(const ClientFormatException('Invalid message response'));

      // Act
      final Future<List<Message>> result = messageService.getMessages();

      // Assert
      await expectLater(
        result,
        throwsA(isA<ClientFormatException>()),
      );
      verify(() => mockClient.getMessages()).called(1);
    });

    test('sendMessage_whenClientSucceeds_thenReturnsTrue', () async {
      // Arrange
      final Message createdMessage = Message(
        id: 1,
        applicationId: 1,
        message: 'Hello World',
        title: 'Test',
        priority: 5,
        date: DateTime.utc(2021),
      );
      when(
        () => mockClient.createMessage(
          title: 'Test',
          message: 'Hello World',
          priority: 5,
        ),
      ).thenAnswer((_) async => createdMessage);

      // Act
      final bool result = await messageService.sendMessage(
        title: 'Test',
        message: 'Hello World',
        priority: 5,
        applicationToken: 'app_token',
      );

      // Assert
      expect(result, isTrue);
      verifyInOrder(<void Function()>[
        () => mockClient.setToken('app_token', AuthType.appToken),
        () => mockClient.createMessage(
              title: 'Test',
              message: 'Hello World',
              priority: 5,
            ),
        () => mockClient.setToken(authToken, AuthType.clientToken),
      ]);
    });

    test(
      'sendMessage_whenClientFails_thenReturnsFalseAndRestoresToken',
      () async {
        // Arrange
        when(
          () => mockClient.createMessage(
            title: 'Test',
            message: 'Hello World',
            priority: 5,
          ),
        ).thenThrow(
          const ClientServerException('Server error', statusCode: 500),
        );

        // Act
        final bool result = await messageService.sendMessage(
          title: 'Test',
          message: 'Hello World',
          priority: 5,
          applicationToken: 'app_token',
        );

        // Assert
        expect(result, isFalse);
        verifyInOrder(<void Function()>[
          () => mockClient.setToken('app_token', AuthType.appToken),
          () => mockClient.createMessage(
                title: 'Test',
                message: 'Hello World',
                priority: 5,
              ),
          () => mockClient.setToken(authToken, AuthType.clientToken),
        ]);
      },
    );

    test('deleteMessage_whenClientSucceeds_thenReturnsTrue', () async {
      // Arrange
      when(() => mockClient.deleteMessage(123)).thenAnswer((_) async {});

      // Act
      final bool result = await messageService.deleteMessage(123);

      // Assert
      expect(result, isTrue);
      verifyInOrder(<void Function()>[
        () => mockClient.setToken(authToken, AuthType.clientToken),
        () => mockClient.deleteMessage(123),
      ]);
    });

    test('deleteMessage_whenClientFails_thenReturnsFalse', () async {
      // Arrange
      when(() => mockClient.deleteMessage(999)).thenThrow(
        const ClientResourceNotFoundException(
          'Message not found',
          statusCode: 404,
        ),
      );

      // Act
      final bool result = await messageService.deleteMessage(999);

      // Assert
      expect(result, isFalse);
      verifyInOrder(<void Function()>[
        () => mockClient.setToken(authToken, AuthType.clientToken),
        () => mockClient.deleteMessage(999),
      ]);
    });

    test('connect_whenMessageArrives_thenInvokesCallback', () async {
      // Arrange
      final Message receivedMessage = Message(
        id: 1,
        applicationId: 1,
        message: 'Hello',
        date: DateTime.utc(2021),
      );
      final Completer<Message> receivedMessageCompleter = Completer<Message>();

      // Act
      messageService.connect(onMessage: receivedMessageCompleter.complete);
      messageStreamController.add(receivedMessage);
      final Message result = await receivedMessageCompleter.future.timeout(
        const Duration(seconds: 1),
      );

      // Assert
      expect(result, same(receivedMessage));
      verifyInOrder(<void Function()>[
        () => mockClient.setToken(authToken, AuthType.clientToken),
        () => mockClient.streamMessages(),
      ]);
    });
  });
}
