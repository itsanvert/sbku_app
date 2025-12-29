import 'dart:ui';

import 'package:flutter/material.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName; // Add this
  final String facultyId;
  final String majorId;
  final String classId;
  final String yearId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isPresent;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.facultyId,
    required this.majorId,
    required this.classId,
    required this.yearId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isPresent,
  });

  // Helper getter for avatar letter
  String get avatarLetter =>
      studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';

  // Helper getter for formatted date
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper getter for time range
  String get timeRange => '$startTime - $endTime';

  // Helper getter for status
  String get statusLabel => isPresent ? 'មានវត្តមាន' : 'អវត្តមាន';

  // Helper getter for status color
  Color get statusColor => isPresent ? Colors.green : Colors.red;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'facultyId': facultyId,
      'majorId': majorId,
      'classId': classId,
      'yearId': yearId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isPresent': isPresent,
    };
  }

  // Create from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      facultyId: json['facultyId'],
      majorId: json['majorId'],
      classId: json['classId'],
      yearId: json['yearId'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      isPresent: json['isPresent'],
    );
  }

  // Copy with method for editing
  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? facultyId,
    String? majorId,
    String? classId,
    String? yearId,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isPresent,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      facultyId: facultyId ?? this.facultyId,
      majorId: majorId ?? this.majorId,
      classId: classId ?? this.classId,
      yearId: yearId ?? this.yearId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}
