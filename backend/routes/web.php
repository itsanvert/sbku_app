<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Users\UserIndex;
use App\Livewire\Students\StudentIndex;
use App\Livewire\Teachers\TeacherIndex;
use App\Livewire\Syllabuses\SyllabusIndex;
use App\Livewire\Subjects\SubjectIndex;
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
    Route::get('/syllabus', SyllabusIndex::class)->middleware('role:admin,manage-syllabus')->name('syllabuses.index');
    Route::get('/subjects', SubjectIndex::class)->middleware('role:admin,manage-subjects')->name('subjects.index');
    
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

        // Excel Export route
        Route::get('/export/excel', function() {
            $ids = session('attendance_export_ids');
            if (!$ids || empty($ids)) {
                return redirect()->back()->with('error', 'No records selected for export.');
            }
            $records = \App\Models\Attendance::with([
                'student.user',
                'student.faculty',
                'student.major',
                'session.teacher.user',
                'session.faculty',
                'session.major',
            ])->whereIn('id', $ids)->get();
            
            return (new \App\Exports\AttendanceExport($records))->download();
        })->name('export.excel');
    });

});

