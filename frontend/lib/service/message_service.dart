import 'dart:convert';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/service/api_service.dart';

class MessageService {
  final ApiService _api = sl<ApiService>();

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
    }

    // 2. Poll with adaptive backoff
    var pollInterval = const Duration(seconds: 10);
    while (true) {
      await Future.delayed(pollInterval);
      try {
        cachedData = await fetchMessages();
        pollInterval = const Duration(seconds: 10);
        yield cachedData;
      } catch (e) {
        print('Polling messages failed: $e');
        pollInterval = Duration(
          seconds: (pollInterval.inSeconds * 2).clamp(10, 60),
        );
        yield cachedData;
      }
    }
  }
}
