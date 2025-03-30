import 'dart:typed_data';
import 'package:gotify_client/models/application_model.dart';
import 'package:gotify_client/models/client_model.dart';
import 'package:gotify_client/models/health_model.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/models/plugin_model.dart';
import 'package:gotify_client/models/user_model.dart';
import 'package:gotify_client/models/version_model.dart';

/// Authentication types available in Gotify
enum AuthType {
  /// App token for sending messages
  appToken,

  /// Client token for receiving messages and managing resources
  clientToken,

  /// Basic auth for initial login or admin operations
  basic,
}

/// Interface for Gotify client operations
abstract class GotifyClient {
  /// Server URL this client is connected to
  String get serverUrl;

  /// Current authentication type
  AuthType get authType;

  // ----- Authentication Operations -----

  /// Set authentication token
  void setToken(String token, AuthType type);

  /// Set basic authentication
  void setBasicAuth(String username, String password);

  /// Create a client token using username/password authentication
  ///
  /// Creates a new client in Gotify with the given name and returns its token.
  /// This is typically used for initial authentication when a token is not yet available.
  ///
  /// Requires [username] and [password] for basic auth
  /// Returns the token for the newly created client
  Future<String> createClientToken(
    String username,
    String password,
    String clientName,
  );

  /// Verify if a token is valid for authentication
  ///
  /// Attempts to make an authenticated request with the provided token
  /// without changing the client's current authentication state
  ///
  /// [token] The token to verify
  /// Returns true if the token can be used for authentication
  Future<bool> verifyToken(String token);

  /// Close and clean up resources
  Future<void> close();

  // ----- Health & Version -----

  /// Get health information about the server
  Future<Health> getHealth();

  /// Get version information about the server
  Future<VersionInfo> getVersion();

  // ----- Message Operations -----

  /// Get all messages (limited by paging)
  ///
  /// [limit] specifies maximum number of messages to return (max 200)
  /// [since] returns all messages with ID less than this value
  Future<PagedMessages> getMessages({int? limit, int? since});

  /// Get messages from a specific application
  ///
  /// [appId] is the application ID
  /// [limit] specifies maximum number of messages to return (max 200)
  /// [since] returns all messages with ID less than this value
  Future<PagedMessages> getAppMessages(
    int appId, {
    int? limit,
    int? since,
  });

  /// Send a message (requires application token)
  Future<Message> createMessage({
    required String message,
    String? title,
    int? priority,
    Map<String, dynamic>? extras,
  });

  /// Delete a message with specific ID
  Future<void> deleteMessage(int messageId);

  /// Delete all messages
  Future<void> deleteMessages();

  /// Delete all messages from a specific application
  Future<void> deleteAppMessages(int appId);

  /// Connect to WebSocket to receive real-time messages
  Stream<Message> streamMessages();

  // ----- Application Operations -----

  /// Get all applications
  Future<List<Application>> getApplications();

  /// Create an application
  Future<Application> createApplication({
    required String name,
    String? description,
    int? defaultPriority,
  });

  /// Update an application
  Future<Application> updateApplication(
    int appId, {
    required String name,
    String? description,
    int? defaultPriority,
  });

  /// Delete an application
  Future<void> deleteApplication(int appId);

  /// Upload an image for an application
  Future<Application> uploadApplicationImage(int appId, Uint8List imageData);

  /// Delete the image for an application
  Future<void> deleteApplicationImage(int appId);

  // ----- Client Operations -----

  /// Get all clients
  Future<List<Client>> getClients();

  /// Create a client
  Future<Client> createClient({required String name});

  /// Update a client
  Future<Client> updateClient(int clientId, {required String name});

  /// Delete a client
  Future<void> deleteClient(int clientId);

  // ----- User Operations -----

  /// Get all users
  Future<List<User>> getUsers();

  /// Get current user
  Future<User> getCurrentUser();

  /// Get specific user by ID
  Future<User> getUser(int userId);

  /// Create a user
  Future<User> createUser({
    required String name,
    required String password,
    required bool admin,
  });

  /// Update a user
  Future<User> updateUser(
    int userId, {
    required String name,
    required bool admin,
    String? password,
  });

  /// Update current user's password
  Future<void> updateCurrentUserPassword(String password);

  /// Delete a user
  Future<void> deleteUser(int userId);

  // ----- Plugin Operations -----

  /// Get all plugins
  Future<List<PluginConfig>> getPlugins();

  /// Get plugin display information
  Future<String> getPluginDisplay(int pluginId);

  /// Enable a plugin
  Future<void> enablePlugin(int pluginId);

  /// Disable a plugin
  Future<void> disablePlugin(int pluginId);

  /// Get plugin configuration (YAML)
  Future<String> getPluginConfig(int pluginId);

  /// Update plugin configuration (YAML)
  Future<void> updatePluginConfig(int pluginId, String yamlConfig);
}
