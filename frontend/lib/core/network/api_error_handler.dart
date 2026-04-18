import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../result.dart';

/// Mixin that provides standard HTTP → Result<T> error mapping.
///
/// Any repository implementation can mix this in to get automatic
/// status-code → AppException conversion.
mixin ApiErrorHandler {
  /// Parses an HTTP response and returns a [Result].
  ///
  /// [parser] converts the decoded JSON body into the desired type.
  /// If the response is successful (2xx), the [parser] is called.
  /// Otherwise, an appropriate [AppException] is created.
  Result<T> handleResponse<T>(
    http.Response response,
    T Function(dynamic body) parser,
  ) {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(parser(body));
      }

      return Failure(_mapStatusToException(response.statusCode, body));
    } on FormatException {
      return Failure(ServerException(
        'Invalid response format from server.',
        response.statusCode,
      ));
    }
  }

  /// Wraps an async operation in try/catch and returns a [Result].
  ///
  /// Catches [SocketException] (no network), [HttpException],
  /// and any other errors, mapping them to appropriate [AppException]s.
  Future<Result<T>> guardAsync<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success(data);
    } on AppException catch (e) {
      return Failure(e);
    } on SocketException {
      return const Failure(NetworkException());
    } on HttpException catch (e) {
      return Failure(ServerException(e.message));
    } catch (e) {
      return Failure(UnknownException(e.toString(), e));
    }
  }

  /// Maps HTTP status codes to typed exceptions.
  AppException _mapStatusToException(int statusCode, dynamic body) {
    final message = _extractMessage(body);

    return switch (statusCode) {
      401 => UnauthorizedException(message ?? 'Session expired. Please log in again.'),
      403 => ForbiddenException(message ?? 'You do not have permission.'),
      404 => NotFoundException(message ?? 'Resource not found.'),
      422 => ValidationException(
          message: message ?? 'Validation failed',
          errors: _extractValidationErrors(body),
        ),
      >= 500 => ServerException(message ?? 'Server error. Please try again later.', statusCode),
      _ => ServerException(message ?? 'Unexpected error (HTTP $statusCode)', statusCode),
    };
  }

  /// Extracts the human-readable message from a JSON error body.
  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['message']?.toString();
    }
    return null;
  }

  /// Extracts Laravel-style validation errors from 422 responses.
  Map<String, List<String>> _extractValidationErrors(dynamic body) {
    if (body is! Map<String, dynamic>) return {};

    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return {};

    return errors.map((key, value) => MapEntry(
      key,
      value is List ? value.map((e) => e.toString()).toList() : [value.toString()],
    ));
  }
}
