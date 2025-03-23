/// Base exception class for service-related errors
abstract class ServiceException implements Exception {
  final String message;

  ServiceException(this.message);

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Authentication service specific exceptions
class AuthServiceException extends ServiceException {
  AuthServiceException(String message) : super(message);
}

/// Message service specific exceptions
class MessageServiceException extends ServiceException {
  MessageServiceException(String message) : super(message);
}

/// Network-related exceptions
class NetworkException extends ServiceException {
  NetworkException(String message) : super(message);
}

/// Validation exceptions
class ValidationException extends ServiceException {
  ValidationException(String message) : super(message);
}
