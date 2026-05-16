import 'dart:convert';
import 'package:sbku_app/core/network/api_response_parser.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/service/api_service.dart';

class TeacherService {
  final ApiService _api = ApiService();

  /// Get teachers as a real-time stream via API polling.
  Stream<List<Teacher>> streamTeachers() {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      try {
        final paginated = await getTeachers(page: 1);
        return paginated.data;
      } catch (e) {
        print('Polling teachers failed: $e');
        return <Teacher>[];
      }
    });
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

    final response = await _api.get('teachers?$query');

    if (response.statusCode == 200) {
      final body = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));
      return TeacherPaginated.fromJson(body);
    }

    throw Exception(ApiResponseParser.errorMessage(response));
  }

  Future<Teacher> getTeacher(String id) async {
    final response = await _api.get('teachers/$id');

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
    final response = await _api.delete('teachers/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete teacher');
    }
  }

  Future<void> createTeacher(Map<String, dynamic> data, {String? filePath}) async {
    if (filePath != null) {
      final fields = data.map((key, value) => MapEntry(key, value.toString()));
      final response = await _api.postMultipart('teachers', fields, 'photo', filePath);
      
      if (response.statusCode != 201) {
        throw Exception('Failed to create teacher with photo');
      }
    } else {
      final response = await _api.post('teachers', data, requiresAuth: true);
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
      
      final response = await _api.postMultipart('teachers/$id', fields, 'photo', filePath);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update teacher with photo');
      }
    } else {
      final response = await _api.put('teachers/$id', data);
      if (response.statusCode != 200) {
        throw Exception('Failed to update teacher');
      }
    }
  }
}
