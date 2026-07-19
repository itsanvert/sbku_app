import 'package:flutter/material.dart';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/core/result.dart';
import 'package:sbku_app/domain/repositories/auth_repository.dart';
import 'package:sbku_app/model/user_model.dart';
import 'package:sbku_app/service/firebase_messaging_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = sl<AuthRepository>();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    _isLoading = false;

    switch (result) {
      case Success<User>():
        _user = result.data;
        notifyListeners();
        return true;
      case Failure<User>():
        _errorMessage = _formatError(result.error);
        notifyListeners();
        return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    switch (result) {
      case Success<User>():
        _user = result.data;
        notifyListeners();
        // Register FCM token with backend after successful login
        try {
          await FirebaseMessagingService().registerToken();
        } catch (e) {
          print('FCM token registration after login failed: $e');
        }
        return true;
      case Failure<User>():
        _errorMessage = _formatError(result.error);
        notifyListeners();
        return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Check authentication status
  Future<void> checkAuth() async {
    final result = await _authRepository.getCurrentUser();
    switch (result) {
      case Success<User?>():
        _user = result.data;
      case Failure<User?>():
        _user = null;
    }
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.updateProfile(
      name: name,
      email: email,
    );

    _isLoading = false;

    switch (result) {
      case Success<User>():
        _user = result.data;
        notifyListeners();
        return true;
      case Failure<User>():
        _errorMessage = _formatError(result.error);
        notifyListeners();
        return false;
    }
  }

  // Update password
  Future<bool> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.updatePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    _isLoading = false;

    switch (result) {
      case Success<void>():
        notifyListeners();
        return true;
      case Failure<void>():
        _errorMessage = _formatError(result.error);
        notifyListeners();
        return false;
    }
  }

  // Upload profile photo
  Future<bool> uploadProfilePhoto(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.uploadProfilePhoto(imagePath);

    _isLoading = false;

    switch (result) {
      case Success<User>():
        _user = result.data;
        notifyListeners();
        return true;
      case Failure<User>():
        _errorMessage = _formatError(result.error);
        notifyListeners();
        return false;
    }
  }

  // Delete profile photo
  Future<bool> deleteProfilePhoto() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.deleteProfilePhoto();

    _isLoading = false;

    switch (result) {
      case Success<User>():
        _user = result.data;
        notifyListeners();
        return true;
      case Failure<User>():
        _errorMessage = _formatError(result.error);
        notifyListeners();
        return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _formatError(AppException error) {
    if (error is ValidationException && error.errors.isNotEmpty) {
      return error.flatErrors;
    }
    return error.message;
  }
}
