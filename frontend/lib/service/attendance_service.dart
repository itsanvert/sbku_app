import 'dart:convert';
import 'package:sbku_app/service/api_service.dart';

class AttendanceService {
  final ApiService _api = ApiService();

  // ── Attendance Sessions ──────────────────────────────────────

  /// Start a new attendance session (teacher).
  Future<Map<String, dynamic>> startSession({
    required int teacherId,
    int? facultyId,
    int? majorId,
    int? scheduleId,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'teacher_id': teacherId,
      if (facultyId != null) 'faculty_id': facultyId,
      if (majorId != null) 'major_id': majorId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await _api.post('attendance-sessions', body, requiresAuth: true);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to start session: ${response.statusCode}');
  }

  /// Get active attendance sessions.
  Future<List<Map<String, dynamic>>> getActiveSessions({int? teacherId}) async {
    String endpoint = 'attendance-sessions/active';
    if (teacherId != null) {
      endpoint += '?teacher_id=$teacherId';
    }

    final response = await _api.get(endpoint);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load active sessions');
  }

  /// Get session details.
  Future<Map<String, dynamic>> getSession(int id) async {
    final response = await _api.get('attendance-sessions/$id');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load session');
  }

  /// Student check-in via QR code.
  Future<Map<String, dynamic>> checkInWithQr({
    required int sessionId,
    required int studentId,
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
  Future<Map<String, dynamic>> endSession(int sessionId) async {
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

  // ── Attendance Reports ───────────────────────────────────────

  /// Get attendances with optional filters.
  Future<Map<String, dynamic>> getAttendances({
    int? studentId,
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
    final response = await _api.get('attendances/report/monthly?month=$month&year=$year');

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

  /// Student's own attendance history.
  Future<Map<String, dynamic>> getStudentHistory(
    int studentId, {
    int? month,
    int? year,
    int page = 1,
  }) async {
    final params = <String>[
      'page=$page',
      if (month != null) 'month=$month',
      if (year != null) 'year=$year',
    ];

    final response = await _api.get('attendances/student/$studentId?${params.join('&')}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load student history');
  }

  // ── Anti-cheating Approval ───────────────────────────────────

  /// Fetch the teacher approval checklist (pending / approved / rejected).
  Future<Map<String, dynamic>> getApprovalList(int sessionId) async {
    final response = await _api.get(
      'attendance-sessions/$sessionId/approvals',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load approval list');
  }

  /// Approve or reject a single student check-in.
  /// [action] must be 'approved' or 'rejected'.
  Future<Map<String, dynamic>> verifyAttendance({
    required int sessionId,
    required int attendanceId,
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
}
