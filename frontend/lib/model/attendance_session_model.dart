import 'package:sbku_app/domain/entities/attendance_entity.dart';
import 'package:sbku_app/domain/entities/student_entity.dart';

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
  final List<String> attendedStudentIds; // List of student IDs who checked in

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
  });

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
        isPresent: isPresent,
      );
    }).toList();
  }
}
