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

    // Admin only management
    Route::get('/users', UserIndex::class)->middleware('role:admin,manage-users')->name('users.index');
    Route::get('/teachers', TeacherIndex::class)->middleware('role:admin,manage-teachers')->name('teachers.index');
    Route::get('/students', StudentIndex::class)->middleware('role:admin,manage-students')->name('students.index');
    
    // Attendance routes
    Route::prefix('attendance')->name('attendance.')->group(function() {
        // Teachers and Admins can manage sessions
        Route::get('/sessions', \App\Livewire\Attendance\AttendanceSessionIndex::class)
            ->middleware('role:admin,teacher,view-sessions')
            ->name('sessions.index');
            
        Route::get('/create-session', \App\Livewire\Attendance\AttendanceCreate::class)
            ->middleware('role:admin,teacher,create-sessions')
            ->name('sessions.create');

        // All roles can view records (filtered internally by the component)
        Route::get('/records', \App\Livewire\Attendance\AttendanceIndex::class)
            ->middleware('role:admin,teacher,student,view-attendance')
            ->name('records.index');
    });

});

