import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ⚠️ IMPORTANT: Change this to your Laravel backend URL
  // For Android Emulator: http://10.0.2.2:8000/api
  // For iOS Simulator: http://localhost:8000/api
  // For Physical Device: http://YOUR_COMPUTER_IP:8000/api (e.g., http://192.168.1.100:8000/api)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  final storage = const FlutterSecureStorage();

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

  // Headers
  Future<Map<String, String>> getHeaders({bool requiresAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      String? token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Multipart request (for file uploads)
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
      if (requiresAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      return await request.send();
    } catch (e) {
      rethrow;
    }
  }
}
