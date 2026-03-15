import 'dart:convert';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/service/api_service.dart';


class TeacherService {
  final ApiService _api = ApiService();

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
      return TeacherPaginated.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load teachers: ${response.statusCode}');
  }

  Future<Teacher> getTeacher(int id) async {
    final response = await _api.get('teachers/$id');

    if (response.statusCode == 200) {
      return Teacher.fromJson(jsonDecode(response.body));
    }

    throw Exception('Teacher not found');
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
