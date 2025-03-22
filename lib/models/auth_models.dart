class AuthConfig {
  final String serverUrl;
  final String? username;
  final String? password;
  final String? clientToken;

  AuthConfig({
    required this.serverUrl,
    this.username,
    this.password,
    this.clientToken,
  });
}

class AuthState {
  final bool isAuthenticated;
  final String serverUrl;
  final String? clientToken;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.serverUrl,
    this.clientToken,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      serverUrl: '',
      clientToken: null,
      error: null,
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
}
