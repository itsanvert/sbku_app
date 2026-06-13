import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sbku_app/core/constants/app_config.dart';

class _CacheEntry {
  final http.Response response;
  final DateTime _createdAt = DateTime.now();

  _CacheEntry(this.response);

  bool get isExpired => DateTime.now().difference(_createdAt) > ApiService._cacheTtl;
}

class ApiService {
  /// Laravel API base (includes `/api`). Override with `API_URL` in `.env` (host only, no `/api`).
  static String get baseUrl => AppConfig.apiBaseUrl;

  final storage = const FlutterSecureStorage();
  static final http.Client _sharedClient = http.Client();
  final http.Client _client;

  // In-memory response cache: keyed by endpoint, expires after TTL
  static final _cache = <String, _CacheEntry>{};
  static const Duration _cacheTtl = Duration(seconds: 30);

  ApiService() : _client = _sharedClient;

  // Retry configuration
  static const int maxRetries = 1;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration extendedTimeout = Duration(seconds: 60);
  static const Duration healthCheckTimeout = Duration(seconds: 5);

  // Track server unreachability to fail fast
  static bool _serverLikelyDown = false;
  static DateTime? _lastServerDownCheck;
  static const Duration _serverDownCooldown = Duration(seconds: 15);

  /// Check if server is likely unreachable (fail-fast before making a real request)
  bool _isServerLikelyDown() {
    if (!_serverLikelyDown) return false;
    if (_lastServerDownCheck != null &&
        DateTime.now().difference(_lastServerDownCheck!) > _serverDownCooldown) {
      _serverLikelyDown = false;
      return false;
    }
    return true;
  }

  void _markServerDown() {
    _serverLikelyDown = true;
    _lastServerDownCheck = DateTime.now();
  }

  void _markServerUp() {
    _serverLikelyDown = false;
    _lastServerDownCheck = null;
  }

  /// Clear the entire in-memory cache (call after mutations like POST/PUT/DELETE)
  void clearCache() {
    _cache.clear();
  }

  /// Invalidate a specific cached endpoint
  void invalidateCache(String pattern) {
    _cache.removeWhere((key, _) => key.contains(pattern));
  }

  http.Response? _getCached(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.response;
    }
    _cache.remove(key);
    return null;
  }

  void _setCache(String key, http.Response response) {
    _cache[key] = _CacheEntry(response);
  }

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

  /// Build a full URL without producing double-slashes.
  /// `endpoint` must NOT start with a slash.
  Uri _buildUri(String endpoint) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final path = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return Uri.parse('$base/$path');
  }

  /// Retry wrapper with exponential backoff and connectivity guard
  Future<http.Response> _retryableRequest<T>(
    Future<http.Response> Function() request, {
    Duration timeout = requestTimeout,
  }) async {
    if (_isServerLikelyDown()) {
      throw TimeoutException('Server unreachable (fast-fail)');
    }

    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await request().timeout(timeout);

        _markServerUp();

        // Only retry on server errors (5xx) and connection issues
        if (response.statusCode >= 500 && attempt < maxRetries - 1) {
          attempt++;
          await Future.delayed(Duration(milliseconds: 100 * (attempt * 2)));
          continue;
        }

        return response;
      } on TimeoutException {
        _markServerDown();
        attempt++;
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 100 * (attempt * 2)));
      } catch (e) {
        _markServerDown();
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

  // GET request with retry and in-memory caching
  Future<http.Response> get(String endpoint, {bool requiresAuth = true, bool forceRefresh = false, Duration? timeout}) async {
    final cacheKey = '$requiresAuth:$endpoint';

    if (!forceRefresh) {
      final cached = _getCached(cacheKey);
      if (cached != null) return cached;
    }

    final headers = await getHeaders(requiresAuth: requiresAuth);
    final uri = _buildUri(endpoint);
    final response = await _retryableRequest(() => _client.get(
          uri,
          headers: headers,
        ), timeout: timeout ?? requestTimeout);

    if (response.statusCode == 200) {
      _setCache(cacheKey, response);
    } else {
      print('[ApiService GET ${response.statusCode}] $uri');
      print('  Body: ${response.body}');
    }

    return response;
  }

  // POST request with retry
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    final uri = _buildUri(endpoint);
    final response = await _retryableRequest(() => _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        ));
    if (response.statusCode < 500) invalidateCache(endpoint.split('/').first);
    if (response.statusCode >= 400) {
      print('[ApiService POST ${response.statusCode}] $uri');
      print('  Request body: $body');
      print('  Response body: ${response.body}');
    }
    return response;
  }

  // PUT request with retry
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    final uri = _buildUri(endpoint);
    final response = await _retryableRequest(() => _client.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        ));
    if (response.statusCode < 500) invalidateCache(endpoint.split('/').first);
    if (response.statusCode >= 400) {
      print('[ApiService PUT ${response.statusCode}] $uri');
      print('  Request body: $body');
      print('  Response body: ${response.body}');
    }
    return response;
  }

  // DELETE request with retry
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await getHeaders(requiresAuth: requiresAuth);
    final uri = _buildUri(endpoint);
    final response = await _retryableRequest(() => _client.delete(
          uri,
          headers: headers,
        ));
    if (response.statusCode < 500) invalidateCache(endpoint.split('/').first);
    if (response.statusCode >= 400) {
      print('[ApiService DELETE ${response.statusCode}] $uri');
      print('  Response body: ${response.body}');
    }
    return response;
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
        _buildUri(endpoint),
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
    final uri = _buildUri(endpoint);
    return await _retryableRequest(() => _client.patch(
          uri,
          headers: headers,
          body: jsonEncode(body),
        ));
  }

  /// Health check - fast, no retries, short timeout
  Future<bool> healthCheck() async {
    try {
      final uri = _buildUri('health');
      final headers = await getHeaders(requiresAuth: false);
      final response = await _client.get(uri, headers: headers).timeout(healthCheckTimeout);
      if (response.statusCode == 200) {
        _markServerUp();
        return true;
      }
      return false;
    } catch (e) {
      _markServerDown();
      return false;
    }
  }
}
