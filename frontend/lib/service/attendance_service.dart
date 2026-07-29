import 'dart:convert';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/service/api_service.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  final ApiService _api = sl<ApiService>();

  // ── Attendance Sessions ──────────────────────────────────────

  /// Get schedules for a teacher, optionally filtered by day.
  Future<List<Map<String, dynamic>>> getTeacherSchedules({
    required String teacherId,
    String? day,
  }) async {
    final params = <String>['teacher_id=$teacherId'];
    if (day != null) params.add('day=$day');

    final response = await _api.get('schedules?${params.join('&')}');

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      return <Map<String, dynamic>>[];
    }
    throw Exception('Failed to load teacher schedules');
  }

  /// Start a new attendance session (teacher).
  Future<Map<String, dynamic>> startSession({
    required String teacherId,
    String? facultyId,
    String? majorId,
    String? scheduleId,
    String? syllabusId,
    String? subjectId,
    String? academicClassId,
    String? shiftId,
    String? yearId,
    String? semesterId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'teacher_id': teacherId,
      if (facultyId != null) 'faculty_id': facultyId,
      if (majorId != null) 'major_id': majorId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (syllabusId != null) 'syllabus_id': syllabusId,
      if (subjectId != null) 'subject_id': subjectId,
      if (academicClassId != null) 'academic_class_id': academicClassId,
      if (shiftId != null) 'shift_id': shiftId,
      if (yearId != null) 'year_id': yearId,
      if (semesterId != null) 'semester_id': semesterId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response =
        await _api.post('attendance-sessions', body, requiresAuth: true);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    // Parse the error body so we can surface the server's validation message
    String errorMessage = 'Failed to start session (HTTP ${response.statusCode})';
    try {
      final errorBody = jsonDecode(response.body);
      if (errorBody is Map) {
        if (errorBody.containsKey('message')) {
          errorMessage = errorBody['message'];
        } else if (errorBody.containsKey('errors')) {
          final errors = errorBody['errors'] as Map;
          errorMessage = errors.values
              .map((v) => v is List ? v.join(', ') : v.toString())
              .join('\n');
        }
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }

  /// Get active attendance sessions.
  Future<List<Map<String, dynamic>>> getActiveSessions({String? teacherId}) async {
    String endpoint = 'attendance-sessions/active';
    if (teacherId != null) {
      endpoint += '?teacher_id=$teacherId';
    }

    final response = await _api.get(endpoint);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map && decoded.containsKey('data')) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      }
      return <Map<String, dynamic>>[];
    }
    throw Exception('Failed to load active sessions');
  }



  /// Listen to active attendance sessions by polling the API.
  Stream<List<Map<String, dynamic>>> listenToActiveSessions({String? teacherId}) async* {
    List<Map<String, dynamic>> cachedData = [];

    // 1. Fetch immediately
    try {
      cachedData = await getActiveSessions(teacherId: teacherId);
      yield cachedData;
    } catch (e) {
      print('Initial active sessions fetch failed: $e');
    }

    // 2. Poll with adaptive backoff
    var pollInterval = const Duration(seconds: 5);
    while (true) {
      await Future.delayed(pollInterval);
      try {
        cachedData = await getActiveSessions(teacherId: teacherId);
        pollInterval = const Duration(seconds: 5);
        yield cachedData;
      } catch (e) {
        print('Polling active sessions failed: $e');
        pollInterval = Duration(
          seconds: (pollInterval.inSeconds * 2).clamp(5, 60),
        );
        yield cachedData;
      }
    }
  }

  /// Listen to attendances for a specific session by polling the API.
  Stream<List<Map<String, dynamic>>> listenToSessionAttendances(String sessionId) async* {
    List<Map<String, dynamic>> cachedData = [];

    Future<List<Map<String, dynamic>>> fetchAttendances() async {
      final data = await getApprovalList(sessionId);
      final attendances = data['attendances'] as Map<String, dynamic>?;
      if (attendances == null) return <Map<String, dynamic>>[];
      
      final List<Map<String, dynamic>> all = [];
      attendances.forEach((key, value) {
        if (value is List) {
          all.addAll(List<Map<String, dynamic>>.from(value));
        }
      });
      return all;
    }

    // 1. Fetch immediately
    try {
      cachedData = await fetchAttendances();
      yield cachedData;
    } catch (e) {
      print('Initial attendances fetch failed: $e');
    }

    // 2. Poll with adaptive backoff
    var pollInterval = const Duration(seconds: 3);
    while (true) {
      await Future.delayed(pollInterval);
      try {
        cachedData = await fetchAttendances();
        pollInterval = const Duration(seconds: 3);
        yield cachedData;
      } catch (e) {
        print('Polling attendances failed: $e');
        pollInterval = Duration(
          seconds: (pollInterval.inSeconds * 2).clamp(3, 60),
        );
        yield cachedData;
      }
    }
  }

  /// Get session details.
  Future<Map<String, dynamic>> getSession(String id) async {
    final response = await _api.get('attendance-sessions/$id');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load session');
  }

  /// Student check-in via QR code.
  Future<Map<String, dynamic>> checkInWithQr({
    required String sessionId,
    required String studentId,
    required String qrToken,
  }) async {
    final response = await _api.post(
      'attendance-sessions/$sessionId/check-in',
      {
        'student_id': studentId,
        'qr_token': qrToken,
      },
      requiresAuth: true,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Check-in failed');
  }

  /// End a session.
  Future<Map<String, dynamic>> endSession(String sessionId) async {
    final response = await _api.post(
      'attendance-sessions/$sessionId/end',
      {},
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to end session');
  }

  /// Renew the QR token for a session.
  ///
  /// Called when a new session period begins so old QR codes are invalidated
  /// and students must scan the fresh QR code.
  Future<Map<String, dynamic>> renewSessionToken(String sessionId) async {
    final response = await _api.post(
      'attendance-sessions/$sessionId/renew-token',
      {},
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    String errorMessage = 'Failed to renew QR token';
    try {
      final errorBody = jsonDecode(response.body);
      if (errorBody is Map && errorBody.containsKey('message')) {
        errorMessage = errorBody['message'];
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }

  // ── Attendance Reports ───────────────────────────────────────

  /// Get attendances with optional filters.
  Future<Map<String, dynamic>> getAttendances({
    String? studentId,
    String? date,
    int? month,
    int? year,
    String? status,
    int page = 1,
  }) async {
    final params = <String>[
      'page=$page',
      if (studentId != null) 'student_id=$studentId',
      if (date != null) 'date=$date',
      if (month != null) 'month=$month',
      if (year != null) 'year=$year',
      if (status != null) 'status=$status',
    ];

    final response = await _api.get('attendances?${params.join('&')}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load attendances');
  }

  /// Daily report.
  Future<Map<String, dynamic>> getDailyReport(String date) async {
    final response = await _api.get('attendances/report/daily?date=$date');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load daily report');
  }

  /// Monthly report.
  Future<Map<String, dynamic>> getMonthlyReport(int month, int year) async {
    final response =
        await _api.get('attendances/report/monthly?month=$month&year=$year');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load monthly report');
  }

  /// Yearly report.
  Future<Map<String, dynamic>> getYearlyReport(int year) async {
    final response = await _api.get('attendances/report/yearly?year=$year');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load yearly report');
  }

  /// Export attendance report to PDF.
  Future<http.Response> exportPdf({
    String? date,
    int? month,
    int? year,
    String? studentId,
  }) async {
    final params = <String>[
      if (date != null) 'date=$date',
      if (month != null) 'month=$month',
      if (year != null) 'year=$year',
      if (studentId != null) 'student_id=$studentId',
    ];
    return await _api.get('attendances/export/pdf?${params.join('&')}');
  }

  /// Export attendance report to Excel (XLSX).
  Future<http.Response> exportExcel({
    String? date,
    int? month,
    int? year,
    String? studentId,
  }) async {
    final params = <String>[
      if (date != null) 'date=$date',
      if (month != null) 'month=$month',
      if (year != null) 'year=$year',
      if (studentId != null) 'student_id=$studentId',
    ];
    return await _api.get('attendances/export/excel?${params.join('&')}');
  }

  /// Student's own attendance history.
  Future<Map<String, dynamic>> getStudentHistory(String studentId,
      {int? month, int? year, int page = 1}) async {
    final params = <String>[
      'page=$page',
      if (month != null) 'month=$month',
      if (year != null) 'year=$year',
    ];

    final response = await _api.get(
        'attendances/student/$studentId?${params.join('&')}',
        requiresAuth: true);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load student attendance history');
  }

  /// Get list of students who checked in to a session, for teacher approval.
  Future<Map<String, dynamic>> getApprovalList(String sessionId) async {
    final response = await _api.get('attendance-sessions/$sessionId/approvals',
        requiresAuth: true);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load approval list');
  }

  /// Approve or reject a single student check-in.
  /// [action] must be 'approved' or 'rejected'.
  Future<Map<String, dynamic>> verifyAttendance({
    required String sessionId,
    required String attendanceId,
    required String action, // 'approved' | 'rejected'
    String? reason,
  }) async {
    final response = await _api.post(
      'attendance-sessions/$sessionId/verify/$attendanceId',
      {
        'action': action,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Verification failed');
  }

  /// Student request permission for a date.
  Future<Map<String, dynamic>> requestPermission({
    required String studentId,
    required String attendanceDate, // YYYY-MM-DD
    required String reason,
    String? imagePath,
    String? scheduleId,
  }) async {
    final fields = <String, String>{
      'student_id': studentId.toString(),
      'attendance_date': attendanceDate,
      'reason': reason,
      if (scheduleId != null) 'schedule_id': scheduleId.toString(),
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      final streamedResponse = await _api.postMultipart(
        'attendances/request-permission',
        fields,
        'image',
        imagePath,
        requiresAuth: true,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Permission request failed');
    } else {
      // Regular POST if no image
      final response = await _api.post(
        'attendances/request-permission',
        fields,
        requiresAuth: true,
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Permission request failed');
    }
  }
}
