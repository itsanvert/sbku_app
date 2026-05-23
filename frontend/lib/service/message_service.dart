import 'dart:convert';
import 'package:sbku_app/service/api_service.dart';

class MessageService {
  final ApiService _api = ApiService();

  /// Poll messages from the API.
  Stream<List<Map<String, dynamic>>> listenToMessages({String? userId}) async* {
    List<Map<String, dynamic>> cachedData = [];

    Future<List<Map<String, dynamic>>> fetchMessages() async {
      final response = await _api.get('messages', requiresAuth: true);
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map && decoded.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
      throw Exception('Failed to load messages (HTTP ${response.statusCode})');
    }

    // 1. Fetch immediately
    try {
      cachedData = await fetchMessages();
      yield cachedData;
    } catch (e) {
      print('Initial messages fetch failed: $e');
      yield* Stream.error(e);
    }

    // 2. Poll periodically
    yield* Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      try {
        cachedData = await fetchMessages();
        return cachedData;
      } catch (e) {
        print('Polling messages failed: $e');
        return cachedData;
      }
    });
  }
}
