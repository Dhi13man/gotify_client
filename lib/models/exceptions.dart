/// Base exception class for service-related errors
abstract class BaseException implements Exception {
  final String message;
  final int? statusCode;

  const BaseException(this.message, {this.statusCode});

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Client-related exceptions
class ClientException extends BaseException {
  const ClientException(super.message, {super.statusCode});
}

class ClientValidationException extends BaseException {
  const ClientValidationException(super.message, {super.statusCode = 400});
}

class ClientTimeoutException extends ClientException {
  const ClientTimeoutException(super.message, {super.statusCode = 504});
}

class ClientAuthenticationException extends ClientException {
  const ClientAuthenticationException(super.message, {super.statusCode = 401});
}
