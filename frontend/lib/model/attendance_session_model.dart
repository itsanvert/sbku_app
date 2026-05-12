import 'package:sbku_app/domain/entities/attendance_entity.dart';
import 'package:sbku_app/domain/entities/student_entity.dart';

/// Represents the lifecycle status of an attendance session.
enum SessionStatus {
  /// Session has not reached its scheduled start time yet.
  upcoming,

  /// Session is currently active and accepting check-ins.
  active,

  /// Session has passed its scheduled end time and is closed.
  ended,
}

class AttendanceSession {
  final String id;
  final String teacherId;
  final String facultyId;
  final String majorId;
  final String classId;
  final String yearId;
  final String shiftId;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final List<String> attendedStudentIds;

  /// The scheduled start time for this session (from syllabus/schedule).
  final String? sessionStartTime; // e.g. "08:00"

  /// The scheduled end time for this session (from syllabus/schedule).
  final String? sessionEndTime; // e.g. "10:00"

  /// The unique QR token for this session — renewed each time the session starts.
  final String? qrToken;

  /// The day of the week this session is scheduled for.
  final String? dayOfWeek;

  AttendanceSession({
    required this.id,
    required this.teacherId,
    required this.facultyId,
    required this.majorId,
    required this.classId,
    required this.yearId,
    required this.shiftId,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    this.endTime,
    this.isActive = true,
    this.attendedStudentIds = const [],
    this.sessionStartTime,
    this.sessionEndTime,
    this.qrToken,
    this.dayOfWeek,
  });

  // ── Session Status Logic ─────────────────────────────────────────

  /// Determine the current lifecycle status of this session based on
  /// the scheduled start/end times and the current clock.
  SessionStatus get status {
    // If the backend already marked it inactive, it's ended.
    if (!isActive || endTime != null) return SessionStatus.ended;

    final now = DateTime.now();

    // If we have scheduled time boundaries, use them.
    if (sessionStartTime != null && sessionEndTime != null) {
      final scheduledStart = _todayAt(sessionStartTime!);
      final scheduledEnd = _todayAt(sessionEndTime!);

      if (now.isBefore(scheduledStart)) return SessionStatus.upcoming;
      if (now.isAfter(scheduledEnd)) return SessionStatus.ended;
      return SessionStatus.active;
    }

    // Fallback: treat as active if is_active is true.
    return SessionStatus.active;
  }

  /// Whether students can currently check in to this session.
  bool get canCheckIn => status == SessionStatus.active;

  /// Whether the teacher can close/end this session.
  /// Only active sessions can be manually closed.
  bool get canEndSession => status == SessionStatus.active;

  /// Whether the session time has expired (past scheduled end time).
  bool get isExpired => status == SessionStatus.ended;

  /// Whether the session hasn't started yet.
  bool get isUpcoming => status == SessionStatus.upcoming;

  /// Human-readable label for the current status.
  String get statusLabel {
    switch (status) {
      case SessionStatus.upcoming:
        return 'មិនទាន់ចាប់ផ្តើម'; // Not started yet
      case SessionStatus.active:
        return 'កំពុងដំណើរការ'; // In progress
      case SessionStatus.ended:
        return 'បានបញ្ចប់'; // Ended
    }
  }

  /// Time remaining until session ends, or null if not active.
  Duration? get timeRemaining {
    if (status != SessionStatus.active || sessionEndTime == null) return null;
    final scheduledEnd = _todayAt(sessionEndTime!);
    final diff = scheduledEnd.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Formatted time slot string (e.g. "08:00 - 10:00").
  String? get formattedTimeSlot {
    if (sessionStartTime == null || sessionEndTime == null) return null;
    return '$sessionStartTime - $sessionEndTime';
  }

  // ── Helper ───────────────────────────────────────────────────────

  /// Parse a time string like "08:00" or "08:00:00" into today's DateTime.
  DateTime _todayAt(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final second = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  // ── JSON Factory ─────────────────────────────────────────────────

  /// Create an AttendanceSession from a backend JSON map.
  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      facultyId: json['faculty_id']?.toString() ?? '',
      majorId: json['major_id']?.toString() ?? '',
      classId: json['academic_class_id']?.toString() ?? '',
      yearId: json['year_id']?.toString() ?? '',
      shiftId: json['shift_id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      startTime: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endTime: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      attendedStudentIds: json['attended_student_ids'] != null
          ? List<String>.from(
              (json['attended_student_ids'] as List).map((e) => e.toString()))
          : const [],
      sessionStartTime: json['session_start_time']?.toString(),
      sessionEndTime: json['session_end_time']?.toString(),
      qrToken: json['qr_token']?.toString(),
      dayOfWeek: json['day_of_week']?.toString(),
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'faculty_id': facultyId,
      'major_id': majorId,
      'academic_class_id': classId,
      'year_id': yearId,
      'shift_id': shiftId,
      'latitude': latitude,
      'longitude': longitude,
      'started_at': startTime.toIso8601String(),
      'ended_at': endTime?.toIso8601String(),
      'is_active': isActive,
      'session_start_time': sessionStartTime,
      'session_end_time': sessionEndTime,
      'qr_token': qrToken,
      'day_of_week': dayOfWeek,
    };
  }

  AttendanceSession copyWith({
    String? id,
    String? teacherId,
    String? facultyId,
    String? majorId,
    String? classId,
    String? yearId,
    String? shiftId,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    List<String>? attendedStudentIds,
    String? sessionStartTime,
    String? sessionEndTime,
    String? qrToken,
    String? dayOfWeek,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      facultyId: facultyId ?? this.facultyId,
      majorId: majorId ?? this.majorId,
      classId: classId ?? this.classId,
      yearId: yearId ?? this.yearId,
      shiftId: shiftId ?? this.shiftId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      attendedStudentIds: attendedStudentIds ?? this.attendedStudentIds,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionEndTime: sessionEndTime ?? this.sessionEndTime,
      qrToken: qrToken ?? this.qrToken,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    );
  }

  // Convert session to list of AttendanceEntity for all students in class
  List<AttendanceEntity> toAttendanceEntities(
      List<StudentEntity> classStudents) {
    return classStudents.map((student) {
      final isPresent = attendedStudentIds.contains(student.id);

      return AttendanceEntity(
        id: '${id}_${student.id}',
        studentId: student.id,
        studentName: student.studentName,
        facultyId: facultyId,
        majorId: majorId,
        shiftId: shiftId,
        classId: classId,
        yearId: yearId,
        date: startTime,
        status: isPresent ? 'Y' : 'N',
        verifyStatus: 'approved',
      );
    }).toList();
  }
}
