import 'dart:convert';
import 'package:http/http.dart' as http;

/// Helpers for parsing Laravel API responses (flat or `{ success, data }` envelope).
class ApiResponseParser {
  ApiResponseParser._();

  static dynamic decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  /// Safely coerces [body] to `Map<String, dynamic>`.
  ///
  /// Returns an empty map if [body] is not a map-like object.
  /// Use [requireMap] if an absent map should be treated as an error.
  static Map<String, dynamic> asMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    return {};
  }

  /// Same as [asMap] but throws a [FormatException] if [body] is not a map.
  /// Callers that *require* a map (e.g. parsing a single-object response)
  /// should prefer this method to avoid silent empty-map returns.
  static Map<String, dynamic> requireMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    throw FormatException(
      'Expected a JSON object but got ${body.runtimeType}. '
      'Raw body: ${body?.toString() ?? "null"}',
    );
  }

  /// Unwraps `data` when the API uses the standard envelope.
  static dynamic unwrapData(dynamic body) {
    final map = asMap(body);
    if (map['success'] == true && map.containsKey('data')) {
      return map['data'];
    }
    return body;
  }

  /// Extracts a `List` from [body].
  ///
  /// Handles two response shapes:
  /// - Flat list: `[{...}, {...}]` → returns the list directly
  /// - Envelope: `{ success: true, data: [{...}] }` → unwraps then returns
  ///
  /// Returns an empty list if the body does not contain a list.
  static List<dynamic> asList(dynamic body, {String listKey = 'data'}) {
    // Step 1: unwrap envelope once, never twice
    final unwrapped = unwrapData(body);

    // Step 2: if it's already a list, return it
    if (unwrapped is List) return unwrapped;

    // Step 3: otherwise look inside a named key
    final map = asMap(unwrapped);
    final list = map[listKey];
    if (list is List) return list;

    return [];
  }

  static String? errorMessage(http.Response response, {dynamic body}) {
    final decoded = body ?? decodeBody(response);
    final map = asMap(decoded);

    if (map['message'] is String) return map['message'] as String;

    final errors = map['errors'];
    if (errors is Map) {
      final parts = <String>[];
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          parts.add(value.first.toString());
        } else if (value != null) {
          parts.add(value.toString());
        }
      });
      if (parts.isNotEmpty) return parts.join('\n');
    }

    if (response.statusCode >= 500) {
      return 'Server error (${response.statusCode}). Try again in a moment.';
    }
    if (response.statusCode == 401) {
      return 'Session expired. Please log in again.';
    }

    return 'Request failed (HTTP ${response.statusCode})';
  }
}
