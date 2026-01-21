// lib/data/dummy_attendance_session.dart
// Complete working version based on your exact entity structures

import 'package:sbku_app/domain/entities/attendance_entity.dart';
import 'package:sbku_app/domain/entities/student_entity.dart';
import 'package:sbku_app/data/dummy_attendance.dart';
import 'package:sbku_app/model/attendance_session_model.dart';

// ==========================================
// STUDENT DATA
// ==========================================
final List<StudentEntity> dummyStudents = [
  // Class C01 - Faculty F01, Major M01, Year Y1, Shift SH1 (5 students)
  StudentEntity(
    studentId: 'S001',
    studentName: 'Sok Dara',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
  ),
  StudentEntity(
    studentId: 'S004',
    studentName: 'Sophea Chen',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
  ),
  StudentEntity(
    studentId: 'S005',
    studentName: 'Rachana Pov',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
  ),
  StudentEntity(
    studentId: 'S006',
    studentName: 'Dara Kim',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
  ),
  StudentEntity(
    studentId: 'S007',
    studentName: 'Sreymom Ly',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
  ),

  // Class C02 - Faculty F02, Major M02, Year Y2, Shift SH2 (3 students)
  StudentEntity(
    studentId: 'S002',
    studentName: 'Chanthy Sok',
    facultyId: 'F02',
    majorId: 'M02',
    classId: 'C02',
    yearId: 'Y2',
    shiftId: 'SH2',
  ),
  StudentEntity(
    studentId: 'S008',
    studentName: 'Visal Chea',
    facultyId: 'F02',
    majorId: 'M02',
    classId: 'C02',
    yearId: 'Y2',
    shiftId: 'SH2',
  ),
  StudentEntity(
    studentId: 'S010',
    studentName: 'Chamroeun Heng',
    facultyId: 'F02',
    majorId: 'M02',
    classId: 'C02',
    yearId: 'Y2',
    shiftId: 'SH2',
  ),

  // Class C03 - Faculty F01, Major M01, Year Y3, Shift SH3 (2 students)
  StudentEntity(
    studentId: 'S003',
    studentName: 'Vannak Lim',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C03',
    yearId: 'Y3',
    shiftId: 'SH3',
  ),
  StudentEntity(
    studentId: 'S009',
    studentName: 'Bopha Tan',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C03',
    yearId: 'Y3',
    shiftId: 'SH3',
  ),
];

// ==========================================
// STUDENT HELPER FUNCTIONS
// ==========================================

StudentEntity? getStudentById(String studentId) {
  try {
    return dummyStudents.firstWhere((s) => s.studentId == studentId);
  } catch (e) {
    return null;
  }
}

String getStudentNameById(String studentId) {
  try {
    return dummyStudents
        .firstWhere((s) => s.studentId == studentId)
        .studentName;
  } catch (e) {
    return 'Unknown Student';
  }
}

List<StudentEntity> getStudentsByClass({
  required String facultyId,
  required String majorId,
  required String classId,
  required String yearId,
  required String shiftId,
}) {
  return dummyStudents
      .where((student) =>
          student.facultyId == facultyId &&
          student.majorId == majorId &&
          student.classId == classId &&
          student.yearId == yearId &&
          student.shiftId == shiftId)
      .toList();
}

int getStudentCountByClass({
  required String facultyId,
  required String majorId,
  required String classId,
  required String yearId,
  required String shiftId,
}) {
  return getStudentsByClass(
    facultyId: facultyId,
    majorId: majorId,
    classId: classId,
    yearId: yearId,
    shiftId: shiftId,
  ).length;
}

// ==========================================
// ATTENDANCE SESSIONS DATA
// ==========================================

List<AttendanceSession> attendanceSessions = [
  // Session 1: Class C01 - Good attendance (4/5 students)
  AttendanceSession(
    id: 'AS001',
    teacherId: 'T001',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
    latitude: 11.5564, // Phnom Penh coordinates
    longitude: 104.9282,
    startTime: DateTime(2025, 1, 10, 8, 0),
    endTime: DateTime(2025, 1, 10, 10, 0),
    isActive: false,
    attendedStudentIds: ['S001', 'S004', 'S005', 'S006'], // S007 absent
  ),

  // Session 2: Class C02 - Perfect attendance (3/3 students)
  AttendanceSession(
    id: 'AS002',
    teacherId: 'T002',
    facultyId: 'F02',
    majorId: 'M02',
    classId: 'C02',
    yearId: 'Y2',
    shiftId: 'SH2',
    latitude: 11.5565,
    longitude: 104.9283,
    startTime: DateTime(2025, 1, 9, 14, 0),
    endTime: DateTime(2025, 1, 9, 16, 0),
    isActive: false,
    attendedStudentIds: ['S002', 'S008', 'S010'], // All present
  ),

  // Session 3: Class C01 - Low attendance (2/5 students)
  AttendanceSession(
    id: 'AS003',
    teacherId: 'T001',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
    latitude: 11.5566,
    longitude: 104.9284,
    startTime: DateTime(2025, 1, 8, 8, 0),
    endTime: DateTime(2025, 1, 8, 10, 0),
    isActive: false,
    attendedStudentIds: ['S001', 'S005'], // Only 2 attended
  ),

  // Session 4: Class C03 - Full attendance (2/2 students)
  AttendanceSession(
    id: 'AS004',
    teacherId: 'T001',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C03',
    yearId: 'Y3',
    shiftId: 'SH3',
    latitude: 11.5567,
    longitude: 104.9285,
    startTime: DateTime(2025, 1, 7, 16, 0),
    endTime: DateTime(2025, 1, 7, 18, 0),
    isActive: false,
    attendedStudentIds: ['S003', 'S009'], // All present
  ),
];

