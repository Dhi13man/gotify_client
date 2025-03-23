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

  /// Validates if this configuration can be used for authentication
  bool get isValid =>
      serverUrl.isNotEmpty &&
      (clientToken != null || (username != null && password != null));

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

class AuthState {
  final bool isAuthenticated;
  final String serverUrl;
  final String? clientToken;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    required this.serverUrl,
    this.clientToken,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      serverUrl: '',
      clientToken: null,
      error: null,
    );
  }

  factory AuthState.error(String message, [String serverUrl = '']) {
    return AuthState(
      isAuthenticated: false,
      serverUrl: serverUrl,
      clientToken: null,
      error: message,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    String? serverUrl,
    String? clientToken,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      serverUrl: serverUrl ?? this.serverUrl,
      clientToken: clientToken ?? this.clientToken,
      error: error ?? this.error,
    );
  }

  /// Clears error and returns new state
  AuthState clearError() => copyWith(error: null);

  @override
  String toString() => 'AuthState('
      'isAuthenticated: $isAuthenticated, '
      'serverUrl: $serverUrl, '
      'clientToken: ${clientToken != null ? '***' : 'null'}, '
      'error: $error)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.serverUrl == serverUrl &&
        other.clientToken == clientToken &&
        other.error == error;
  }

  @override
  int get hashCode =>
      isAuthenticated.hashCode ^
      serverUrl.hashCode ^
      clientToken.hashCode ^
      error.hashCode;
}
