import 'package:flutter/material.dart';
import 'package:gotify_client/models/auth_models.dart';
import 'package:gotify_client/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _authState = AuthState.initial();

  bool _loading = false;

  AuthState get authState => _authState;

  bool get isAuthenticated => _authState.isAuthenticated;

  bool get isLoading => _loading;

  String? get error => _authState.error;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _loading = true;
    notifyListeners();

    _authState = await _authService.loadAuth();

    _loading = false;
    notifyListeners();
  }

  Future<bool> login(AuthConfig config) async {
    _loading = true;
    notifyListeners();

    _authState = await _authService.login(config);

    _loading = false;
    notifyListeners();

    return _authState.isAuthenticated;
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();

    await _authService.logout();
    _authState = AuthState.initial();

    _loading = false;
    notifyListeners();
  }
}
