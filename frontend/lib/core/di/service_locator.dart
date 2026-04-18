import 'package:get_it/get_it.dart';

import 'package:sbku_app/data/repositories/attendance_repository_impl.dart';
import 'package:sbku_app/data/repositories/auth_repository_impl.dart';
import 'package:sbku_app/data/repositories/student_repository_impl.dart';
import 'package:sbku_app/domain/repositories/attendance_repository.dart';
import 'package:sbku_app/domain/repositories/auth_repository.dart';
import 'package:sbku_app/domain/repositories/student_repository.dart';
import 'package:sbku_app/service/api_service.dart';

/// Global service locator instance.
///
/// Access registered dependencies anywhere with `sl<Type>()`.
/// Example: `final repo = sl<StudentRepository>();`
final GetIt sl = GetIt.instance;

/// Registers all dependencies. Call once in `main()` before `runApp()`.
///
/// Registration order matters — register leaf dependencies first,
/// then higher-level ones that depend on them.
void setupServiceLocator() {
  // ── Core / Network ─────────────────────────────────────────
  sl.registerLazySingleton<ApiService>(() => ApiService());

  // ── Repositories ───────────────────────────────────────────
  // Registered as interfaces so consumers never see the implementation.

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(apiService: sl<ApiService>()),
  );

  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(apiService: sl<ApiService>()),
  );

  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(apiService: sl<ApiService>()),
  );
}
