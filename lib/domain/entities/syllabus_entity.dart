class SyllabusEntity {
  final String id;
  final String classId;
  final String teacherId;
  final String subjectId;
  final String shiftId;
  final String semesterId;
  final String yearId;

  SyllabusEntity(
      {required this.id,
      required this.classId,
      required this.teacherId,
      required this.subjectId,
      required this.shiftId,
      required this.semesterId,
      required this.yearId});
}
