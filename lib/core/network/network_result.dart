// ignore_for_file: use_super_parameters
/// Sealed result type returned by every API service method.
///
/// Pattern-match on this to handle success and failure in the UI layer:
/// ```dart
/// final result = await authService.login(request);
/// switch (result) {
///   case Success(:final data): // use data
///   case Failure(:final exception): // handle exception.message
/// }
/// ```
sealed class NetworkResult<T> {
  const NetworkResult();

  /// Returns `true` when the request succeeded.
  bool get isSuccess => this is Success<T>;

  /// Convenience: unwrap [data] or return `null`.
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  /// Convenience: unwrap [ApiException] or return `null`.
  ApiException? get exceptionOrNull => switch (this) {
    Success() => null,
    Failure(:final exception) => exception,
  };

  /// Transforms [data] on success, leaving failure untouched.
  NetworkResult<R> map<R>(R Function(T data) transform) => switch (this) {
    Success(:final data) => Success(transform(data)),
    Failure(:final exception) => Failure(exception),
  };
}

final class Success<T> extends NetworkResult<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends NetworkResult<T> {
  final ApiException exception;
  const Failure(this.exception);
}

// ─── Exception hierarchy ─────────────────────────────────────────────────────

/// Base class for all API-related exceptions.
sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 400 – The request was malformed.
final class BadRequestException extends ApiException {
  final Map<String, dynamic>? errors;
  const BadRequestException(
    super.message, {
    super.statusCode = 400,
    this.errors,
  });
}

/// 401 – Authentication required / token expired.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    String message = 'Unauthorized. Please log in again.',
  ]) : super(message, statusCode: 401);
}

/// 403 – Access denied.
final class ForbiddenException extends ApiException {
  const ForbiddenException([
    String message = 'You do not have permission to perform this action.',
  ]) : super(message, statusCode: 403);
}

/// 404 – Resource not found.
final class NotFoundException extends ApiException {
  const NotFoundException([
    String message = 'The requested resource was not found.',
  ]) : super(message, statusCode: 404);
}

/// 422 – Laravel validation failed.
final class ValidationException extends ApiException {
  /// Field-level validation errors from Laravel's JSON response.
  final Map<String, dynamic>? errors;
  const ValidationException(
    super.message, {
    super.statusCode = 422,
    this.errors,
  });

  /// Returns the first validation message for [field], or `null`.
  String? fieldError(String field) {
    final fieldErrors = errors?[field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return null;
  }
}

/// 429 – Too many requests.
final class TooManyRequestsException extends ApiException {
  const TooManyRequestsException([
    String message = 'Too many requests. Please try again later.',
  ]) : super(message, statusCode: 429);
}

/// 5xx – Server-side error.
final class ServerException extends ApiException {
  const ServerException([
    String message = 'A server error occurred. Please try again later.',
  ]) : super(message, statusCode: 500);
}

/// No internet / DNS failure.
final class NetworkException extends ApiException {
  const NetworkException([
    String message = 'No internet connection. Please check your network.',
  ]) : super(message);
}

/// Connection/send/receive timed out.
final class TimeoutException extends ApiException {
  const TimeoutException([
    String message = 'Request timed out. Please try again.',
  ]) : super(message);
}

/// Request was cancelled (e.g. widget disposed).
final class CancelledException extends ApiException {
  const CancelledException([String message = 'Request was cancelled.'])
    : super(message);
}

/// Unexpected / unclassified error.
final class UnknownException extends ApiException {
  const UnknownException([
    String message = 'An unexpected error occurred at network.',
  ]) : super(message);
}
