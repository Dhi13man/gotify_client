import 'dart:convert';
import 'package:gotify_client/clients/client_factory.dart';
import 'package:gotify_client/clients/gotify_client.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:gotify_client/models/auth_models.dart';

/// Service that handles authentication operations with the Gotify server
class AuthService {
  // Constants
  static const String _authKey = 'gotify_auth';
  static const String _tokenKey = 'gotify_token';
  static const String _clientName = 'Flutter Client';

  static final _logger = Logger('AuthService');

  final FlutterSecureStorage _secureStorage;

  /// Creates a new AuthService with the given secure storage
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
      if (token == null ||
          authMap['serverUrl'] == null ||
          authMap['serverUrl'].isEmpty) {
        return AuthState.initial();
      }

      final String serverUrl = authMap['serverUrl'];
      final bool isAuthenticated =
          authMap['isAuthenticated'] == true && token.isNotEmpty;

      // Verify token silently - don't block UI if this fails
      if (isAuthenticated) {
        _verifyTokenSilently(serverUrl, token);
      }

      return AuthState(
        isAuthenticated: isAuthenticated,
        serverUrl: serverUrl,
        token: token,
        error: null,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error loading auth data', e, stackTrace);
      return AuthState.initial();
    }
  }

  /// Attempts to login with the provided configuration
  Future<AuthState> login(AuthConfig config) async {
    if (!config.isValid) {
      return AuthState.error('Invalid authentication configuration');
    }

    // Normalize and validate server URL
    final String serverUrl = _normalizeServerUrl(config.serverUrl);
    if (serverUrl.isEmpty) {
      return AuthState.error('Server URL cannot be empty', config.serverUrl);
    }

    try {
      _logger.info('Attempting login to server: $serverUrl');

      final GotifyClient client = ClientFactory.getClient(serverUrl);
      String? token = config.clientToken;

      // If username/password is provided, get token via client creation
      if (token == null && config.username != null && config.password != null) {
        try {
          token = await client.createClientToken(
            config.username!,
            config.password!,
            _clientName,
          );
        } catch (e) {
          _logger.warning('Failed to get token using credentials', e);
          return AuthState.error(
            'Login failed: Invalid username or password',
            serverUrl,
          );
        }
      }

      if (token == null || token.isEmpty) {
        return AuthState.error(
          'No valid authentication method provided',
          serverUrl,
        );
      }

      // Verify token works by making a test request
      try {
        _logger.info('Verifying token validity');
        final bool isValid = await client.verifyToken(token);

        if (!isValid) {
          _logger.warning('Token verification failed');
          return AuthState.error('Token verification failed', serverUrl);
        }

        // Store auth data
        final authState = AuthState.authenticated(serverUrl, token);
        await _saveAuth(authState);
        return authState;
      } catch (e) {
        _logger.severe('Error during token verification', e);
        return AuthState.error(
          'Could not verify token: ${e.toString()}',
          serverUrl,
        );
      }
    } on ClientAuthenticationException catch (e) {
      _logger.warning('Authentication exception during login', e);
      return AuthState.error('Authentication failed: ${e.message}', serverUrl);
    } on ClientException catch (e) {
      _logger.warning('Client exception during login', e);
      return AuthState.error('Server error: ${e.message}', serverUrl);
    } catch (e) {
      _logger.severe('Unexpected error during login', e);
      return AuthState.error(
        'Unexpected error: ${e.toString()}',
        serverUrl,
      );
    }
  }

  /// Logs the user out by clearing stored credentials
  Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_authKey),
        _secureStorage.delete(key: _tokenKey),
      ]);
      ClientFactory.clearClients();
    } catch (e, stackTrace) {
      _logger.severe('Error during logout', e, stackTrace);
      throw ClientException('Failed to logout: ${e.toString()}');
    }
  }

  /// Normalizes server URL by removing trailing slashes and validating format
  String _normalizeServerUrl(String url) {
    try {
      var serverUrl = url.trim();
      // Remove trailing slashes
      serverUrl = serverUrl.replaceAll(RegExp(r'/+$'), '');

      // Parse and validate URL
      final uri = Uri.parse(serverUrl);
      if (uri.host.isEmpty) {
        throw const ClientValidationException('Invalid host in URL');
      }
      if (!uri.hasScheme || !['http', 'https'].contains(uri.scheme)) {
        throw const ClientValidationException('Invalid URL scheme');
      }
      return serverUrl;
    } catch (e, stackTrace) {
      _logger.warning('Error normalizing server URL: $url', e, stackTrace);
      return '';
    }
  }

  /// Verify token silently in the background to detect invalid tokens
  Future<void> _verifyTokenSilently(String serverUrl, String token) async {
    try {
      _logger.fine('Silently verifying stored token');
      final GotifyClient client = ClientFactory.getClient(serverUrl);

      final bool isValid = await client.verifyToken(token);

      if (!isValid) {
        // Token is no longer valid, clear stored auth data
        _logger.info(
            'Stored token is no longer valid, clearing authentication data');
        await logout();
      }
    } catch (e) {
      _logger.warning('Error during silent token verification', e);
      // Don't throw - this is a background verification
    }
  }

  /// Saves authentication state securely
  Future<void> _saveAuth(AuthState authState) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

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
    } catch (e, stackTrace) {
      _logger.severe('Error saving auth data', e, stackTrace);
      throw ClientException(
          'Failed to save authentication data: ${e.toString()}');
    }
  }
}
