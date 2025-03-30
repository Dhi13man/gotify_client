/// Base exception class for client errors
class ClientException implements Exception {
  /// Error message
  final String message;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Creates a client exception
  const ClientException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ClientException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when authentication fails
class ClientAuthenticationException extends ClientException {
  /// Creates an authentication exception
  const ClientAuthenticationException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);

  @override
  String toString() =>
      'Authentication error: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when input validation fails
class ClientValidationException extends ClientException {
  /// Creates a validation exception
  const ClientValidationException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);

  @override
  String toString() =>
      'Validation error: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when a request times out
class ClientTimeoutException extends ClientException {
  /// Creates a timeout exception
  const ClientTimeoutException(String message) : super(message);

  @override
  String toString() => 'Request timeout: $message';
}

/// Exception thrown when a network error occurs
class ClientNetworkException extends ClientException {
  /// Creates a network exception
  const ClientNetworkException(String message) : super(message);

  @override
  String toString() => 'Network error: $message';
}

/// Exception thrown when a resource isn't found
class ClientResourceNotFoundException extends ClientException {
  /// Creates a not found exception
  const ClientResourceNotFoundException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);

  @override
  String toString() =>
      'Resource not found: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when the server returns an error
class ClientServerException extends ClientException {
  /// Creates a server exception
  const ClientServerException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);

  @override
  String toString() =>
      'Server error: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when data formatting fails
class ClientFormatException extends ClientException {
  /// Creates a format exception
  const ClientFormatException(String message) : super(message);

  @override
  String toString() => 'Format error: $message';
}
