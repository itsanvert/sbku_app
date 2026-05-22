import 'package:sbku_app/core/constants/app_config.dart';

// teacher_model.dart
// Matches the backend API response from GET /api/teachers and GET /api/teachers/{id}
// The backend appends computed attributes: name, email, avatar_url via Eloquent accessors.

class Teacher {
  final String id;
  final String? userId;
  final String name;
  final String? email;
  final String? gender;
  final String? phone;
  final String? majorId;
  final String? facultyId;
  final String? scheduleId;
  final String? shiftId;
  final String? year;
  final String role;
  final String? profileImagePath;
  final String? avatarUrl;

  // Resolved relation names (from nested objects)
  final String? major;
  final String? faculty;
  final String? schedule;
  final String? shift;

  final String? createdAt;
  final String? updatedAt;

  Teacher({
    required this.id,
    this.userId,
    required this.name,
    this.email,
    this.gender,
    this.phone,
    this.majorId,
    this.facultyId,
    this.scheduleId,
    this.shiftId,
    this.year,
    this.role = 'teacher',
    this.profileImagePath,
    this.avatarUrl,
    this.major,
    this.faculty,
    this.schedule,
    this.shift,
    this.createdAt,
    this.updatedAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    // Handle both paginated list items and single-record responses
    // Backend appends 'name', 'email', 'avatar_url' as computed attributes
    return Teacher(
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
      phone: json['phone']?.toString(),
      majorId: json['major_id']?.toString(),
      facultyId: json['faculty_id']?.toString(),
      scheduleId: json['schedule_id']?.toString(),
      shiftId: json['shift_id']?.toString(),
      year: json['year']?.toString(),
      role: json['role']?.toString() ?? 'teacher',
      profileImagePath: json['profile_image_path']?.toString(),
      avatarUrl: AppConfig.resolveMediaUrl(
        json['avatar_url']?.toString() ?? json['profile_image_path']?.toString(),
      ),
      major: _relationName(json['major']) ?? json['major_name']?.toString(),
      faculty: _relationName(json['faculty']) ?? json['faculty_name']?.toString(),
      schedule: _relationName(json['schedule']) ?? json['schedule_name']?.toString(),
      shift: _relationName(json['shift']) ?? json['shift_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Extracts a 'name' field from a nested relation object, or returns the
  /// raw string if the value is already a plain string.
  static String? _relationName(dynamic value) {
    if (value == null) return null;
    if (value is Map) return value['name']?.toString();
    if (value is String) return value;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'email': email,
        'gender': gender,
        'phone': phone,
        'major_id': majorId,
        'faculty_id': facultyId,
        'schedule_id': scheduleId,
        'shift_id': shiftId,
        'year': year,
        'role': role,
        'profile_image_path': profileImagePath,
        'avatar_url': avatarUrl,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

// ── Paginated wrapper ──────────────────────────────────────────────────────

class TeacherPaginated {
  final List<Teacher> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  TeacherPaginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.perPage = 15,
  });

  factory TeacherPaginated.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<Teacher> teachers = rawData is List
        ? rawData.map((e) => Teacher.fromJson(e as Map<String, dynamic>)).toList()
        : [];

    return TeacherPaginated(
      data: teachers,
      currentPage: _parseInt(json['current_page']) ?? 1,
      lastPage: _parseInt(json['last_page']) ?? 1,
      total: _parseInt(json['total']) ?? 0,
      perPage: _parseInt(json['per_page']) ?? 15,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

// Backward-compat alias so any code using TeacherModel still compiles
typedef TeacherModel = Teacher;
