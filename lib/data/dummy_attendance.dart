// data/dummy_attendance.dart
import '../model/attendance.dart';

List<AttendanceModel> dummyAttendances = [
  AttendanceModel(
    id: '1',
    studentId: '1',
    studentName: 'សុខ វណ្ណា',
    facultyId: '1',
    majorId: '1',
    classId: '1',
    yearId: '1',
    date: DateTime.now().subtract(Duration(days: 1)),
    startTime: '08:00',
    endTime: '10:00',
    isPresent: true,
  ),
  AttendanceModel(
    id: '2',
    studentId: '2',
    studentName: 'លី ចន្ទា',
    facultyId: '1',
    majorId: '1',
    classId: '1',
    yearId: '1',
    date: DateTime.now().subtract(Duration(days: 1)),
    startTime: '08:00',
    endTime: '10:00',
    isPresent: false,
  ),
  AttendanceModel(
    id: '3',
    studentId: '3',
    studentName: 'ខេម សុភា',
    facultyId: '2',
    majorId: '2',
    classId: '2',
    yearId: '2',
    date: DateTime.now(),
    startTime: '10:00',
    endTime: '12:00',
    isPresent: true,
  ),
];
