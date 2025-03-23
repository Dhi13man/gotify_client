import 'package:flutter/material.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/services/auth_service.dart';
import 'package:gotify_client/models/exceptions.dart';
import 'package:logging/logging.dart';

class AuthProvider extends ChangeNotifier {
  static const String initializationErrorPrefix = 'Failed to initialize: ';
  static const String loginErrorPrefix = 'Login failed: ';
  static const String logoutErrorPrefix = 'Error during logout: ';
  static const String invalidConfigError =
      'Invalid configuration: Either client token or username/password must be provided';

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
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize authentication', e, stackTrace);
      final errorMessage =
          AuthOperations.getErrorMessage(e, initializationErrorPrefix);
      _authState = AuthState.error(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Attempt to login using the provided configuration
  Future<bool> login(AuthConfig config) async {
    if (!config.isValid) {
      _authState = AuthState.error(invalidConfigError);
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      _authState = await _authService.login(config);
      return _authState.isAuthenticated;
    } catch (e, stackTrace) {
      _logger.warning('Login error', e, stackTrace);
      final String errorMessage =
          AuthOperations.getErrorMessage(e, loginErrorPrefix);
      _authState = AuthState.error(errorMessage);
      notifyListeners();
      return _authState.isAuthenticated;
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
    } catch (e, stackTrace) {
      _logger.warning('Logout error', e, stackTrace);
      // Still consider user logged out even if there's an error clearing storage
      final String errorMessage =
          AuthOperations.getErrorMessage(e, logoutErrorPrefix);
      _authState = AuthState.error(errorMessage);
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

/// Helper for authentication operations
class AuthOperations {
  static String getErrorMessage(Object e, String prefix) {
    if (e is AuthServiceException) {
      return e.message;
    }
    return '$prefix${e.toString()}';
  }

  // Private constructor to prevent instantiation
  AuthOperations._();
}
