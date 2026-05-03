<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Users\UserIndex;
use App\Livewire\Students\StudentIndex;
use App\Livewire\Teachers\TeacherIndex;
use App\Livewire\Syllabuses\SyllabusIndex;
use App\Livewire\Subjects\SubjectIndex;
use App\Livewire\Faculties\FacultyIndex;
use App\Livewire\Majors\MajorIndex;
use App\Livewire\Classes\ClassIndex;
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

        // 1. Daily Attendance Data (Last 7 days)
        $dailyData = \App\Models\Attendance::selectRaw('DATE(created_at) as date, count(*) as count')
            ->where('created_at', '>=', now()->subDays(6)->startOfDay())
            ->groupBy('date')
            ->get()
            ->pluck('count', 'date');
        
        $dates = [];
        $counts = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i)->format('Y-m-d');
            $dates[] = now()->subDays($i)->format('M d (D)'); 
            $counts[] = $dailyData[$date] ?? 0;
        }

        // 2. Attendance Status Distribution
        $statusCounts = \App\Models\Attendance::selectRaw('status, count(*) as count')
            ->groupBy('status')
            ->get()
            ->pluck('count', 'status');
        
        $presentCount = $statusCounts['Y'] ?? 0;
        $absentCount = $statusCounts['N'] ?? 0;
        $permissionCount = $statusCounts['P'] ?? 0;

        return view('dashboard', compact(
            'teacherCount', 
            'studentCount', 
            'userCount', 
            'attendanceCount',
            'activeSessions',
            'dates',
            'counts',
            'presentCount',
            'absentCount',
            'permissionCount'
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
    Route::get('/faculties', FacultyIndex::class)->middleware('role:admin')->name('faculties.index');
    Route::get('/majors', MajorIndex::class)->middleware('role:admin')->name('majors.index');
    Route::get('/classes', ClassIndex::class)->middleware('role:admin')->name('classes.index');
    
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
            $filterInfo = session('attendance_export_filter', 'All records');
            
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
            
            return (new \App\Exports\AttendanceExport(
                $records, 
                auth()->user()?->name ?? 'System',
                $filterInfo
            ))->download();
        })->name('export.excel');
    });

});

