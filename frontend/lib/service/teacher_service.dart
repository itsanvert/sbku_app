import 'dart:async';
import 'dart:convert';
import 'package:sbku_app/core/constants/api_endpoints.dart';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/core/network/api_response_parser.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/service/api_service.dart';

class TeacherService {
  final ApiService _api = sl<ApiService>();
  /// Get teachers as a real-time stream via API polling.
  Stream<List<Teacher>> streamTeachers() async* {
    List<Teacher> cachedData = [];

    // 1. Fetch and emit the first event immediately
    try {
      final paginated = await getTeachers(page: 1);
      cachedData = paginated.data;
      yield cachedData;
    } catch (e) {
      print('Initial teachers fetch failed: $e');
    }

    // 2. Poll with adaptive backoff on failure
    var pollInterval = const Duration(seconds: 10);
    while (true) {
      await Future.delayed(pollInterval);
      try {
        final paginated = await getTeachers(page: 1);
        cachedData = paginated.data;
        pollInterval = const Duration(seconds: 10);
        yield cachedData;
      } catch (e) {
        print('Polling teachers failed: $e');
        pollInterval = Duration(
          seconds: (pollInterval.inSeconds * 2).clamp(10, 60),
        );
        yield cachedData;
      }
    }
  }

  Future<TeacherPaginated> getTeachers({
    int page = 1,
    String search = '',
    String sortBy = 'teachers.id',
    String sortDir = 'asc',
  }) async {
    final query = [
      'page=$page',
      if (search.isNotEmpty) 'search=${Uri.encodeComponent(search)}',
      'sort_by=$sortBy',
      'sort_dir=$sortDir',
    ].join('&');

    final response = await _api.get('${ApiEndpoints.teachers}?$query', timeout: ApiService.extendedTimeout);

    if (response.statusCode == 200) {
      final body = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));
      return TeacherPaginated.fromJson(body);
    }

    throw Exception(ApiResponseParser.errorMessage(response));
  }

  Future<Teacher> getTeacher(String id) async {
    final response = await _api.get(ApiEndpoints.teacher(int.parse(id)));

    if (response.statusCode == 200) {
      final body = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));
      final data = ApiResponseParser.unwrapData(body);
      return Teacher.fromJson(
        data is Map<String, dynamic> ? data : body,
      );
    }

    throw Exception(ApiResponseParser.errorMessage(response));
  }

  Future<void> deleteTeacher(int id) async {
    final response = await _api.delete(ApiEndpoints.teacher(id));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete teacher');
    }
  }

  Future<void> createTeacher(Map<String, dynamic> data, {String? filePath}) async {
    if (filePath != null) {
      final fields = data.map((key, value) => MapEntry(key, value.toString()));
      final response = await _api.postMultipart(ApiEndpoints.teachers, fields, 'photo', filePath);

      if (response.statusCode != 201) {
        throw Exception('Failed to create teacher with photo');
      }
    } else {
      final response = await _api.post(ApiEndpoints.teachers, data, requiresAuth: true);
      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create teacher');
      }
    }
  }

  Future<void> updateTeacher(int id, Map<String, dynamic> data, {String? filePath}) async {
    if (filePath != null) {
      final fields = data.map((key, value) => MapEntry(key, value.toString()));
      fields['_method'] = 'PUT';

      final response = await _api.postMultipart(ApiEndpoints.teacher(id), fields, 'photo', filePath);

      if (response.statusCode != 200) {
        throw Exception('Failed to update teacher with photo');
      }
    } else {
      final response = await _api.put(ApiEndpoints.teacher(id), data);
      if (response.statusCode != 200) {
        throw Exception('Failed to update teacher');
      }
    }
  }
}
