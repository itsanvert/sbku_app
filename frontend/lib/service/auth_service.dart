import 'dart:convert';

import 'package:sbku_app/core/network/api_response_parser.dart';
import 'package:sbku_app/model/user_model.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.post('register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final data = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));

      if (response.statusCode == 201 && data['success'] == true) {
        await _apiService.saveToken(data['token'] as String);
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
        };
      }

      return {
        'success': false,
        'message': ApiResponseParser.errorMessage(response, body: data),
        'errors': data['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('login', {
        'email': email,
        'password': password,
      });

      final data = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));

      if (response.statusCode == 200 &&
          data['success'] == true &&
          data['token'] != null &&
          data['user'] != null) {
        await _apiService.saveToken(data['token'] as String);
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
        };
      }

      return {
        'success': false,
        'message': ApiResponseParser.errorMessage(response, body: data),
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response from server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<bool> logout() async {
    try {
      await _apiService.post('logout', {}, requiresAuth: true);
    } catch (_) {
      // Always clear local session.
    }
    await _apiService.deleteToken();
    return true;
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return null;

      final response = await _apiService.get('user');

      if (response.statusCode == 200) {
        final data = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));
        if (data['success'] == true && data['user'] != null) {
          return User.fromJson(data['user'] as Map<String, dynamic>);
        }
      }

      if (response.statusCode == 401) {
        await _apiService.deleteToken();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _apiService.put(
        'user/profile-information',
        {'name': name, 'email': email},
      );

      final data = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': ApiResponseParser.errorMessage(response, body: data),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.put(
        'user/password',
        {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }

      return {
        'success': false,
        'message': ApiResponseParser.errorMessage(response, body: data),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(String imagePath) async {
    try {
      final response = await _apiService.postMultipart(
        'user/profile-photo',
        {},
        'photo',
        imagePath,
      );

      final responseData = await response.stream.bytesToString();
      final data = ApiResponseParser.asMap(jsonDecode(responseData));

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message']?.toString() ?? 'Upload failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteProfilePhoto() async {
    try {
      final response = await _apiService.delete('user/profile-photo');
      final data = ApiResponseParser.asMap(ApiResponseParser.decodeBody(response));

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user'] as Map<String, dynamic>),
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': ApiResponseParser.errorMessage(response, body: data),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _apiService.post('user/fcm-token', {'token': token}, requiresAuth: true);
    } catch (_) {
      // Non-fatal.
    }
  }
}
