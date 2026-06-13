import 'dart:async';
import 'dart:convert';
import 'package:sbku_app/core/constants/api_endpoints.dart';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/core/network/api_response_parser.dart';
import 'package:sbku_app/model/student_model.dart';
import 'package:sbku_app/service/api_service.dart';

class StudentService {
  final ApiService _api = sl<ApiService>();
  /// Get students as a real-time stream via API polling.
  Stream<List<Student>> streamStudents() async* {
    List<Student> cachedData = [];

    // 1. Fetch and emit the first event immediately
    try {
      final paginated = await getStudents(page: 1);
      cachedData = paginated.data;
      yield cachedData;
    } catch (e) {
      print('Initial students fetch failed: $e');
    }

    // 2. Poll with adaptive backoff on failure
    var pollInterval = const Duration(seconds: 10);
    while (true) {
      await Future.delayed(pollInterval);
      try {
        final paginated = await getStudents(page: 1);
        cachedData = paginated.data;
        pollInterval = const Duration(seconds: 10);
        yield cachedData;
      } catch (e) {
        print('Polling students failed: $e');
        pollInterval = Duration(
          seconds: (pollInterval.inSeconds * 2).clamp(10, 60),
        );
        yield cachedData;
      }
    }
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