// ==========================================
// SESSION MANAGEMENT FUNCTIONS
// ==========================================

/// Generate AttendanceEntity records from a completed session
void generateAttendanceFromSession(AttendanceSession session) {
  // Get all students in the class
  final classStudents = getStudentsByClass(
    facultyId: session.facultyId,
    majorId: session.majorId,
    classId: session.classId,
    yearId: session.yearId,
    shiftId: session.shiftId,
  );

  // Create attendance record for each student
  for (var student in classStudents) {
    final isPresent = session.attendedStudentIds.contains(student.studentId);

    final attendanceRecord = AttendanceEntity(
      id: '${session.id}_${student.studentId}',
      studentId: student.studentId,
      studentName: student.studentName,
      facultyId: session.facultyId,
      majorId: session.majorId,
      shiftId: session.shiftId,
      classId: session.classId,
      yearId: session.yearId,
      date: session.startTime,
      isPresent: isPresent,
    );

    dummyAttendanceEntities.add(attendanceRecord);
  }
}

/// Initialize attendance data from all completed sessions
void initializeAttendanceData() {
  // Clear existing data
  dummyAttendanceEntities.clear();

  // Generate attendance records from all closed sessions
  final closedSessions = attendanceSessions.where((s) => !s.isActive).toList();

  for (var session in closedSessions) {
    generateAttendanceFromSession(session);
  }
}

/// Get all active sessions
List<AttendanceSession> getActiveSessions() {
  return attendanceSessions.where((s) => s.isActive).toList();
}

/// Get all past/closed sessions
List<AttendanceSession> getPastSessions() {
  return attendanceSessions.where((s) => !s.isActive).toList();
}

/// Get sessions by teacher ID
List<AttendanceSession> getSessionsByTeacher(String teacherId) {
  return attendanceSessions.where((s) => s.teacherId == teacherId).toList();
}

/// Get sessions by class details
List<AttendanceSession> getSessionsByClass({
  required String facultyId,
  required String majorId,
  required String classId,
  required String yearId,
  required String shiftId,
}) {
  return attendanceSessions
      .where((s) =>
          s.facultyId == facultyId &&
          s.majorId == majorId &&
          s.classId == classId &&
          s.yearId == yearId &&
          s.shiftId == shiftId)
      .toList();
}

/// Find a session by ID
AttendanceSession? findSessionById(String sessionId) {
  try {
    return attendanceSessions.firstWhere((s) => s.id == sessionId);
  } catch (e) {
    return null;
  }
}

/// Update an existing session
void updateSession(AttendanceSession updatedSession) {
  final index = attendanceSessions.indexWhere((s) => s.id == updatedSession.id);
  if (index != -1) {
    attendanceSessions[index] = updatedSession;
  }
}

/// Add a new session
void addSession(AttendanceSession newSession) {
  attendanceSessions.add(newSession);
}

/// Calculate attendance statistics for a class
Map<String, dynamic> getClassAttendanceStats({
  required String facultyId,
  required String majorId,
  required String classId,
  required String yearId,
  required String shiftId,
}) {
  // Get all closed sessions for this class
  final sessions = getSessionsByClass(
    facultyId: facultyId,
    majorId: majorId,
    classId: classId,
    yearId: yearId,
    shiftId: shiftId,
  ).where((s) => !s.isActive).toList();

  // Get total students in class
  final totalStudents = getStudentCountByClass(
    facultyId: facultyId,
    majorId: majorId,
    classId: classId,
    yearId: yearId,
    shiftId: shiftId,
  );

  final totalSessions = sessions.length;
  final totalPossibleAttendance = totalStudents * totalSessions;

  // Calculate actual attendance
  int totalActualAttendance = 0;
  for (var session in sessions) {
    totalActualAttendance += session.attendedStudentIds.length;
  }

  // Calculate percentage
  final attendanceRate = totalPossibleAttendance > 0
      ? (totalActualAttendance / totalPossibleAttendance * 100)
          .toStringAsFixed(1)
      : '0.0';

  return {
    'totalSessions': totalSessions,
    'totalStudents': totalStudents,
    'totalPossibleAttendance': totalPossibleAttendance,
    'totalActualAttendance': totalActualAttendance,
    'attendanceRate': attendanceRate,
    'attendanceRateDouble': totalPossibleAttendance > 0
        ? (totalActualAttendance / totalPossibleAttendance * 100)
        : 0.0,
  };
}

/// Get student attendance history
List<AttendanceEntity> getStudentAttendanceHistory(String studentId) {
  return dummyAttendanceEntities.where((a) => a.studentId == studentId).toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
}

/// Get attendance statistics for a specific student
Map<String, dynamic> getStudentAttendanceStats(String studentId) {
  final studentRecords = getStudentAttendanceHistory(studentId);
  final totalSessions = studentRecords.length;
  final presentCount = studentRecords.where((r) => r.isPresent).length;
  final absentCount = totalSessions - presentCount;

  final attendanceRate = totalSessions > 0
      ? (presentCount / totalSessions * 100).toStringAsFixed(1)
      : '0.0';

  return {
    'totalSessions': totalSessions,
    'presentCount': presentCount,
    'absentCount': absentCount,
    'attendanceRate': attendanceRate,
    'attendanceRateDouble':
        totalSessions > 0 ? (presentCount / totalSessions * 100) : 0.0,
  };
}
