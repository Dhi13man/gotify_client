/// Base exception class for service-related errors
abstract class ServiceException implements Exception {
  final String message;

  ServiceException(this.message);

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Authentication service specific exceptions
class AuthServiceException extends ServiceException {
  AuthServiceException(super.message);
}

/// Message service specific exceptions
class MessageServiceException extends ServiceException {
  MessageServiceException(super.message);
}

/// Network-related exceptions
class NetworkException extends ServiceException {
  NetworkException(super.message);
}

/// Validation exceptions
class ValidationException extends ServiceException {
  ValidationException(super.message);
}
