<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\TeacherController;
use App\Http\Controllers\Api\StudentController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AttendanceSessionController;
use App\Http\Controllers\Api\SyllabusController;
use App\Http\Controllers\Api\FacultyController;
use App\Http\Controllers\Api\MajorController;
use App\Http\Controllers\Api\SubjectController;
use App\Http\Controllers\Api\AcademicClassController;


/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/
// Public routes

Route::post('/login', [AuthController::class, 'login']);

// Public storage route for CORS support on Flutter Web
Route::get('/storage/{path}', function ($path) {
    $path = storage_path('app/public/' . $path);
    if (!file_exists($path)) abort(404);

    return response()->file($path, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET',
        'Access-Control-Allow-Headers' => 'Content-Type, Authorization',
    ]);
})->where('path', '.*');

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::put('/user/profile-information', [ProfileController::class, 'updateProfile']);
    Route::put('/user/password', [ProfileController::class, 'updatePassword']);
    Route::post('/user/profile-photo', [ProfileController::class, 'updateProfilePhoto']);
    Route::delete('/user/profile-photo', [ProfileController::class, 'deleteProfilePhoto']);
    Route::post('/user/fcm-token', [ProfileController::class, 'updateFcmToken']);

    // Teachers
    Route::apiResource('teachers', TeacherController::class)
        ->names([
            'index'   => 'api.teachers.index',
            'store'   => 'api.teachers.store',
            'show'    => 'api.teachers.show',
            'update'  => 'api.teachers.update',
            'destroy' => 'api.teachers.destroy',
        ]);

    // Students
    Route::apiResource('students', StudentController::class)
        ->names([
            'index'   => 'api.students.index',
            'store'   => 'api.students.store',
            'show'    => 'api.students.show',
            'update'  => 'api.students.update',
            'destroy' => 'api.students.destroy',
        ]);

    // Attendance reports (must be before apiResource to avoid route conflicts)
    Route::get('attendances/report/daily', [AttendanceController::class, 'dailyReport']);
    Route::get('attendances/report/monthly', [AttendanceController::class, 'monthlyReport']);
    Route::get('attendances/report/yearly', [AttendanceController::class, 'yearlyReport']);
    Route::get('attendances/export/pdf', [AttendanceController::class, 'exportPdf']);
    Route::get('attendances/export/excel', [AttendanceController::class, 'exportExcel']);
    Route::get('attendances/student/{studentId}', [AttendanceController::class, 'studentHistory']);
    Route::post('attendances/request-permission', [AttendanceController::class, 'requestPermission']);

    // Attendance CRUD
    Route::apiResource('attendances', AttendanceController::class)
        ->only(['index', 'show'])
        ->names([
            'index' => 'api.attendances.index',
            'show'  => 'api.attendances.show',
        ]);

    // Attendance Sessions
    Route::post('attendance-sessions', [AttendanceSessionController::class, 'store']);
    Route::get('attendance-sessions/active', [AttendanceSessionController::class, 'active']);
    Route::get('attendance-sessions/{id}', [AttendanceSessionController::class, 'show']);
    Route::post('attendance-sessions/{id}/check-in', [AttendanceSessionController::class, 'checkIn']);
    Route::post('attendance-sessions/{id}/end', [AttendanceSessionController::class, 'end']);

    // Anti-cheating: teacher approval checklist
    Route::get('attendance-sessions/{id}/approvals', [AttendanceSessionController::class, 'approvalList']);
    Route::post('attendance-sessions/{sessionId}/verify/{attendanceId}', [AttendanceSessionController::class, 'verifyAttendance']);

    // Syllabus
    Route::get('syllabus', [SyllabusController::class, 'index']);

    // Faculty, Major, Subject, Class
    Route::apiResource('faculties', FacultyController::class);
    Route::apiResource('majors', MajorController::class);
    Route::apiResource('subjects', SubjectController::class);
    Route::apiResource('classes', AcademicClassController::class);
});
