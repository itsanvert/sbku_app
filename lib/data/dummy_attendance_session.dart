import 'package:sbku_app/domain/entities/attendance_entity.dart';
import 'package:sbku_app/data/dummy_students.dart';
import 'package:sbku_app/domain/entities/student_entity.dart';
import 'package:sbku_app/model/attendance_session_model.dart';

// Store active and past sessions
List<AttendanceSession> attendanceSessions = [
  // Example past session
  AttendanceSession(
    id: 'AS001',
    teacherId: 'T001',
    facultyId: 'F01',
    majorId: 'M01',
    classId: 'C01',
    yearId: 'Y1',
    shiftId: 'SH1',
    latitude: 11.5564,
    longitude: 104.9282,
    startTime: DateTime(2025, 1, 1, 8, 0),
    endTime: DateTime(2025, 1, 1, 10, 0),
    isActive: false,
    attendedStudentIds: ['S001', 'S004'], // Students who attended
  ),
];

// Generate AttendanceEntity records from completed sessions
List<AttendanceEntity> dummyAttendanceEntities = [];

// Call this function when a session ends to generate attendance records
void generateAttendanceFromSession(AttendanceSession session) {
  // Get all students in the session's class
  final classStudents = dummyStudents
      .where((student) =>
          student.facultyId == session.facultyId &&
          student.majorId == session.majorId &&
          student.classId == session.classId &&
          student.yearId == session.yearId &&
          student.shiftId == session.shiftId)
      .toList();

  // Convert session to attendance entities
  final attendanceRecords = session.toAttendanceEntities(classStudents);

  // Add to dummy attendance list
  dummyAttendanceEntities.addAll(attendanceRecords);
}

// Helper to get student name by ID
String getStudentNameById(String studentId) {
  try {
    return dummyStudents
        .firstWhere((s) => s.studentId == studentId)
        .studentName;
  } catch (e) {
    return 'Unknown Student';
  }
}

// Helper to get students in a specific class
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
