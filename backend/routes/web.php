<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Users\UserIndex;
use App\Livewire\Students\StudentIndex;
use App\Livewire\Teachers\TeacherIndex;
Route::get('/', function () {
    return view('auth.login');
});

Route::middleware([
    'auth:sanctum',
    config('jetstream.auth_session'),
    'verified',
])->group(function () {
    Route::get('/dashboard', function () {
        $teacherCount = \App\Models\Teacher::count();
        $studentCount = \App\Models\Student::count();
        $userCount = \App\Models\User::count();
        $attendanceCount = \App\Models\Attendance::count();
        $activeSessions = \App\Models\AttendanceSession::where('is_active', true)->count();

        return view('dashboard', compact(
            'teacherCount', 
            'studentCount', 
            'userCount', 
            'attendanceCount',
            'activeSessions'
        ));
    })->name('dashboard');
});

Route::get('/flux-test', function () {
    return view('flux-test');
});
Route::middleware(['auth', 'verified'])->group(function () {

    Route::get('/teachers', TeacherIndex::class)->name('teachers.index'); // ← same path = conflict
    Route::get('/students', StudentIndex::class)->name('students.index');
    Route::get('/users', UserIndex::class)->name('users.index');
    
    // Attendance routes
    Route::get('/attendance/sessions', \App\Livewire\Attendance\AttendanceSessionIndex::class)->name('attendance.sessions.index');
    Route::get('/attendance/records', \App\Livewire\Attendance\AttendanceIndex::class)->name('attendance.records.index');
    Route::get('/attendance/create-session', \App\Livewire\Attendance\AttendanceCreate::class)->name('attendance.sessions.create');

});

