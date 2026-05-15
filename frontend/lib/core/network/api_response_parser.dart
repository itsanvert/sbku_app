import 'dart:convert';

import 'package:http/http.dart' as http;

/// Helpers for parsing Laravel API responses (flat or `{ success, data }` envelope).
class ApiResponseParser {
  ApiResponseParser._();

  static dynamic decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  static Map<String, dynamic> asMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    return {};
  }

  /// Unwraps `data` when the API uses the standard envelope.
  static dynamic unwrapData(dynamic body) {
    final map = asMap(body);
    if (map['success'] == true && map.containsKey('data')) {
      return map['data'];
    }
    return body;
  }

  static List<dynamic> asList(dynamic body, {String listKey = 'data'}) {
    final unwrapped = unwrapData(body);
    if (unwrapped is List) return unwrapped;

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
