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
use App\Livewire\Schedules\ScheduleIndex;
use App\Livewire\Shifts\ShiftIndex;
use App\Livewire\Admin\MessageCenter;

Route::get('/', function () {
    return view('auth.login');
});

// Explicitly block registration routes
Route::any('/register', function () {
    abort(404);
})->name('register');

Route::middleware([
    'auth:sanctum',
    config('jetstream.auth_session'),
    'verified',
])->group(function () {
    Route::get('/dashboard', function (\App\Services\FirestoreService $firestore) {
        $teacherCount = $firestore->count('teachers');
        $studentCount = $firestore->count('students');
        $userCount = $firestore->count('users');
        $attendanceCount = $firestore->count('attendances');
        $activeSessions = $firestore->count('attendance_sessions', ['is_active' => true]);

        // 1. Daily Attendance Data (Last 7 days)
        // Note: For a high-performance production dashboard, you'd typically 
        // pre-calculate these or use a summary document in Firestore.
        $sevenDaysAgo = now()->subDays(7)->format('Y-m-d');
        $recentAttendances = $firestore->list('attendances', [
            ['attendance_date', '>=', $sevenDaysAgo]
        ]);
        
        $dates = [];
        $counts = [];
        
        // Group by date in PHP since Firestore doesn't have native SQL group-by
        $dailyData = [];
        foreach ($recentAttendances as $attendance) {
            $date = $attendance['attendance_date'] ?? null;
            if ($date) {
                $dailyData[$date] = ($dailyData[$date] ?? 0) + 1;
            }
        }

        for ($i = 6; $i >= 0; $i--) {
            $dateObj = now()->subDays($i);
            $dateKey = $dateObj->format('Y-m-d');
            $dates[] = $dateObj->format('M d (D)'); 
            $counts[] = $dailyData[$dateKey] ?? 0;
        }

        // 2. Attendance Status Distribution
        $presentCount = 0;
        $absentCount = 0;
        $permissionCount = 0;

        foreach ($recentAttendances as $attendance) {
            $status = $attendance['status'] ?? '';
            if ($status === 'Y') $presentCount++;
            elseif ($status === 'N') $absentCount++;
            elseif ($status === 'P') $permissionCount++;
        }

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
    Route::get('/schedules', ScheduleIndex::class)->middleware('role:admin')->name('schedules.index');
    Route::get('/shifts', ShiftIndex::class)->middleware('role:admin')->name('shifts.index');
    Route::get('/messages', MessageCenter::class)->name('messages');
    
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

    // Temporary migration route for messages (Remove after use)
    Route::get('/admin/migrate-messages', function () {
        if (auth()->user()?->role !== 'admin') abort(403);
        
        \Illuminate\Support\Facades\Artisan::call('firestore:migrate', ['--model' => 'Message']);
        return "Migration completed: <br>" . nl2br(\Illuminate\Support\Facades\Artisan::output());
    });
});

