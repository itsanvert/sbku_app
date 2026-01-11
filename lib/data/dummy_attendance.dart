import 'package:sbku_app/domain/entities/attendance_entity.dart';

/// In-memory dummy attendance records
final List<AttendanceEntity> dummyAttendanceEntities = [
  AttendanceEntity(
    id: 'AS001_S001',
    studentId: 'S001',
    studentName: 'Sok Dara',
    facultyId: 'F01',
    majorId: 'M01',
    shiftId: 'SH1',
    classId: 'C01',
    yearId: 'Y1',
    date: DateTime(2025, 1, 10, 8, 0),
    isPresent: true,
  ),
  AttendanceEntity(
    id: 'AS001_S004',
    studentId: 'S004',
    studentName: 'Sophea Chen',
    facultyId: 'F01',
    majorId: 'M01',
    shiftId: 'SH1',
    classId: 'C01',
    yearId: 'Y1',
    date: DateTime(2025, 1, 10, 8, 0),
    isPresent: true,
  ),
  AttendanceEntity(
    id: 'AS001_S007',
    studentId: 'S007',
    studentName: 'Sreymom Ly',
    facultyId: 'F01',
    majorId: 'M01',
    shiftId: 'SH1',
    classId: 'C01',
    yearId: 'Y1',
    date: DateTime(2025, 1, 10, 8, 0),
    isPresent: false,
  ),

  // -----------------------------
  // Class C02
  // -----------------------------
  AttendanceEntity(
    id: 'AS002_S002',
    studentId: 'S002',
    studentName: 'Chanthy Sok',
    facultyId: 'F02',
    majorId: 'M02',
    shiftId: 'SH2',
    classId: 'C02',
    yearId: 'Y2',
    date: DateTime(2025, 1, 9, 14, 0),
    isPresent: true,
  ),
  AttendanceEntity(
    id: 'AS002_S008',
    studentId: 'S008',
    studentName: 'Visal Chea',
    facultyId: 'F02',
    majorId: 'M02',
    shiftId: 'SH2',
    classId: 'C02',
    yearId: 'Y2',
    date: DateTime(2025, 1, 9, 14, 0),
    isPresent: true,
  ),

  // -----------------------------
  // Class C03
  // -----------------------------
  AttendanceEntity(
    id: 'AS004_S003',
    studentId: 'S003',
    studentName: 'Vannak Lim',
    facultyId: 'F01',
    majorId: 'M01',
    shiftId: 'SH3',
    classId: 'C03',
    yearId: 'Y3',
    date: DateTime(2025, 1, 7, 16, 0),
    isPresent: true,
  ),
];
