/// Centralized API endpoint constants.
/// Eliminates scattered string literals across services.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ────────────────────────────────────────────────────
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String user = 'user';

  // ── Profile ─────────────────────────────────────────────────
  static const String profileInfo = 'user/profile-information';
  static const String profilePassword = 'user/password';
  static const String profilePhoto = 'user/profile-photo';

  // ── Students ────────────────────────────────────────────────
  static const String students = 'students';
  static String student(int id) => 'students/$id';

  // ── Teachers ────────────────────────────────────────────────
  static const String teachers = 'teachers';
  static String teacher(int id) => 'teachers/$id';

  // ── Attendance Sessions ─────────────────────────────────────
  static const String attendanceSessions = 'attendance-sessions';
  static const String activeSessions = 'attendance-sessions/active';
  static String session(int id) => 'attendance-sessions/$id';
  static String checkIn(int sessionId) => 'attendance-sessions/$sessionId/check-in';
  static String endSession(int sessionId) => 'attendance-sessions/$sessionId/end';
  static String approvals(int sessionId) => 'attendance-sessions/$sessionId/approvals';
  static String verify(int sessionId, int attendanceId) =>
      'attendance-sessions/$sessionId/verify/$attendanceId';

  // ── Attendance Reports ──────────────────────────────────────
  static const String attendances = 'attendances';
  static const String dailyReport = 'attendances/report/daily';
  static const String monthlyReport = 'attendances/report/monthly';
  static const String yearlyReport = 'attendances/report/yearly';
  static const String exportPdf = 'attendances/export/pdf';
  static const String exportExcel = 'attendances/export/excel';
  static String studentHistory(int studentId) => 'attendances/student/$studentId';
  static const String requestPermission = 'attendances/request-permission';

  // ── Syllabus ────────────────────────────────────────────────
  static const String syllabus = 'syllabus';
}
