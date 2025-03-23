/// Base exception class for service-related errors
abstract class ServiceException implements Exception {
  final String message;
  final int? statusCode;

  ServiceException(this.message, {this.statusCode});

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Authentication service specific exceptions
class AuthServiceException extends ServiceException {
  AuthServiceException(super.message, {super.statusCode});
}

/// Message service specific exceptions
class MessageServiceException extends ServiceException {
  MessageServiceException(super.message, {super.statusCode});
}

class AuthenticationException extends MessageServiceException {
  AuthenticationException(super.message, {super.statusCode});
}


/// Network-related exceptions
class NetworkException extends ServiceException {
  NetworkException(super.message, {super.statusCode});
}

/// Validation exceptions
class ValidationException extends ServiceException {
  ValidationException(super.message, {super.statusCode});
}