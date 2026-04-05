class SyllabusModel {
  final String id;
  final String facultyName;
  final String majorName;
  final String yearName;
  final String semesterName;
  final String subjectName;
  final String teacherName;
  final String shiftName;
  final String creditHours;
  final String scheduleInfo;

  SyllabusModel({
    required this.id,
    required this.facultyName,
    required this.majorName,
    required this.yearName,
    required this.semesterName,
    required this.subjectName,
    required this.teacherName,
    required this.shiftName,
    this.creditHours = '3',
    this.scheduleInfo = 'TBD',
  });
}
