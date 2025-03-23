/// Configuration for authentication
class AuthConfig {
  final String serverUrl;
  final String? username;
  final String? password;
  final String? clientToken;

  const AuthConfig({
    required this.serverUrl,
    this.username,
    this.password,
    this.clientToken,
  });

  /// Check if config has valid credentials (either token or username+password)
  bool get isValid {
    // Token authentication
    if (clientToken != null && clientToken!.isNotEmpty) {
      return true;
    }

    // Username/password authentication
    return username != null &&
        username!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty;
  }

  /// Create a copy with modifications
  AuthConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? clientToken,
  }) {
    return AuthConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      clientToken: clientToken ?? this.clientToken,
    );
  }

  @override
  String toString() => 'AuthConfig(serverUrl: $serverUrl, '
      'username: ${username != null ? '***' : 'null'}, '
      'password: ${password != null ? '***' : 'null'}, '
      'clientToken: ${clientToken != null ? '***' : 'null'})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthConfig &&
        other.serverUrl == serverUrl &&
        other.username == username &&
        other.password == password &&
        other.clientToken == clientToken;
  }

  @override
  int get hashCode =>
      serverUrl.hashCode ^
      username.hashCode ^
      password.hashCode ^
      clientToken.hashCode;
}

/// Authentication state
class AuthState {
  final String serverUrl;
  final String? token;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    required this.serverUrl,
    required this.isAuthenticated,
    this.token,
    this.error,
  });

  /// Initial unauthenticated state
  factory AuthState.initial() {
    return const AuthState(isAuthenticated: false, serverUrl: '');
  }

  /// Error state
  factory AuthState.error(String error, [String serverUrl = '']) {
    return AuthState(
      isAuthenticated: false,
      serverUrl: serverUrl,
      error: error,
    );
  }

  /// Authenticated state
  factory AuthState.authenticated(String serverUrl, String token) {
    return AuthState(
      serverUrl: serverUrl,
      token: token,
      isAuthenticated: true,
    );
  }

  /// Create a new state with cleared error
  AuthState clearError() {
    return AuthState(
      serverUrl: serverUrl,
      token: token,
      isAuthenticated: isAuthenticated,
    );
  }

  /// Create a copy with modifications
  AuthState copyWith({
    String? serverUrl,
    String? token,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      serverUrl: serverUrl ?? this.serverUrl,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }

  @override
  String toString() => 'AuthState('
      'isAuthenticated: $isAuthenticated, '
      'serverUrl: $serverUrl, '
      'clientToken: ${token != null ? '***' : 'null'}, '
      'error: $error)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.serverUrl == serverUrl &&
        other.token == token &&
        other.error == error;
  }

  @override
  int get hashCode =>
      isAuthenticated.hashCode ^
      serverUrl.hashCode ^
      token.hashCode ^
      error.hashCode;
}
