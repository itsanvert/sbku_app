
class SyllabusModel {
  final String id;
  final String className;
  final String teacherName;
  final String subjectName;
  final String shiftName;
  final String semesterName;
  final String yearName;

  SyllabusModel({
    required this.id,
    required this.className,
    required this.teacherName,
    required this.subjectName,
    required this.shiftName,
    required this.semesterName,
    required this.yearName,
  });

  /// ❌ REMOVE THIS (unsafe without ID lookup)
  /// SyllabusEntity toEntity() { ... }

  /// ❌ REMOVE THIS (entity has IDs, model has names)
  /// factory SyllabusModel.fromEntity(...)
}
