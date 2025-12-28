class AttendanceModel {
  final String id;
  final String studentId;
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
    required this.facultyId,
    required this.majorId,
    required this.classId,
    required this.yearId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isPresent,
  });
}
