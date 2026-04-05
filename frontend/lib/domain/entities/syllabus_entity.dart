class SyllabusEntity {
  final String id;
  final String facultyId;
  final String majorId;
  final String subjectId;
  final String teacherId;
  final String shiftId;
  final String yearId;
  final String semesterId;
  final String? creditHours;
  final String? scheduleDescription; // e.g., "Mon 08:00 - 10:00"

  SyllabusEntity({
    required this.id,
    required this.facultyId,
    required this.majorId,
    required this.subjectId,
    required this.teacherId,
    required this.shiftId,
    required this.yearId,
    required this.semesterId,
    this.creditHours,
    this.scheduleDescription,
  });
}
