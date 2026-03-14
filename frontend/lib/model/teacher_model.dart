class Teacher {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? gender;
  final int? year;
  final int? userId;
  final String? major;
  final String? faculty;
  final String? schedule;
  final String? shift;
  final String? avatarUrl;
  final String? createdAt;

  Teacher({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.gender,
    this.year,
    this.userId,
    this.major,
    this.faculty,
    this.schedule,
    this.shift,
    this.avatarUrl,
    this.createdAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: _parseInt(json['id'])!,
      userId: _parseInt(json['user_id']),
      year: _parseInt(json['year']),
      name: json['name']?.toString() ?? '',
      email: json['user']?['email']?.toString() ?? json['email']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      major: json['major']?['name']?.toString(),
      faculty: json['faculty']?['name']?.toString(),
      schedule: json['schedule']?['name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      createdAt: json['created_at']?.toString(),
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
        'phone': phone,
        'gender': gender,
        'year': year,
        'user_id': userId,
        'major': major,
        'faculty': faculty,
        'schedule': schedule,
        'shift': shift,
        'avatar_url': avatarUrl,
        'created_at': createdAt,
      };
}

// ── Paginated wrapper ──────────────────────────────────────────────────
class TeacherPaginated {
  final List<Teacher> data;
  final int currentPage;
  final int lastPage;
  final int total;

  TeacherPaginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory TeacherPaginated.fromJson(Map<String, dynamic> json) {
    return TeacherPaginated(
      data: (json['data'] as List).map((e) => Teacher.fromJson(e)).toList(),
      currentPage: _parseInt(json['current_page']) ?? 1,
      lastPage: _parseInt(json['last_page']) ?? 1,
      total: _parseInt(json['total']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
