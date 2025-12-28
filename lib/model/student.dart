class StudentModel {
  final String id;
  final String name;
  final String gender;
  final String faculty;
  final String major;
  final String shift;
  final String generation;
  final String year;
  final String email;

  StudentModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.faculty,
    required this.major,
    required this.shift,
    required this.generation,
    required this.year,
    required this.email,
  });

  // 👇 Helper: get first letter for avatar
  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
