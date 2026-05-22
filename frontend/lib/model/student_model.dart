import 'package:sbku_app/core/constants/app_config.dart';

class Student {
  final String id;
  final String name;
  final String? email;
  final String? gender;
  final String? dob;
  final String? userId;
  final String? faculty;
  final String? major;
  final int? year;
  final String? shift;
  final String? generation;
  final String? avatarUrl;
  final String? createdAt;

  Student({
    required this.id,
    required this.name,
    this.email,
    this.gender,
    this.dob,
    this.userId,
    this.faculty,
    this.major,
    this.year,
    this.shift,
    this.generation,
    this.avatarUrl,
    this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ??
          json['user_name']?.toString() ??
          json['user']?['name']?.toString() ??
          '',
      email: json['email']?.toString() ??
          json['user_email']?.toString() ??
          json['user']?['email']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      faculty: _relationName(json['faculty']) ?? json['faculty_name']?.toString(),
      major: _relationName(json['major']) ?? json['major_name']?.toString(),
      year: _parseInt(json['year']),
      shift: _relationName(json['shift']) ?? json['shift_name']?.toString(),
      generation: json['generation']?.toString(),
      avatarUrl: _resolveAvatar(json),
      createdAt: json['created_at']?.toString(),
    );
  }

  static String? _relationName(dynamic value) {
    if (value == null) return null;
    if (value is Map) return value['name']?.toString();
    if (value is String) return value;
    return null;
  }

  static String? _resolveAvatar(Map<String, dynamic> json) {
    return AppConfig.resolveMediaUrl(
      json['avatar_url']?.toString() ??
          json['profile_image_path']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'gender': gender,
        'dob': dob,
        'user_id': userId,
        'faculty': faculty,
        'major': major,
        'year': year,
        'shift': shift,
        'generation': generation,
        'avatar_url': avatarUrl,
        'created_at': createdAt,
      };
}

typedef StudentModel = Student;

class StudentPaginated {
  final List<Student> data;
  final int currentPage;
  final int lastPage;
  final int total;

  StudentPaginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory StudentPaginated.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final List<Student> students = raw is List
        ? raw
            .map((e) => Student.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : [];

    return StudentPaginated(
      data: students,
      currentPage: _parseInt(json['current_page']) ?? 1,
      lastPage: _parseInt(json['last_page']) ?? 1,
      total: _parseInt(json['total']) ?? students.length,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
