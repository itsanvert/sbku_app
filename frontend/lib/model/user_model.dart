import 'package:sbku_app/core/constants/app_config.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? profilePhotoUrl;
  final String? profilePhotoPath;
  final bool twoFactorEnabled;
  final String? createdAt;
  final String? updatedAt;
  final String? role;
  final String? studentId;
  final String? teacherId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.profilePhotoUrl,
    this.profilePhotoPath,
    this.twoFactorEnabled = false,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.studentId,
    this.teacherId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Try multiple possible keys for the profile image URL
    final String? rawPhotoUrl = json['profile_photo_url']?.toString() ?? 
                               json['avatar_url']?.toString() ?? 
                               json['profile_image_url']?.toString();
    final String? rawPhotoPath = json['profile_photo_path']?.toString();

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      profilePhotoUrl: AppConfig.resolveMediaUrl(rawPhotoUrl),
      profilePhotoPath: rawPhotoPath,
      twoFactorEnabled: json['two_factor_enabled'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      role: json['role'] ?? json['role_id']?.toString(),
      studentId: json['student_id']?.toString(),
      teacherId: json['teacher_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'profile_photo_path': profilePhotoPath,
      'profile_photo_url': profilePhotoUrl,
      'two_factor_enabled': twoFactorEnabled,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role,
      'student_id': studentId,
      'teacher_id': teacherId,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    String? profilePhotoUrl,
    String? profilePhotoPath,
    bool? twoFactorEnabled,
    String? createdAt,
    String? updatedAt,
    String? role,
    String? studentId,
    String? teacherId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
