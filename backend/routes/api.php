<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\TeacherController;
use App\Http\Controllers\Api\StudentController;


/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/
// Public routes
Route::post('/register', [AuthController::class, 'register']);
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
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::put('/user/profile-information', [ProfileController::class, 'updateProfile']);
    Route::put('/user/password', [ProfileController::class, 'updatePassword']);
    Route::post('/user/profile-photo', [ProfileController::class, 'updateProfilePhoto']);
    Route::delete('/user/profile-photo', [ProfileController::class, 'deleteProfilePhoto']);

    // ← add ->names() to prefix API route names differently
    Route::apiResource('teachers', TeacherController::class)
        ->names([
            'index'   => 'api.teachers.index',
            'store'   => 'api.teachers.store',
            'show'    => 'api.teachers.show',
            'update'  => 'api.teachers.update',
            'destroy' => 'api.teachers.destroy',
        ]);

    Route::apiResource('students', StudentController::class)
        ->names([
            'index'   => 'api.students.index',
            'store'   => 'api.students.store',
            'show'    => 'api.students.show',
            'update'  => 'api.students.update',
            'destroy' => 'api.students.destroy',    
        ]);    
});
