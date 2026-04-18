import 'package:sbku_app/core/result.dart';
import 'package:sbku_app/model/student_model.dart';

/// Contract for student data operations.
///
/// The presentation layer depends on this interface — never on
/// `StudentService` directly. This enables:
/// - Swapping data sources (API, cache, mock)
/// - Easier unit testing via mock implementations
abstract class StudentRepository {
  /// Fetches a paginated list of students.
  Future<Result<StudentPaginated>> getStudents({
    int page = 1,
    String search = '',
    String sortBy = 'id',
    String sortDir = 'asc',
  });

  /// Fetches a single student by ID.
  Future<Result<Student>> getStudent(int id);

  /// Creates a new student, optionally with a profile photo.
  Future<Result<void>> createStudent(
    Map<String, dynamic> data, {
    String? filePath,
  });

  /// Updates an existing student, optionally with a profile photo.
  Future<Result<void>> updateStudent(
    int id,
    Map<String, dynamic> data, {
    String? filePath,
  });

  /// Deletes a student by ID.
  Future<Result<void>> deleteStudent(int id);
}
