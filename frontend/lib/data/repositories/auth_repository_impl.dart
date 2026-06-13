import 'dart:convert';

import 'package:sbku_app/core/constants/api_endpoints.dart';
import 'package:sbku_app/core/network/api_error_handler.dart';
import 'package:sbku_app/core/result.dart';
import 'package:sbku_app/domain/repositories/auth_repository.dart';
import 'package:sbku_app/model/user_model.dart';
import 'package:sbku_app/service/api_service.dart';

/// Concrete implementation of [AuthRepository] backed by the REST API.
class AuthRepositoryImpl with ApiErrorHandler implements AuthRepository {
  final ApiService _api;

  AuthRepositoryImpl({required ApiService apiService}) : _api = apiService;

  // ── Helpers ──────────────────────────────────────────────────

  /// Parses a standard auth response and saves the token.
  Future<User> _handleAuthResponse(dynamic body) async {
    final data = body as Map<String, dynamic>;

    if (data['success'] != true) {
      throw ServerException(data['message']?.toString() ?? 'Authentication failed');
    }

    if (data.containsKey('token')) {
      await _api.saveToken(data['token']);
    }

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Parses a profile update response.
  User _parseUserResponse(dynamic body) {
    final data = body as Map<String, dynamic>;

    if (data['success'] != true) {
      throw ServerException(data['message']?.toString() ?? 'Operation failed');
    }

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  // ── Auth Operations ──────────────────────────────────────────

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) {
    return guardAsync(() async {
      final response = await _api.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      }, requiresAuth: false);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return _handleAuthResponse(body);
      }

      throw _mapStatusToAppException(response.statusCode, body);
    });
  }

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return guardAsync(() async {
      final response = await _api.post(ApiEndpoints.register, {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }, requiresAuth: false);

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return _handleAuthResponse(body);
      }

      throw _mapStatusToAppException(response.statusCode, body);
    });
  }

  @override
  Future<Result<void>> logout() {
    return guardAsync(() async {
      try {
        await _api.post(ApiEndpoints.logout, {}, requiresAuth: true);
      } catch (_) {
        // Silently catch exceptions to ensure token deletion completes
      } finally {
        await _api.deleteToken();
      }
    });
  }

  @override
  Future<Result<User?>> getCurrentUser() {
    return guardAsync(() async {
      final response = await _api.get(ApiEndpoints.user);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['user'] as Map<String, dynamic>);
        }
      }

      if (response.statusCode == 401) {
        await _api.deleteToken();
      }

      return null;
    });
  }

  // ── Profile Operations ───────────────────────────────────────

  @override
  Future<Result<User>> updateProfile({
    required String name,
    required String email,
  }) {
    return guardAsync(() async {
      final response = await _api.put(ApiEndpoints.profileInfo, {
        'name': name,
        'email': email,
      });

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return _parseUserResponse(body);
      }

      throw _mapStatusToAppException(response.statusCode, body);
    });
  }

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return guardAsync(() async {
      final response = await _api.put(ApiEndpoints.profilePassword, {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final body = jsonDecode(response.body);

      if (response.statusCode != 200 || body['success'] != true) {
        throw _mapStatusToAppException(response.statusCode, body);
      }
    });
  }

  @override
  Future<Result<User>> uploadProfilePhoto(String imagePath) {
    return guardAsync(() async {
      final response = await _api.postMultipart(
        ApiEndpoints.profilePhoto,
        {},
        'photo',
        imagePath,
      );

      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        return User.fromJson(data['user'] as Map<String, dynamic>);
      }

      throw ServerException(data['message']?.toString() ?? 'Upload failed');
    });
  }

  @override
  Future<Result<User>> deleteProfilePhoto() {
    return guardAsync(() async {
      final response = await _api.delete(ApiEndpoints.profilePhoto);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return _parseUserResponse(body);
      }

      throw _mapStatusToAppException(response.statusCode, body);
    });
  }

  // ── Error Mapping ────────────────────────────────────────────

  AppException _mapStatusToAppException(int statusCode, dynamic body) {
    final message = body is Map ? body['message']?.toString() : null;

    return switch (statusCode) {
      401 => UnauthorizedException(message ?? 'Invalid credentials'),
      403 => ForbiddenException(message ?? 'Access denied'),
      422 => ValidationException(
          message: message ?? 'Validation failed',
          errors: _extractErrors(body),
        ),
      >= 500 => ServerException(message ?? 'Server error', statusCode),
      _ => ServerException(message ?? 'Unexpected error', statusCode),
    };
  }

  Map<String, List<String>> _extractErrors(dynamic body) {
    if (body is! Map<String, dynamic>) return {};
    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return {};
    return errors.map((key, value) => MapEntry(
      key,
      value is List ? value.map((e) => e.toString()).toList() : [value.toString()],
    ));
  }
}
