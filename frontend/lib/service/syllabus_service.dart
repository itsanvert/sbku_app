import 'dart:convert';
import 'package:sbku_app/model/syllabus_model.dart';
import 'package:sbku_app/service/api_service.dart';

class SyllabusService {
  final ApiService _apiService = ApiService();

  Future<List<SyllabusModel>> getSyllabus() async {
    try {
      final response = await _apiService.get('syllabus');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        
        return data.map((json) => SyllabusModel(
          id: json['id'].toString(),
          facultyName: json['faculty_name'] ?? 'Unknown',
          majorName: json['major_name'] ?? 'Unknown',
          yearName: json['year_name'] ?? 'Unknown Year',
          semesterName: json['semester_name'] ?? 'Unknown Semester',
          subjectName: json['subject_name'] ?? 'Unknown Subject',
          teacherName: json['teacher_name'] ?? 'Unknown Teacher',
          shiftName: json['shift_name'] ?? 'Unknown Shift',
          creditHours: json['credit_hours']?.toString() ?? '3',
          scheduleInfo: json['schedule_description'] ?? 'TBD',
        )).toList();
      } else {
        throw Exception('Failed to load syllabus');
      }
    } catch (e) {
      throw Exception('Error fetching syllabus: $e');
    }
  }
}
