// teacher_model.dart
// Matches the backend API response from GET /api/teachers and GET /api/teachers/{id}
// The backend appends computed attributes: name, email, avatar_url via Eloquent accessors.

class Teacher {
  final int id;
  final int? userId;
  final String name;
  final String? email;
  final String? gender;
  final String? phone;
  final int? majorId;
  final int? facultyId;
  final int? scheduleId;
  final int? shiftId;
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
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ??
          json['user']?['email']?.toString(),
      gender: json['gender']?.toString(),
      phone: json['phone']?.toString(),
      majorId: _parseInt(json['major_id']),
      facultyId: _parseInt(json['faculty_id']),
      scheduleId: _parseInt(json['schedule_id']),
      shiftId: _parseInt(json['shift_id']),
      year: json['year']?.toString(),
      role: json['role']?.toString() ?? 'teacher',
      profileImagePath: json['profile_image_path']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      // Relations may be a nested object with a 'name' field
      major: _relationName(json['major']),
      faculty: _relationName(json['faculty']),
      schedule: _relationName(json['schedule']),
      shift: _relationName(json['shift']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
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
