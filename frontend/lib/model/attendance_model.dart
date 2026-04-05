import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_data.dart';
import 'package:sbku_app/domain/entities/attendance_entity.dart';
class AttendanceModel {
  final AttendanceEntity entity;
  // UI-resolved values
  final String facultyName;
  final String majorName;
  final String shiftName;
  final String className;
  final String yearName;
  final String startTime;
  final String endTime;

  AttendanceModel({
    required this.entity,
    required this.facultyName,
    required this.majorName,
    required this.shiftName,
    required this.className,
    required this.yearName,
    required this.startTime,
    required this.endTime,
  });

  /// ✅ Factory: Entity → UI Model
  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    final faculty = dummyFaculties.firstWhere((f) => f.id == entity.facultyId);
    final major = dummyMajors.firstWhere((m) => m.id == entity.majorId);
    final shift = dummyShifts.firstWhere((s) => s.id == entity.shiftId);
    final classRoom =
        dummyClasses.firstWhere((c) => c.id == entity.classId);
    final year = dummyYears.firstWhere((y) => y.id == entity.yearId);

    return AttendanceModel(
      entity: entity,
      facultyName: faculty.facultyName,
      majorName: major.majorName,
      shiftName: shift.shiftName,
      className: classRoom.className,
      yearName: year.yearName,
      startTime: shift.startTime,
      endTime: shift.endTime,
    );
  }

  // 🔹 UI Helpers
  String get studentName => entity.studentName;

  String get avatarLetter =>
      studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';

  String get formattedDate =>
      '${entity.date.day}/${entity.date.month}/${entity.date.year}';

  String get timeRange => '$startTime - $endTime';

  String get statusLabel {
    if (entity.isPermission) {
      if (entity.verifyStatus == 'pending') return 'រង់ចាំការអនុញ្ញាត';
      if (entity.verifyStatus == 'approved') return 'អនុញ្ញាត (ច្បាប់)';
      if (entity.verifyStatus == 'rejected') return 'បដិសេធច្បាប់ (អវត្តមាន)';
      return 'ច្បាប់';
    }
    if (entity.isPresent) {
      return entity.verifyStatus == 'pending' ? 'រង់ចាំការបញ្ជាក់' : 'មានវត្តមាន';
    }
    return 'អវត្តមាន';
  }

  Color get statusColor {
    if (entity.isPermission) {
      if (entity.verifyStatus == 'pending') return Colors.orange;
      if (entity.verifyStatus == 'approved') return Colors.blue;
      return Colors.red;
    }
    if (entity.isPresent) {
      return entity.verifyStatus == 'pending' ? Colors.teal : Colors.green;
    }
    return Colors.red;
  }
}
