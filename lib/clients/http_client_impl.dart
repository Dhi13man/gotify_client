import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:gotify_client/clients/gotify_client.dart';
import 'package:gotify_client/models/application_model.dart';
import 'package:gotify_client/models/client_model.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:gotify_client/models/health_model.dart';
import 'package:gotify_client/models/message_model.dart';
import 'package:gotify_client/models/plugin_model.dart';
import 'package:gotify_client/models/user_model.dart';
import 'package:gotify_client/models/version_model.dart';

/// HTTP implementation of the GotifyClient interface
class GotifyHttpClient implements GotifyClient {
  // API endpoint constants
  static const String _messageEndpoint = '/message';
  static const String _applicationEndpoint = '/application';
  static const String _clientEndpoint = '/client';
  static const String _userEndpoint = '/user';
  static const String _currentUserEndpoint = '/current/user';
  static const String _pluginEndpoint = '/plugin';
  static const String _healthEndpoint = '/health';
  static const String _versionEndpoint = '/version';
  static const String _streamEndpoint = '/stream';

  // HTTP constants
  static const int _timeoutSeconds = 10;
  static const String _jsonContentType = 'application/json';
  static const String _yamlContentType = 'application/x-yaml';
  static const String _authHeader = 'Authorization';
  static const String _contentTypeHeader = 'Content-Type';
  static const String _gotifyKeyHeader = 'X-Gotify-Key';

  // Private fields
  final String _serverUrl;
  final Logger _logger = Logger('GotifyClient');
  final http.Client _httpClient;
  String? _token;
  String? _username;
  String? _password;
  AuthType _authType = AuthType.clientToken;

  @override
  String get serverUrl => _serverUrl;

  @override
  AuthType get authType => _authType;

  /// Creates a new HTTP client instance for the specified server
  GotifyHttpClient(String serverUrl, {http.Client? httpClient})
      : _serverUrl = _normalizeUrl(serverUrl),
        _httpClient = httpClient ?? http.Client();

  static String _normalizeUrl(String url) {
    return url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  @override
  void setToken(String token, AuthType type) {
    _token = token;
    _authType = type;
    _username = null;
    _password = null;
  }

  @override
  void setBasicAuth(String username, String password) {
    _username = username;
    _password = password;
    _authType = AuthType.basic;
    _token = null;
  }

  @override
  Future<void> close() async {
    _httpClient.close();
  }

  // Helper method to build authentication headers
  Map<String, String> _buildAuthHeaders() {
    if (_authType == AuthType.basic && _username != null && _password != null) {
      final String credentials =
          base64Encode(utf8.encode('$_username:$_password'));
      return {_authHeader: 'Basic $credentials'};
    } else if (_token != null) {
      // Support both authorization methods for token
      return {
        _authHeader: 'Bearer $_token',
        _gotifyKeyHeader: _token!,
      };
    }
    return {};
  }

  // Helper method to handle HTTP errors uniformly
  void _handleHttpError(http.Response response, String endpoint) {
    final int statusCode = response.statusCode;
    String message;

    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      message =
          body['error'] ?? body['errorDescription'] ?? 'Unknown server error';
    } catch (_) {
      message = response.body.isNotEmpty
          ? response.body.substring(0, response.body.length.clamp(0, 100))
          : 'Unknown error';
    }

    if (statusCode == 401) {
      throw ClientAuthenticationException(message, statusCode: statusCode);
    } else if (statusCode == 400) {
      throw ClientValidationException(message, statusCode: statusCode);
    } else if (statusCode == 404) {
      throw ClientResourceNotFoundException(
        'Resource not found: $endpoint',
        statusCode: statusCode,
      );
    } else if (statusCode >= 500) {
      throw ClientServerException(
        'Server error: $message',
        statusCode: statusCode,
      );
    } else {
      throw ClientException(
        'Request failed with status $statusCode: $message',
        statusCode: statusCode,
      );
    }
  }

