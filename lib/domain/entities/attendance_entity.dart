class AttendanceEntity {
  final String id;
  final String studentId;
  final String studentName;
  final String facultyId;
  final String majorId;
  final String shiftId;
  final String classId;
  final String yearId;
  final DateTime date;
  final bool isPresent;
  

  AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.facultyId,
    required this.majorId,
    required this.shiftId,
    required this.classId,
    required this.yearId,
    required this.date,
    required this.isPresent,

  });
}
