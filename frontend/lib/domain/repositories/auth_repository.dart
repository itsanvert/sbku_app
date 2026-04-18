import 'package:sbku_app/core/result.dart';
import 'package:sbku_app/model/user_model.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Attempts login. Returns the authenticated [User] on success.
  Future<Result<User>> login({
    required String email,
    required String password,
  });

  /// Registers a new user. Returns the created [User] on success.
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Logs out the current user.
  Future<Result<void>> logout();

  /// Gets the currently authenticated user, or `null` if unauthenticated.
  Future<Result<User?>> getCurrentUser();

  /// Updates the user's profile information.
  Future<Result<User>> updateProfile({
    required String name,
    required String email,
  });

  /// Updates the user's password.
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  /// Uploads a new profile photo.
  Future<Result<User>> uploadProfilePhoto(String imagePath);

  /// Deletes the current profile photo.
  Future<Result<User>> deleteProfilePhoto();
}
