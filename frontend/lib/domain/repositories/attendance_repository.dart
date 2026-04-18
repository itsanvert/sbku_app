import 'package:sbku_app/core/result.dart';

/// Contract for attendance-related data operations.
abstract class AttendanceRepository {
  // ── Sessions ────────────────────────────────────────────────

  /// Start a new attendance session (teacher-only).
  Future<Result<Map<String, dynamic>>> startSession({
    required int teacherId,
    int? facultyId,
    int? majorId,
    int? scheduleId,
    double? latitude,
    double? longitude,
  });

  /// Get a list of currently active sessions.
  Future<Result<List<Map<String, dynamic>>>> getActiveSessions({int? teacherId});

  /// Get session details by ID.
  Future<Result<Map<String, dynamic>>> getSession(int id);

  /// Student QR check-in.
  Future<Result<Map<String, dynamic>>> checkInWithQr({
    required int sessionId,
    required int studentId,
    required String qrToken,
  });

  /// End a session and finalize attendance records.
  Future<Result<Map<String, dynamic>>> endSession(int sessionId);

  // ── Reports ─────────────────────────────────────────────────

  /// Get attendances with optional filters.
  Future<Result<Map<String, dynamic>>> getAttendances({
    int? studentId,
    String? date,
    int? month,
    int? year,
    String? status,
    int page = 1,
  });

  /// Daily attendance report.
  Future<Result<Map<String, dynamic>>> getDailyReport(String date);

  /// Monthly attendance report.
  Future<Result<Map<String, dynamic>>> getMonthlyReport(int month, int year);

  /// Yearly attendance report.
  Future<Result<Map<String, dynamic>>> getYearlyReport(int year);

  /// Student's own attendance history.
  Future<Result<Map<String, dynamic>>> getStudentHistory(
    int studentId, {
    int? month,
    int? year,
    int page = 1,
  });

  // ── Approvals ───────────────────────────────────────────────

  /// Get list of check-ins for teacher approval.
  Future<Result<Map<String, dynamic>>> getApprovalList(int sessionId);

  /// Approve or reject a student check-in.
  Future<Result<Map<String, dynamic>>> verifyAttendance({
    required int sessionId,
    required int attendanceId,
    required String action, // 'approved' | 'rejected'
    String? reason,
  });

  /// Student request permission for a date.
  Future<Result<Map<String, dynamic>>> requestPermission({
    required int studentId,
    required String attendanceDate,
    required String reason,
    String? imagePath,
    int? scheduleId,
  });
}
