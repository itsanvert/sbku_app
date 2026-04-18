/// Centralized enums to replace scattered magic strings throughout the app.

// ── User Roles ──────────────────────────────────────────────────────────────

enum UserRole {
  admin('admin'),
  teacher('teacher'),
  student('student');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? s) =>
      UserRole.values.firstWhere(
        (e) => e.value == s?.toLowerCase(),
        orElse: () => UserRole.student,
      );
}

// ── Gender ──────────────────────────────────────────────────────────────────

enum Gender {
  male('male', 'Male'),
  female('female', 'Female');

  final String value;
  final String label;
  const Gender(this.value, this.label);

  static Gender fromString(String? s) =>
      Gender.values.firstWhere(
        (e) => e.value == s?.toLowerCase(),
        orElse: () => Gender.male,
      );
}

// ── Shift ────────────────────────────────────────────────────────────────────

enum ShiftType {
  morning('morning', 'Morning', 'ព្រឹក'),
  afternoon('afternoon', 'Afternoon', 'រសៀល'),
  evening('evening', 'Evening', 'ល្ងាច');

  final String value;
  final String label;
  final String khmerLabel;
  const ShiftType(this.value, this.label, this.khmerLabel);

  static ShiftType fromString(String? s) =>
      ShiftType.values.firstWhere(
        (e) => e.value == s?.toLowerCase(),
        orElse: () => ShiftType.morning,
      );
}

// ── Attendance Status ───────────────────────────────────────────────────────

enum AttendanceStatus {
  present('Y', 'Present'),
  absent('N', 'Absent'),
  permission('P', 'Permission');

  final String code;
  final String label;
  const AttendanceStatus(this.code, this.label);

  static AttendanceStatus fromCode(String? s) =>
      AttendanceStatus.values.firstWhere(
        (e) => e.code == s,
        orElse: () => AttendanceStatus.absent,
      );
}

// ── Verify Status ───────────────────────────────────────────────────────────

enum VerifyStatus {
  pending('pending', 'Pending'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected');

  final String value;
  final String label;
  const VerifyStatus(this.value, this.label);

  static VerifyStatus fromString(String? s) =>
      VerifyStatus.values.firstWhere(
        (e) => e.value == s?.toLowerCase(),
        orElse: () => VerifyStatus.pending,
      );
}

// ── Sort Direction ──────────────────────────────────────────────────────────

enum SortDirection {
  asc('asc'),
  desc('desc');

  final String value;
  const SortDirection(this.value);
}
