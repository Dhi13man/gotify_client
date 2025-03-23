import 'package:flutter/material.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/services/auth_service.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:logging/logging.dart';

class AuthProvider extends ChangeNotifier {
  static final _logger = Logger('AuthProvider');

  final AuthService _authService;
  AuthState _authState = AuthState.initial();
  bool _loading = false;

  // Getters
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState.isAuthenticated;
  bool get isLoading => _loading;
  String? get error => _authState.error;

  // Constructor with optional dependency injection for testability
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initAuth();
  }

  /// Initialize authentication by loading saved state
  Future<void> _initAuth() async {
    _setLoading(true);

    try {
      _authState = await _authService.loadAuth();
    } catch (e) {
      _logger.severe('Failed to initialize authentication', e);
      _authState = AuthState.error('Failed to initialize: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Attempt to login using the provided configuration
  Future<bool> login(AuthConfig config) async {
    if (!config.isValid) {
      _authState = AuthState.error(
          'Invalid configuration: Either client token or username/password must be provided');
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      _authState = await _authService.login(config);
      return _authState.isAuthenticated;
    } catch (e) {
      final message = e is AuthServiceException
          ? e.message
          : 'Login failed: ${e.toString()}';
      _logger.warning('Login error', e);
      _authState = AuthState.error(message, config.serverUrl);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout and clear authentication state
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _authState = AuthState.initial();
    } catch (e) {
      _logger.warning('Logout error', e);
      // Still consider user logged out even if there's an error clearing storage
      _authState = AuthState.error('Error during logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear any error state
  void clearError() {
    if (_authState.error != null) {
      _authState = _authState.clearError();
      notifyListeners();
    }
  }

  /// Helper method to update loading state
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
