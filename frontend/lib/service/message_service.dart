import 'dart:convert';
import 'package:sbku_app/service/api_service.dart';

class MessageService {
  final ApiService _api = ApiService();

  /// Poll messages from the API.
  Stream<List<Map<String, dynamic>>> listenToMessages({String? userId}) {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      try {
        final response = await _api.get('messages', requiresAuth: true);
        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is List) {
            return List<Map<String, dynamic>>.from(decoded);
          } else if (decoded is Map && decoded.containsKey('data')) {
            return List<Map<String, dynamic>>.from(decoded['data']);
          }
        }
        return <Map<String, dynamic>>[];
      } catch (e) {
        print('Polling messages failed: $e');
        return <Map<String, dynamic>>[];
      }
    });
  }
}
