import 'dart:convert';
import 'package:gotify_client/models/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:gotify_client/models/auth_models.dart';

class AuthService {
  // Constants
  static const String _authKey = 'gotify_auth';
  static const String _tokenKey = 'gotify_token';
  static const String _clientEndpoint = '/client';
  static const String _applicationEndpoint = '/application';
  static const Duration _requestTimeout = Duration(seconds: 10);

  static final _logger = Logger('AuthService');

  final FlutterSecureStorage _secureStorage;

  AuthService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Loads authentication state from secure storage
  Future<AuthState> loadAuth() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? authData = prefs.getString(_authKey);
      if (authData == null) {
        return AuthState.initial();
      }

      final Map<String, dynamic> authMap = jsonDecode(authData);
      final token = await _secureStorage.read(key: _tokenKey);
      return AuthState(
        isAuthenticated: authMap['isAuthenticated'] == true && token != null,
        serverUrl: authMap['serverUrl'] ?? '',
        token: token,
        error: null,
      );
    } catch (e) {
      _logger.severe('Error loading auth data', e);
      return AuthState.initial();
    }
  }

  /// Attempts to login with the provided configuration
  Future<AuthState> login(AuthConfig config) async {
    // Normalize and validate server URL
    final String serverUrl = _normalizeServerUrl(config.serverUrl);
    if (serverUrl.isEmpty) {
      return _createErrorState(serverUrl, 'Server URL cannot be empty');
    }

    try {
      String? token = config.clientToken;

      // If username/password is provided, get token via client creation
      if (token == null && config.username != null && config.password != null) {
        token = await _getTokenFromCredentials(
          serverUrl,
          config.username!,
          config.password!,
        );
      }

      if (token == null || token.isEmpty) {
        return _createErrorState(
          serverUrl,
          'No valid authentication method provided',
        );
      }

      // Verify token works by making a test request
      await _verifyToken(serverUrl, token);

      // Store auth data
      final authState = AuthState(
        isAuthenticated: true,
        serverUrl: serverUrl,
        token: token,
        error: null,
      );
      await _saveAuth(authState);
      return authState;
    } catch (e) {
      return _createErrorState(
        config.serverUrl,
        'Authentication failed: ${e.toString().split('\n').first}',
      );
    }
  }

  /// Logs the user out by clearing stored credentials
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_authKey),
        _secureStorage.delete(key: _tokenKey),
      ]);
    } catch (e) {
      throw ClientAuthenticationException('Failed to logout: ${e.toString()}');
    }
  }

  /// Normalizes server URL by removing trailing slashes and validating format
  String _normalizeServerUrl(String url) {
    try {
      var serverUrl = url.trim();
      // Remove trailing slashes
      while (serverUrl.endsWith('/')) {
        serverUrl = serverUrl.substring(0, serverUrl.length - 1);
      }

      // Parse and validate URL
      final uri = Uri.parse(serverUrl);
      if (uri.host.isEmpty) {
        throw ClientValidationException('Invalid host in URL');
      }
      if (!uri.hasScheme || !['http', 'https'].contains(uri.scheme)) {
        throw ClientValidationException('Invalid URL scheme');
      }
      return serverUrl;
    } catch (e, stackTrace) {
      _logger.severe('Error normalizing server URL', e, stackTrace);
      return url;
    }
  }

  /// Gets a client token using username and password authentication
  Future<String> _getTokenFromCredentials(
      String serverUrl, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl$_clientEndpoint'),
        body: jsonEncode({'name': 'Flutter Client'}),
        encoding: Encoding.getByName('utf-8'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/json',
        },
      ).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw ClientAuthenticationException(
          'Failed to create client: HTTP ${response.statusCode} - ${_getErrorFromResponse(response)}',
        );
      }

      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      if (token == null || token is! String || token.isEmpty) {
        throw ClientAuthenticationException(
          'Server returned invalid token format',
        );
      }
      return token;
    } on ClientException {
      rethrow;
    } catch (e) {
      throw ClientAuthenticationException(
        'Failed to get token: ${e.toString()}',
      );
    }
  }

  /// Verifies that a token is valid by making a test request
  Future<void> _verifyToken(String serverUrl, String token) async {
    try {
      final verifyResponse = await http.get(
        Uri.parse('$serverUrl$_applicationEndpoint'),
        headers: {'X-Gotify-Key': token},
      ).timeout(_requestTimeout);

      if (verifyResponse.statusCode != 200) {
        throw ClientAuthenticationException(
          'Invalid token: HTTP ${verifyResponse.statusCode} - ${_getErrorFromResponse(verifyResponse)}',
        );
      }
    } on ClientException {
      rethrow;
    } catch (e) {
      throw ClientAuthenticationException(
        'Token verification failed: ${e.toString()}',
      );
    }
  }

  /// Extracts error message from HTTP response
  String _getErrorFromResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['error'] ?? body['message'] ?? 'Unknown error';
    } catch (e) {
      _logger.severe('Error parsing response', e);
      return response.reasonPhrase ?? e.toString();
    }
  }

  /// Helper method to create error auth states
  AuthState _createErrorState(String serverUrl, String errorMessage) {
    return AuthState(
      isAuthenticated: false,
      serverUrl: serverUrl,
      token: null,
      error: errorMessage,
    );
  }

  /// Saves authentication state securely
  Future<void> _saveAuth(AuthState authState) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store non-sensitive data in SharedPreferences
      await prefs.setString(
        _authKey,
        jsonEncode({
          'isAuthenticated': authState.isAuthenticated,
          'serverUrl': authState.serverUrl,
        }),
      );

      // Store token securely if present
      if (authState.token != null && authState.token!.isNotEmpty) {
        await _secureStorage.write(
          key: _tokenKey,
          value: authState.token!,
        );
      }
    } catch (e) {
      _logger.severe('Error saving auth data', e);
    }
  }
}