  /// Execute a request with proper error handling
  Future<T> _executeRequest<T>(
    Future<T> Function() requestFn,
    String endpoint,
  ) async {
    try {
      return await requestFn().timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () =>
            throw const ClientTimeoutException('Request timed out'),
      );
    } on ClientException {
      rethrow;
    } on TimeoutException {
      throw const ClientTimeoutException('Request timed out');
    } on SocketException catch (e) {
      final String message = 'Network connection error: ${e.message}';
      _logger.severe('Network error during request to $endpoint: $message');
      throw ClientNetworkException(message);
    } on HttpException catch (e) {
      final String message = 'HTTP error: ${e.message}';
      _logger.severe('HTTP error during request to $endpoint: $message');
      throw ClientException(message);
    } on FormatException catch (e) {
      final String message = 'Data formatting error: ${e.message}';
      _logger.severe('Format error during request to $endpoint: $message');
      throw ClientFormatException(message);
    } catch (e, stackTrace) {
      _logger.severe('Error during request to $endpoint', e, stackTrace);
      throw ClientException('Request failed: ${e.toString()}');
    }
  }

  /// Generic GET request method
  Future<dynamic> _get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
    Map<String, String>? queryParams,
  }) async {
    return _executeRequest(() async {
      final Uri url = Uri.parse(_serverUrl + endpoint).replace(
        queryParameters: queryParams,
      );

      final headers = {
        ..._buildAuthHeaders(),
        if (additionalHeaders != null) ...additionalHeaders,
      };

      final response = await _httpClient.get(url, headers: headers);

      if (response.statusCode != 200) {
        _handleHttpError(response, endpoint);
      }

      if (response.body.isEmpty) {
        return null;
      }

      return _parseJsonResponse(response.body, endpoint);
    }, endpoint);
  }

  /// Generic POST request method
  Future<dynamic> _post(
    String endpoint, {
    dynamic body,
    String contentType = _jsonContentType,
    Map<String, String>? additionalHeaders,
  }) async {
    return _executeRequest(() async {
      final Uri url = Uri.parse(_serverUrl + endpoint);

      final Map<String, String> headers = {
        _contentTypeHeader: contentType,
        ..._buildAuthHeaders(),
        if (additionalHeaders != null) ...additionalHeaders,
      };

      Object? requestBody;
      if (body != null) {
        requestBody = contentType == _jsonContentType
            ? jsonEncode(body)
            : body.toString();
      }

      final response = await _httpClient.post(
        url,
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _handleHttpError(response, endpoint);
      }

      if (response.body.isEmpty) {
        return null;
      }

      return _parseJsonResponse(response.body, endpoint);
    }, endpoint);
  }

  /// Generic PUT request method
  Future<dynamic> _put(
    String endpoint, {
    dynamic body,
    String contentType = _jsonContentType,
    Map<String, String>? additionalHeaders,
  }) async {
    return _executeRequest(() async {
      final Uri url = Uri.parse(_serverUrl + endpoint);

      final Map<String, String> headers = {
        _contentTypeHeader: contentType,
        ..._buildAuthHeaders(),
        if (additionalHeaders != null) ...additionalHeaders,
      };

      Object? requestBody;
      if (body != null) {
        requestBody = contentType == _jsonContentType
            ? jsonEncode(body)
            : body.toString();
      }

      final response = await _httpClient.put(
        url,
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _handleHttpError(response, endpoint);
      }

      if (response.body.isEmpty) {
        return null;
      }

      return _parseJsonResponse(response.body, endpoint);
    }, endpoint);
  }

  /// Generic DELETE request method
  Future<void> _delete(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    await _executeRequest(() async {
      final Uri url = Uri.parse(_serverUrl + endpoint);

      final headers = {
        ..._buildAuthHeaders(),
        if (additionalHeaders != null) ...additionalHeaders,
      };

      final response = await _httpClient.delete(url, headers: headers);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _handleHttpError(response, endpoint);
      }

      return;
    }, endpoint);
  }

  /// Parse JSON response safely
  dynamic _parseJsonResponse(String responseBody, String endpoint) {
    if (responseBody.isEmpty) return null;

    try {
      return jsonDecode(responseBody);
    } on FormatException {
      _logger.warning('Invalid JSON response from server: $responseBody');
      throw const ClientFormatException(
          'Server returned invalid response format');
    }
  }

  // ----- Health & Version Implementations -----

  @override
  Future<Health> getHealth() async {
    final data = await _get(_healthEndpoint);
    return Health.fromJson(data);
  }

  @override
  Future<VersionInfo> getVersion() async {
    final data = await _get(_versionEndpoint);
    return VersionInfo.fromJson(data);
  }

  // ----- Message Implementations -----

  @override
  Future<PagedMessages> getMessages({int? limit, int? since}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (since != null) queryParams['since'] = since.toString();

    final data = await _get(_messageEndpoint, queryParams: queryParams);
    return PagedMessages.fromJson(data);
  }

  @override
  Future<PagedMessages> getAppMessages(
    int appId, {
    int? limit,
    int? since,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (since != null) queryParams['since'] = since.toString();

    final data = await _get(
      '$_applicationEndpoint/$appId$_messageEndpoint',
      queryParams: queryParams,
    );
    return PagedMessages.fromJson(data);
  }

  @override
  Future<Message> createMessage({
    required String message,
    String? title,
    int? priority,
    Map<String, dynamic>? extras,
  }) async {
    if (_authType != AuthType.appToken) {
      throw const ClientAuthenticationException(
          'Creating messages requires an application token');
    }

    final Map<String, dynamic> body = {
      'message': message,
      if (title != null) 'title': title,
      if (priority != null) 'priority': priority,
      if (extras != null) 'extras': extras,
    };

    final data = await _post(_messageEndpoint, body: body);
    return Message.fromJson(data);
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    await _delete('$_messageEndpoint/$messageId');
  }

  @override
  Future<void> deleteMessages() async {
    await _delete(_messageEndpoint);
  }

  @override
  Future<void> deleteAppMessages(int appId) async {
    await _delete('$_applicationEndpoint/$appId$_messageEndpoint');
  }

  @override
  Stream<Message> streamMessages() {
    if (_token == null) {
      throw const ClientAuthenticationException(
          'Authentication token is required for streaming messages');
    }

    final wsUrl = _serverUrl.replaceFirst(RegExp(r'^http'), 'ws');
    final uri = Uri.parse('$wsUrl$_streamEndpoint');

    // Add auth token as query parameter for WebSocket
    final uriWithAuth = uri.replace(
      queryParameters: {'token': _token},
    );

    final WebSocketChannel channel = WebSocketChannel.connect(uriWithAuth);

    return channel.stream.map((dynamic data) {
      if (data is String) {
        try {
          return Message.fromJson(jsonDecode(data));
        } catch (e, stackTrace) {
          _logger.warning('Error parsing WebSocket message', e, stackTrace);
          throw ClientFormatException(
              'Invalid message format: ${e.toString()}');
        }
      } else {
        throw const ClientFormatException('Unexpected WebSocket data format');
      }
    });
  }

  // ----- Application Operations -----

  @override
  Future<List<Application>> getApplications() async {
    final data = await _get(_applicationEndpoint);

    if (data is! List) {
      throw const ClientFormatException(
          'Expected applications list but got different format');
    }

    return data
        .cast<Map<String, dynamic>>()
        .map((json) => Application.fromJson(json))
        .toList();
  }

  @override
  Future<Application> createApplication({
    required String name,
    String? description,
    int? defaultPriority,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      if (description != null) 'description': description,
      if (defaultPriority != null) 'defaultPriority': defaultPriority,
    };

    final data = await _post(_applicationEndpoint, body: body);
    return Application.fromJson(data);
  }

  @override
  Future<Application> updateApplication(
    int appId, {
    required String name,
    String? description,
    int? defaultPriority,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      if (description != null) 'description': description,
      if (defaultPriority != null) 'defaultPriority': defaultPriority,
    };

    final data = await _put('$_applicationEndpoint/$appId', body: body);
    return Application.fromJson(data);
  }

  @override
  Future<void> deleteApplication(int appId) async {
    await _delete('$_applicationEndpoint/$appId');
  }

  @override
  Future<Application> uploadApplicationImage(
      int appId, Uint8List imageData) async {
    return _executeRequest(() async {
      final uri = Uri.parse('$_serverUrl$_applicationEndpoint/$appId/image');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add auth headers
      request.headers.addAll(_buildAuthHeaders());

      // Add the file
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageData,
        filename: 'image.png', // Default filename
      ));

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        _handleHttpError(response, '$_applicationEndpoint/$appId/image');
      }

      final data = _parseJsonResponse(
          response.body, '$_applicationEndpoint/$appId/image');
      return Application.fromJson(data);
    }, '$_applicationEndpoint/$appId/image');
  }

  @override
  Future<void> deleteApplicationImage(int appId) async {
    await _delete('$_applicationEndpoint/$appId/image');
  }

  // ----- Client Operations -----

  @override
  Future<List<Client>> getClients() async {
    final data = await _get(_clientEndpoint);

    if (data is! List) {
      throw const ClientFormatException(
          'Expected clients list but got different format');
    }

    return data
        .cast<Map<String, dynamic>>()
        .map((json) => Client.fromJson(json))
        .toList();
  }

  @override
  Future<Client> createClient({required String name}) async {
    final data = await _post(_clientEndpoint, body: {'name': name});
    return Client.fromJson(data);
  }

  @override
  Future<Client> updateClient(int clientId, {required String name}) async {
    final data = await _put('$_clientEndpoint/$clientId', body: {'name': name});
    return Client.fromJson(data);
  }

  @override
  Future<void> deleteClient(int clientId) async {
    await _delete('$_clientEndpoint/$clientId');
  }

  // ----- User Operations -----

  @override
  Future<List<User>> getUsers() async {
    final data = await _get(_userEndpoint);

    if (data is! List) {
      throw const ClientFormatException(
          'Expected users list but got different format');
    }

    return data
        .cast<Map<String, dynamic>>()
        .map((json) => User.fromJson(json))
        .toList();
  }

  @override
  Future<User> getCurrentUser() async {
    final data = await _get(_currentUserEndpoint);
    return User.fromJson(data);
  }

  @override
  Future<User> getUser(int userId) async {
    final data = await _get('$_userEndpoint/$userId');
    return User.fromJson(data);
  }

  @override
  Future<User> createUser({
    required String name,
    required String password,
    required bool admin,
  }) async {
    final data = await _post(_userEndpoint, body: {
      'name': name,
      'pass': password,
      'admin': admin,
    });
    return User.fromJson(data);
  }

  @override
  Future<User> updateUser(
    int userId, {
    required String name,
    required bool admin,
    String? password,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'admin': admin,
    };

    if (password != null && password.isNotEmpty) {
      body['pass'] = password;
    }

    final data = await _post('$_userEndpoint/$userId', body: body);
    return User.fromJson(data);
  }

  @override
  Future<void> updateCurrentUserPassword(String password) async {
    await _post('$_currentUserEndpoint/password', body: {'pass': password});
  }

  @override
  Future<void> deleteUser(int userId) async {
    await _delete('$_userEndpoint/$userId');
  }

  // ----- Plugin Operations -----

  @override
  Future<List<PluginConfig>> getPlugins() async {
    final data = await _get(_pluginEndpoint);

    if (data is! List) {
      throw const ClientFormatException(
          'Expected plugins list but got different format');
    }

    return data
        .cast<Map<String, dynamic>>()
        .map((json) => PluginConfig.fromJson(json))
        .toList();
  }

  @override
  Future<String> getPluginDisplay(int pluginId) async {
    final data = await _get('$_pluginEndpoint/$pluginId/display');

    if (data is String) {
      return data;
    } else if (data is Map &&
        data.containsKey('data') &&
        data['data'] is String) {
      return data['data'];
    } else {
      throw const ClientFormatException(
          'Expected string data from plugin display endpoint');
    }
  }

  @override
  Future<void> enablePlugin(int pluginId) async {
    await _post('$_pluginEndpoint/$pluginId/enable');
  }

  @override
  Future<void> disablePlugin(int pluginId) async {
    await _post('$_pluginEndpoint/$pluginId/disable');
  }

  @override
  Future<String> getPluginConfig(int pluginId) async {
    return _executeRequest(() async {
      final Uri url = Uri.parse('$_serverUrl$_pluginEndpoint/$pluginId/config');

      final headers = _buildAuthHeaders();

      final response = await _httpClient.get(url, headers: headers);

      if (response.statusCode != 200) {
        _handleHttpError(response, '$_pluginEndpoint/$pluginId/config');
      }

      return response.body; // Raw YAML text
    }, '$_pluginEndpoint/$pluginId/config');
  }

  @override
  Future<void> updatePluginConfig(int pluginId, String yamlConfig) async {
    await _post(
      '$_pluginEndpoint/$pluginId/config',
      body: yamlConfig,
      contentType: _yamlContentType,
    );
  }

  // ----- Authentication Operations -----

  @override
  Future<bool> verifyToken(String token) async {
    // Create a temporary client to avoid modifying current state
    final temporaryClient = GotifyHttpClient(_serverUrl);
    try {
      // Try to get current user with this token to verify it
      temporaryClient.setToken(token, AuthType.clientToken);
      await temporaryClient.getCurrentUser();
      return true;
    } on ClientAuthenticationException catch (e, stackTrace) {
      _logger.severe(
        'Authentication error during token verification',
        e,
        stackTrace,
      );
      return false;
    } on ClientException catch (e, stackTrace) {
      _logger.warning('Token verification failed', e, stackTrace);
      return false;
    } catch (e) {
      _logger.warning('Unexpected error during token verification', e);
      return false;
    } finally {
      // Clean up temporary client
      await temporaryClient.close();
    }
  }

  @override
  Future<String> createClientToken(
    String username,
    String password,
    String clientName,
  ) async {
    // Create a temporary client for this operation to avoid modifying current state
    final temporaryClient = GotifyHttpClient(_serverUrl);
    try {
      // Set basic auth for creating a client
      temporaryClient.setBasicAuth(username, password);

      // Create a client and get its token
      final client = await temporaryClient.createClient(name: clientName);
      return client.token;
    } finally {
      // Clean up temporary client
      await temporaryClient.close();
    }
  }
}
