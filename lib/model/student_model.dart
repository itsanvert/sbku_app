// model/student_model.dart
class StudentModel {
  final String id;
  final String name;
  final String gender;
  final String dob;
  final String faculty;
  final String major;
  final String year;
  final String shift;
  final String generation;
  final String email;
  final String? profileImagePath; // Added for image storage

  StudentModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.faculty,
    required this.major,
    required this.year,
    required this.shift,
    required this.generation,
    required this.email,
    this.profileImagePath,
  });

  // Copy with method for easy updates
  StudentModel copyWith({
    String? id,
    String? name,
    String? gender,
    String? dob,
    String? faculty,
    String? major,
    String? year,
    String? shift,
    String? generation,
    String? email,
    String? profileImagePath,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      year: year ?? this.year,
      shift: shift ?? this.shift,
      generation: generation ?? this.generation,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'faculty': faculty,
      'major': major,
      'year': year,
      'shift': shift,
      'generation': generation,
      'email': email,
      'profileImagePath': profileImagePath,
    };
  }

  // From JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      dob: json['dob'] as String,
      faculty: json['faculty'] as String,
      major: json['major'] as String,
      year: json['year'] as String,
      shift: json['shift'] as String,
      generation: json['generation'] as String,
      email: json['email'] as String,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  @override
  String toString() {
    return 'StudentModel(id: $id, name: $name, gender: $gender, dob: $dob, '
        'faculty: $faculty, major: $major, year: $year, shift: $shift, '
        'generation: $generation, email: $email, profileImagePath: $profileImagePath)';
  }
}
