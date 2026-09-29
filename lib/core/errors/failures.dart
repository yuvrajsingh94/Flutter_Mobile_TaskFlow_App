/// Base class for all domain-level failures across TaskFlow Enterprise.
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Server or API failure returned from the backend.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

/// Network connectivity failure (no internet, timeout, DNS resolution failure).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.statusCode});
}

/// Authentication and session failures (unauthorized, expired token, forbidden).
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

/// Validation failure on form input or entity constraints.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors, super.statusCode});
}

/// Local storage or caching failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.statusCode});
}
