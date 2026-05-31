import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sbku_app/core/constants/api_endpoints.dart';
import 'package:sbku_app/core/network/api_error_handler.dart';
import 'package:sbku_app/core/result.dart';
import 'package:sbku_app/domain/repositories/attendance_repository.dart';
import 'package:sbku_app/service/api_service.dart';

/// Concrete implementation of [AttendanceRepository] backed by the REST API.
class AttendanceRepositoryImpl
    with ApiErrorHandler
    implements AttendanceRepository {
  final ApiService _api;

  AttendanceRepositoryImpl({required ApiService apiService}) : _api = apiService;

  // ── Helper ──────────────────────────────────────────────────

  Map<String, dynamic> _decodeJson(http.Response response) =>
      jsonDecode(response.body) as Map<String, dynamic>;

  void _assertSuccess(http.Response response, [String? fallbackMessage]) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = fallbackMessage ?? 'Request failed (HTTP ${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          message = body['message'];
        } else if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as Map;
          message = errors.values
              .map((v) => v is List ? v.join(', ') : v.toString())
              .join('\n');
        }
      } catch (_) {}
      throw ServerException(message, response.statusCode);
    }
  }

  // ── Sessions ────────────────────────────────────────────────

  @override
  Future<Result<Map<String, dynamic>>> startSession({
    required int teacherId,
    int? facultyId,
    int? majorId,
    int? scheduleId,
    double? latitude,
    double? longitude,
  }) {
    return guardAsync(() async {
      final body = <String, dynamic>{
        'teacher_id': teacherId,
        if (facultyId != null) 'faculty_id': facultyId,
        if (majorId != null) 'major_id': majorId,
        if (scheduleId != null) 'schedule_id': scheduleId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      final response = await _api.post(
        ApiEndpoints.attendanceSessions,
        body,
        requiresAuth: true,
      );
      _assertSuccess(response, 'Failed to start session');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getActiveSessions({
    int? teacherId,
  }) {
    return guardAsync(() async {
      String endpoint = ApiEndpoints.activeSessions;
      if (teacherId != null) {
        endpoint += '?teacher_id=$teacherId';
      }

      final response = await _api.get(endpoint);
      _assertSuccess(response, 'Failed to load active sessions');
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map && decoded.containsKey('data')) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      }
      return <Map<String, dynamic>>[];
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getSession(int id) {
    return guardAsync(() async {
      final response = await _api.get(ApiEndpoints.session(id));
      _assertSuccess(response, 'Failed to load session');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> checkInWithQr({
    required int sessionId,
    required int studentId,
    required String qrToken,
  }) {
    return guardAsync(() async {
      final response = await _api.post(
        ApiEndpoints.checkIn(sessionId),
        {
          'student_id': studentId,
          'qr_token': qrToken,
        },
        requiresAuth: true,
      );
      _assertSuccess(response, 'Check-in failed');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> endSession(int sessionId) {
    return guardAsync(() async {
      final response = await _api.post(
        ApiEndpoints.endSession(sessionId),
        {},
        requiresAuth: true,
      );
      _assertSuccess(response, 'Failed to end session');
      return _decodeJson(response);
    });
  }

  // ── Reports ─────────────────────────────────────────────────

  @override
  Future<Result<Map<String, dynamic>>> getAttendances({
    int? studentId,
    String? date,
    int? month,
    int? year,
    String? status,
    int page = 1,
  }) {
    return guardAsync(() async {
      final params = <String>[
        'page=$page',
        if (studentId != null) 'student_id=$studentId',
        if (date != null) 'date=$date',
        if (month != null) 'month=$month',
        if (year != null) 'year=$year',
        if (status != null) 'status=$status',
      ];

      final response = await _api.get(
        '${ApiEndpoints.attendances}?${params.join('&')}',
      );
      _assertSuccess(response, 'Failed to load attendances');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getDailyReport(String date) {
    return guardAsync(() async {
      final response = await _api.get('${ApiEndpoints.dailyReport}?date=$date');
      _assertSuccess(response, 'Failed to load daily report');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getMonthlyReport(int month, int year) {
    return guardAsync(() async {
      final response = await _api.get(
        '${ApiEndpoints.monthlyReport}?month=$month&year=$year',
      );
      _assertSuccess(response, 'Failed to load monthly report');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getYearlyReport(int year) {
    return guardAsync(() async {
      final response = await _api.get(
        '${ApiEndpoints.yearlyReport}?year=$year',
      );
      _assertSuccess(response, 'Failed to load yearly report');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getStudentHistory(
    int studentId, {
    int? month,
    int? year,
    int page = 1,
  }) {
    return guardAsync(() async {
      final params = <String>[
        'page=$page',
        if (month != null) 'month=$month',
        if (year != null) 'year=$year',
      ];

      final response = await _api.get(
        '${ApiEndpoints.studentHistory(studentId)}?${params.join('&')}',
        requiresAuth: true,
      );
      _assertSuccess(response, 'Failed to load student history');
      return _decodeJson(response);
    });
  }

  // ── Approvals ───────────────────────────────────────────────

  @override
  Future<Result<Map<String, dynamic>>> getApprovalList(int sessionId) {
    return guardAsync(() async {
      final response = await _api.get(
        ApiEndpoints.approvals(sessionId),
        requiresAuth: true,
      );
      _assertSuccess(response, 'Failed to load approval list');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> verifyAttendance({
    required int sessionId,
    required int attendanceId,
    required String action,
    String? reason,
  }) {
    return guardAsync(() async {
      final response = await _api.post(
        ApiEndpoints.verify(sessionId, attendanceId),
        {
          'action': action,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
        requiresAuth: true,
      );
      _assertSuccess(response, 'Verification failed');
      return _decodeJson(response);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> requestPermission({
    required int studentId,
    required String attendanceDate,
    required String reason,
    String? imagePath,
    int? scheduleId,
  }) {
    return guardAsync(() async {
      final fields = <String, String>{
        'student_id': studentId.toString(),
        'attendance_date': attendanceDate,
        'reason': reason,
        if (scheduleId != null) 'schedule_id': scheduleId.toString(),
      };

      if (imagePath != null && imagePath.isNotEmpty) {
        final streamedResponse = await _api.postMultipart(
          ApiEndpoints.requestPermission,
          fields,
          'image',
          imagePath,
          requiresAuth: true,
        );
        final response = await http.Response.fromStream(streamedResponse);
        _assertSuccess(response, 'Permission request failed');
        return _decodeJson(response);
      } else {
        final response = await _api.post(
          ApiEndpoints.requestPermission,
          fields,
          requiresAuth: true,
        );
        _assertSuccess(response, 'Permission request failed');
        return _decodeJson(response);
      }
    });
  }
}
