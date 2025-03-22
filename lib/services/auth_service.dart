import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:gotify_client/models/auth_models.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _authKey = 'gotify_auth';
  final String _tokenKey = 'gotify_token';
  final Logger _logger = Logger('AuthService');

  Future<AuthState> loadAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authData = prefs.getString(_authKey);

      if (authData != null) {
        final authMap = jsonDecode(authData);
        final token = await _secureStorage.read(key: _tokenKey);

        return AuthState(
          isAuthenticated: authMap['isAuthenticated'] && token != null,
          serverUrl: authMap['serverUrl'] ?? '',
          clientToken: token,
          error: null,
        );
      }
    } catch (e) {
      _logger.severe('Error loading auth data', e);
    }

    return AuthState.initial();
  }

  Future<AuthState> login(AuthConfig config) async {
    try {
      // Validate and normalize server URL
      var serverUrl = config.serverUrl.trim();
      // Remove trailing slashes
      while (serverUrl.endsWith('/')) {
        serverUrl = serverUrl.substring(0, serverUrl.length - 1);
      }

      // Check for invalid port configuration
      final uri = Uri.parse(serverUrl);
      if (uri.port == 0) {
        throw Exception('Invalid port configuration in server URL');
      }

      String? token = config.clientToken;

      // If username/password is provided, get token via client creation
      if (token == null && config.username != null && config.password != null) {
        final response = await http.post(
          Uri.parse('$serverUrl/client'),
          body: jsonEncode({'name': 'Flutter Client'}),
          encoding: Encoding.getByName('utf-8'),
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('${config.username}:${config.password}'))}',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          token = responseData['token'];
        } else {
          throw Exception('Failed to create client: ${response.statusCode}');
        }
      }

      if (token == null) {
        throw Exception('No authentication method provided');
      }

      // Verify token works by making a test request
      final verifyResponse = await http.get(
        Uri.parse('$serverUrl/application'),
        headers: {'X-Gotify-Key': token},
      );

      if (verifyResponse.statusCode != 200) {
        throw Exception('Invalid token');
      }

      // Store auth data
      final authState = AuthState(
        isAuthenticated: true,
        serverUrl: serverUrl,
        clientToken: token,
        error: null,
      );

      await _saveAuth(authState);
      return authState;
    } catch (e) {
      _logger.severe('Login failed', e);
      return AuthState(
        isAuthenticated: false,
        serverUrl: config.serverUrl,
        clientToken: null,
        error: 'Authentication failed: $e',
      );
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authKey);
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      _logger.severe('Logout error', e);
    }
  }

  Future<void> _saveAuth(AuthState authState) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store non-sensitive data in SharedPreferences
      await prefs.setString(
          _authKey,
          jsonEncode({
            'isAuthenticated': authState.isAuthenticated,
            'serverUrl': authState.serverUrl,
          }));

      // Store token securely
      if (authState.clientToken != null) {
        await _secureStorage.write(
          key: _tokenKey,
          value: authState.clientToken!,
        );
      }
    } catch (e) {
      _logger.severe('Error saving auth data', e);
    }
  }
}
