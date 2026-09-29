/// Base exception for TaskFlow infrastructure and data sources.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Server exception thrown when the HTTP API returns an error response.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.details});
}

/// Network exception thrown when socket, connection, or timeout errors occur.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.details});
}

/// Authentication exception thrown on invalid credentials or expired sessions.
class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode, super.details});
}

/// Cache or persistent storage read/write exception.
class CacheException extends AppException {
  const CacheException(super.message, {super.statusCode, super.details});
}
