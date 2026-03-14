class Student {
  final int id;
  final String name;
  final String? email;
  final String? gender;
  final String? dob;
  final int? userId;
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
      id: _parseInt(json['id'])!,
      userId: _parseInt(json['user_id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? json['user']?['email']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      faculty: json['faculty']?['name']?.toString() ?? json['faculty']?.toString(),
      major: json['major']?['name']?.toString() ?? json['major']?.toString(),
      year: _parseInt(json['year']),
      shift: json['shift']?.toString(),
      generation: json['generation']?.toString(),
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

// For backward compatibility if needed:
typedef StudentModel = Student;

// ── Paginated wrapper ──────────────────────────────────────────────────
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
    return StudentPaginated(
      data: (json['data'] as List).map((e) => Student.fromJson(e)).toList(),
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
