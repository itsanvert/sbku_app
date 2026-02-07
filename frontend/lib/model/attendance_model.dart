import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_class.dart';
import 'package:sbku_app/data/dummy_major.dart';
import 'package:sbku_app/data/dummy_shirt.dart';
import 'package:sbku_app/domain/entities/attendance_entity.dart';
import 'package:sbku_app/data/dummy_faculty.dart';
import 'package:sbku_app/data/dummy_year.dart';

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

  String get statusLabel => entity.isPresent ? 'មានវត្តមាន' : 'អវត្តមាន';

  Color get statusColor => entity.isPresent ? Colors.green : Colors.red;
}
