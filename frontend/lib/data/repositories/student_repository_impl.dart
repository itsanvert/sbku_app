import 'package:sbku_app/core/constants/api_endpoints.dart';
import 'package:sbku_app/core/network/api_error_handler.dart';
import 'package:sbku_app/core/result.dart';
import 'package:sbku_app/domain/repositories/student_repository.dart';
import 'package:sbku_app/model/student_model.dart';
import 'package:sbku_app/service/api_service.dart';

/// Concrete implementation of [StudentRepository] backed by the REST API.
///
/// Uses [ApiErrorHandler] mixin for automatic HTTP → Result<T> mapping.
class StudentRepositoryImpl with ApiErrorHandler implements StudentRepository {
  final ApiService _api;

  StudentRepositoryImpl({required ApiService apiService}) : _api = apiService;

  @override
  Future<Result<StudentPaginated>> getStudents({
    int page = 1,
    String search = '',
    String sortBy = 'id',
    String sortDir = 'asc',
  }) {
    return guardAsync(() async {
      final query = [
        'page=$page',
        if (search.isNotEmpty) 'search=${Uri.encodeComponent(search)}',
        'sort_by=$sortBy',
        'sort_dir=$sortDir',
      ].join('&');

      final response = await _api.get('${ApiEndpoints.students}?$query');
      final result = handleResponse(
        response,
        (body) => StudentPaginated.fromJson(body as Map<String, dynamic>),
      );

      return result.data;
    });
  }

  @override
  Future<Result<Student>> getStudent(int id) {
    return guardAsync(() async {
      final response = await _api.get(ApiEndpoints.student(id));
      final result = handleResponse(
        response,
        (body) => Student.fromJson(body as Map<String, dynamic>),
      );

      return result.data;
    });
  }

  @override
  Future<Result<void>> createStudent(
    Map<String, dynamic> data, {
    String? filePath,
  }) {
    return guardAsync(() async {
      if (filePath != null) {
        final fields = data.map((key, value) => MapEntry(key, value.toString()));
        final response = await _api.postMultipart(
          ApiEndpoints.students,
          fields,
          'photo',
          filePath,
        );

        if (response.statusCode != 201) {
          throw ServerException('Failed to create student with photo', response.statusCode);
        }
      } else {
        final response = await _api.post(
          ApiEndpoints.students,
          data,
          requiresAuth: true,
        );

        final result = handleResponse<void>(response, (_) {});
        if (result.isFailure) {
          throw (result as Failure).error;
        }
      }
    });
  }

  @override
  Future<Result<void>> updateStudent(
    int id,
    Map<String, dynamic> data, {
    String? filePath,
  }) {
    return guardAsync(() async {
      if (filePath != null) {
        final fields = data.map((key, value) => MapEntry(key, value.toString()));
        fields['_method'] = 'PUT';

        final response = await _api.postMultipart(
          ApiEndpoints.student(id),
          fields,
          'photo',
          filePath,
        );

        if (response.statusCode != 200) {
          throw ServerException('Failed to update student with photo', response.statusCode);
        }
      } else {
        final response = await _api.put(ApiEndpoints.student(id), data);
        final result = handleResponse<void>(response, (_) {});
        if (result.isFailure) {
          throw (result as Failure).error;
        }
      }
    });
  }

  @override
  Future<Result<void>> deleteStudent(int id) {
    return guardAsync(() async {
      final response = await _api.delete(ApiEndpoints.student(id));
      final result = handleResponse<void>(response, (_) {});
      if (result.isFailure) {
        throw (result as Failure).error;
      }
    });
  }
}
