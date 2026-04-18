/// A typed Result that replaces raw `Map<String, dynamic>` returns.
///
/// Usage:
/// ```dart
/// final result = await repository.getStudent(id);
/// switch (result) {
///   case Success(:final data): // use data
///   case Failure(:final error): // handle error
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// `true` when this result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// `true` when this result is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the data if [Success], otherwise throws.
  T get data => (this as Success<T>).value;

  /// Convenience: fold into a single value.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onFailure,
  }) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      Failure(:final error) => onFailure(error),
    };
  }
}

/// Wraps a successful computation.
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Wraps a failed computation.
class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}

// ── Exceptions ──────────────────────────────────────────────────────────────

/// Base class for all application-level exceptions.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the device cannot reach the server.
class NetworkException extends AppException {
  const NetworkException([
    String message = 'Unable to connect. Please check your internet connection.',
  ]) : super(message);
}

/// Thrown when the server returns an unexpected error (5xx).
class ServerException extends AppException {
  const ServerException([
    String message = 'Something went wrong on the server.',
    int? statusCode,
  ]) : super(message, statusCode: statusCode);
}

/// Thrown when the user's token is missing or expired (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'Session expired. Please log in again.',
  ]) : super(message, statusCode: 401);
}

/// Thrown when the server rejects input (422).
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({
    String message = 'Validation failed',
    this.errors = const {},
  }) : super(message, statusCode: 422);

  /// Returns a flat string of all validation error messages.
  String get flatErrors =>
      errors.values.expand((v) => v).join('\n');
}

/// Thrown when the resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException([
    String message = 'Resource not found.',
  ]) : super(message, statusCode: 404);
}

/// Thrown when the user does not have permission (403).
class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'You do not have permission to perform this action.',
  ]) : super(message, statusCode: 403);
}

/// Generic app-level error for everything else.
class UnknownException extends AppException {
  const UnknownException([
    String message = 'An unexpected error occurred.',
    dynamic originalError,
  ]) : super(message, originalError: originalError);
}
