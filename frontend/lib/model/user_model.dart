import 'package:sbku_app/service/api_service.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? profilePhotoUrl;
  final bool twoFactorEnabled;
  final String? createdAt;
  final String? updatedAt;
  final String? role;
  final int? studentId;
  final int? teacherId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.profilePhotoUrl,
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

    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      profilePhotoUrl: _fixPhotoUrl(rawPhotoUrl),
      twoFactorEnabled: json['two_factor_enabled'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      role: json['role'] ?? json['role_id']?.toString(),
      studentId: json['student_id'],
      teacherId: json['teacher_id'],
    );
  }

  /// Rewrites localhost / 127.0.0.1 URLs to the real backend host so that
  /// profile photos load correctly on physical devices.
  static String? _fixPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // If it's already a full URL from a CDN (like ui-avatars or google), leave it be
    if (url.contains('ui-avatars.com') || url.contains('googleusercontent.com')) {
      return url;
    }

    // Extract the origin (scheme + host + port) from the configured API base URL
    final apiBase = ApiService.baseUrl; 
    final uri = Uri.tryParse(apiBase);
    if (uri == null) return url;
    
    final backendOrigin = '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';

    // Replace any loopback variant with the real backend origin
    final loopbackRegex = RegExp(r'https?://(localhost|127\.0\.0\.1)(:\d+)?');
    if (url.contains(loopbackRegex)) {
      return url.replaceFirst(loopbackRegex, backendOrigin);
    }
    
    // If it's a relative path, prepend the base origin
    if (!url.startsWith('http')) {
      // Ensure we don't have double slashes
      final cleanPath = url.startsWith('/') ? url.substring(1) : url;
      // If it doesn't contain 'storage', it might be a direct path
      return '$backendOrigin/$cleanPath';
    }

    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
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
    int? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    String? profilePhotoUrl,
    bool? twoFactorEnabled,
    String? createdAt,
    String? updatedAt,
    String? role,
    int? studentId,
    int? teacherId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
