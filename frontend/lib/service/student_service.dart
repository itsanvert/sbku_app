import 'dart:convert';
import 'package:sbku_app/model/student_model.dart';
import 'package:sbku_app/service/api_service.dart';

class StudentService {
  final ApiService _api = ApiService();

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

    final response = await _api.get('students?$query');

    if (response.statusCode == 200) {
      return StudentPaginated.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load students: ${response.statusCode}');
  }

  Future<Student> getStudent(int id) async {
    final response = await _api.get('students/$id');

    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body));
    }

    throw Exception('Student not found');
  }

  Future<void> deleteStudent(int id) async {
    final response = await _api.delete('students/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete student');
    }
  }

  Future<void> createStudent(Map<String, dynamic> data, {String? filePath}) async {
    if (filePath != null) {
      final fields = data.map((key, value) => MapEntry(key, value.toString()));
      final response = await _api.postMultipart('students', fields, 'photo', filePath);
      
      if (response.statusCode != 201) {
        throw Exception('Failed to create student with photo');
      }
    } else {
      final response = await _api.post('students', data, requiresAuth: true);
      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create student');
      }
    }
  }

  Future<void> updateStudent(int id, Map<String, dynamic> data, {String? filePath}) async {
    if (filePath != null) {
      // Laravel handles PUT with multipart a bit differently (often requires _method: PUT)
      final fields = data.map((key, value) => MapEntry(key, value.toString()));
      fields['_method'] = 'PUT';
      
      final response = await _api.postMultipart('students/$id', fields, 'photo', filePath);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update student with photo');
      }
    } else {
      final response = await _api.put('students/$id', data);
      if (response.statusCode != 200) {
        throw Exception('Failed to update student');
      }
    }
  }
}
