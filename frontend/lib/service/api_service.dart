import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sbku_app/core/constants/app_config.dart';

class ApiService {
  /// Laravel API base (includes `/api`). Override with `API_URL` in `.env` (host only, no `/api`).
  static String get baseUrl => AppConfig.apiBaseUrl;

  final storage = const FlutterSecureStorage();
  // Single shared HTTP client for the entire app to maintain Keep-Alive, DNS, and SSL session caching.
  static final http.Client _sharedClient = http.Client();
  final http.Client _client;

  ApiService() : _client = _sharedClient;

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration requestTimeout = Duration(seconds: 30);

  // Token management
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }

  // Headers with user-agent and device identification
  Future<Map<String, String>> getHeaders({bool requiresAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'SBKU-Mobile/1.0.0',
    };

    if (requiresAuth) {
      String? token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Retry wrapper with exponential backoff
  Future<http.Response> _retryableRequest<T>(
    Future<http.Response> Function() request,
  ) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await request().timeout(requestTimeout);

        // Only retry on server errors (5xx) and connection issues
        if (response.statusCode >= 500 && attempt < maxRetries - 1) {
          attempt++;
          await Future.delayed(Duration(milliseconds: 100 * (attempt * 2)));
          continue;
        }

        return response;
      } on TimeoutException {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 100 * (attempt * 2)));
      } catch (e) {
        // For network errors, retry
        if (attempt < maxRetries - 1) {
          attempt++;
          await Future.delayed(Duration(milliseconds: 100 * (attempt * 2)));
          continue;
        }
        rethrow;
      }
    }

    throw TimeoutException('Max retries exceeded');
  }

  // GET request with retry
  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    return await _retryableRequest(() => _client.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
        ));
  }

  // POST request with retry
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    return await _retryableRequest(() => _client.post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        ));
  }

  // PUT request with retry
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    return await _retryableRequest(() => _client.put(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        ));
  }

  // DELETE request with retry
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    return await _retryableRequest(() => _client.delete(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
        ));
  }

  // Multipart request (for file uploads) - no retry as file position can't be reset
  Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields,
    String fileField,
    String filePath, {
    bool requiresAuth = true,
  }) async {
    try {
      String? token = await getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$endpoint'),
      );

      // Add headers
      request.headers['Accept'] = 'application/json';
      request.headers['User-Agent'] = 'SBKU-Mobile/1.0.0';
      if (requiresAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      return await request.send().timeout(requestTimeout);
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request with retry
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    return await _retryableRequest(() => _client.patch(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        ));
  }

  /// Health check - useful for testing connectivity
  Future<bool> healthCheck() async {
    try {
      final response = await get('health', requiresAuth: false);
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}
