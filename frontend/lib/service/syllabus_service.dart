import 'package:sbku_app/core/network/api_response_parser.dart';
import 'package:sbku_app/model/syllabus_model.dart';
import 'package:sbku_app/service/api_service.dart';

class SyllabusService {
  final ApiService _apiService = ApiService();

  Future<List<SyllabusModel>> getSyllabus() async {
    final response = await _apiService.get('syllabus');

    if (response.statusCode != 200) {
      throw Exception(
        ApiResponseParser.errorMessage(response, body: ApiResponseParser.decodeBody(response)),
      );
    }

    final body = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));
    final list = ApiResponseParser.asList(body);

    return list.map((item) {
      final json = Map<String, dynamic>.from(item as Map);
      return SyllabusModel(
        id: json['id']?.toString() ?? '',
        facultyName: json['faculty_name']?.toString() ?? '—',
        majorName: json['major_name']?.toString() ?? '—',
        yearName: json['year_name']?.toString() ?? json['year_id']?.toString() ?? '—',
        semesterName: json['semester_name']?.toString() ??
            (json['semester_id'] != null ? 'Semester ${json['semester_id']}' : '—'),
        subjectName: json['subject_name']?.toString() ?? '—',
        teacherName: json['teacher_name']?.toString() ?? '—',
        shiftName: json['shift_name']?.toString() ?? '—',
        creditHours: json['credit_hours']?.toString() ?? '3',
        scheduleInfo: json['schedule_description']?.toString() ?? '—',
      );
    }).toList();
  }
}
