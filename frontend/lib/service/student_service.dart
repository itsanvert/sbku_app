import 'dart:async';
import 'dart:convert';
import 'package:sbku_app/core/constants/api_endpoints.dart';
import 'package:sbku_app/core/network/api_response_parser.dart';
import 'package:sbku_app/core/result.dart';
import 'package:sbku_app/model/student_model.dart';
import 'package:sbku_app/service/api_service.dart';

class StudentService {
  final ApiService _api = ApiService();
  final Map<String, DateTime> _lastPoll = {};

  bool _shouldPoll(String key, {int minIntervalSec = 10}) {
    final now = DateTime.now();
    final last = _lastPoll[key];
    if (last == null || now.difference(last).inSeconds >= minIntervalSec) {
      _lastPoll[key] = now;
      return true;
    }
    return false;
  }

  /// Get students as a real-time stream via API polling (debounced 10s).
  Stream<List<Student>> streamStudents() async* {
    // 1. Fetch and emit the first event immediately (0-second mark)
    try {
      final paginated = await getStudents(page: 1);
      yield paginated.data;
    } catch (e) {
      print('Initial students fetch failed: $e');
      yield <Student>[];
    }

    // 2. Poll periodically every 10 seconds in the background
    yield* Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      if (!_shouldPoll('students')) return <Student>[];
      try {
        final paginated = await getStudents(page: 1);
        return paginated.data;
      } catch (e) {
        print('Polling students failed: $e');
        return <Student>[];
      }
    });
  }

  Future<StudentPaginated> getStudents({
    int page = 1,
    String search = '',
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    final query = [
      'page=$page',
      if (search.isNotEmpty) 'search=${Uri.encodeComponent(search)}',
      'sort_by=$sortBy',
      'sort_dir=$sortDir',
    ].join('&');

    final response = await _api.get('${ApiEndpoints.students}?$query');

    if (response.statusCode == 200) {
      final body = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));
      return StudentPaginated.fromJson(body);
    }

    throw Exception(ApiResponseParser.errorMessage(response));
  }

  Future<Student> getStudent(String id) async {
    final response = await _api.get(ApiEndpoints.student(int.parse(id)));

    if (response.statusCode == 200) {
      final body = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));
      final data = ApiResponseParser.unwrapData(body);
      return Student.fromJson(
        data is Map<String, dynamic> ? data : body,
      );
    }

    throw Exception(ApiResponseParser.errorMessage(response));
  }

  Future<void> deleteStudent(String id) async {
    final response = await _api.delete(ApiEndpoints.student(int.parse(id)));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete student');
    }
  }

  Future<void> createStudent(Map<String, dynamic> data, {String? filePath}) async {
    if (filePath != null) {
      final fields = data.map((key, value) => MapEntry(key, value.toString()));
      final response = await _api.postMultipart(ApiEndpoints.students, fields, 'photo', filePath);

      if (response.statusCode != 201) {
        throw Exception('Failed to create student with photo');
      }
    } else {
      final response = await _api.post(ApiEndpoints.students, data, requiresAuth: true);
      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create student');
      }
    }
  }

  Future<void> updateStudent(int id, Map<String, dynamic> data, {String? filePath}) async {
    if (filePath != null) {
      final fields = data.map((key, value) => MapEntry(key, value.toString()));
      fields['_method'] = 'PUT';

      final response = await _api.postMultipart(ApiEndpoints.student(id), fields, 'photo', filePath);

      if (response.statusCode != 200) {
        throw Exception('Failed to update student with photo');
      }
    } else {
      final response = await _api.put(ApiEndpoints.student(id), data);
      if (response.statusCode != 200) {
        throw Exception('Failed to update student');
      }
    }
  }
}
