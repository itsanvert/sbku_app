<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\AttendanceSession;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Shift;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;

/**
 * DashboardService
 *
 * Single source of truth for the dashboard statistics, shared by the
 * dashboard view, the PDF report route, and the Excel export route.
 */
class DashboardService
{
    protected FirestoreService $firestore;
    protected bool $isFirestore;

    public function __construct(?FirestoreService $firestore = null)
    {
        $this->firestore = $firestore ?? app(FirestoreService::class);
        $this->isFirestore = FirestoreService::isActive();
    }

    /**
     * All dashboard stats: entity counts, 7-day trend, and status totals.
     */
    public function stats(): array
    {
        if ($this->isFirestore) {
            $teacherCount = Cache::remember('dashboard.teacher_count', 300, fn() => $this->firestore->count('teachers'));
            $studentCount = Cache::remember('dashboard.student_count', 300, fn() => $this->firestore->count('students'));
            $userCount = Cache::remember('dashboard.user_count', 300, fn() => $this->firestore->count('users'));
            $attendanceCount = Cache::remember('dashboard.attendance_count', 300, fn() => $this->firestore->count('attendances'));
            $activeSessions = Cache::remember('dashboard.active_sessions', 300, fn() => $this->firestore->count('attendance_sessions', ['is_active' => true]));
        } else {
            $teacherCount = Cache::remember('dashboard.teacher_count', 300, fn() => Teacher::count());
            $studentCount = Cache::remember('dashboard.student_count', 300, fn() => Student::count());
            $userCount = Cache::remember('dashboard.user_count', 300, fn() => User::count());
            $attendanceCount = Cache::remember('dashboard.attendance_count', 300, fn() => Attendance::count());
            $activeSessions = Cache::remember('dashboard.active_sessions', 300, fn() => AttendanceSession::where('is_active', true)->count());
        }

        $sevenDaysAgo = $this->isFirestore
            ? now()->subDays(7)->format('Y-m-d')
            : now()->subDays(7);

        $statusByDay = Cache::remember('dashboard.attendance_stats', 300, function () use ($sevenDaysAgo) {
            $statusByDay = [];

            if ($this->isFirestore) {
                foreach ($this->firestore->list('attendances', [['attendance_date', '>=', $sevenDaysAgo]]) as $attendance) {
                    $date = $attendance['attendance_date'] ?? null;
                    $status = $attendance['status'] ?? '';
                    if ($date) {
                        $statusByDay[$date][$status] = ($statusByDay[$date][$status] ?? 0) + 1;
                    }
                }

                return $statusByDay;
            }

            $rows = Attendance::where('attendance_date', '>=', $sevenDaysAgo)
                ->selectRaw('attendance_date as date_key, status, COUNT(*) as count')
                ->groupBy('attendance_date', 'status')
                ->get();

            foreach ($rows as $row) {
                $statusByDay[$row->date_key][$row->status] = (int) $row->count;
            }

            return $statusByDay;
        });

        $dailyStats = [];
        $dates = [];
        $counts = [];
        $presentCount = 0;
        $absentCount = 0;
        $permissionCount = 0;

        for ($i = 6; $i >= 0; $i--) {
            $dateObj = now()->subDays($i);
            $dateKey = $dateObj->format('Y-m-d');
            $perDay = $statusByDay[$dateKey] ?? [];

            $present = $perDay['Y'] ?? 0;
            $absent = $perDay['N'] ?? 0;
            $permission = $perDay['P'] ?? 0;

            $dailyStats[] = [
                'date'       => $dateObj->format('d M Y'),
                'label'      => $dateObj->format('M d (D)'),
                'total'      => $present + $absent + $permission,
                'present'    => $present,
                'absent'     => $absent,
                'permission' => $permission,
            ];
            $dates[] = $dateObj->format('M d (D)');
            $counts[] = $present + $absent + $permission;

            $presentCount += $present;
            $absentCount += $absent;
            $permissionCount += $permission;
        }

        return compact(
            'teacherCount',
            'studentCount',
            'userCount',
            'attendanceCount',
            'activeSessions',
            'dates',
            'counts',
            'dailyStats',
            'presentCount',
            'absentCount',
            'permissionCount'
        );
    }

    /**
     * Attendance models for the last 7 days with relations attached,
     * ready for the PDF / Excel report templates. Global (matches the
     * dashboard's all-university numbers).
     */
    public function recentRecords(): Collection
    {
        $sevenDaysAgo = $this->isFirestore
            ? now()->subDays(7)->format('Y-m-d')
            : now()->subDays(7);

        if ($this->isFirestore) {
            return collect($this->firestore->list('attendances', [['attendance_date', '>=', $sevenDaysAgo]]))->map(
                fn(array $data) => $this->mapFirestoreRecord($data)
            );
        }

        return Attendance::with([
            'student.user',
            'student.faculty',
            'student.major',
            'student.shift',
            'session.teacher.user',
            'session.faculty',
            'session.major',
            'session.shift',
        ])->where('attendance_date', '>=', $sevenDaysAgo)
            ->latest('attendance_date')
            ->get();
    }

    /**
     * Rehydrate a Firestore attendance array into an Attendance model with
     * mocked relations, mirroring the pattern used in AttendanceIndex.
     */
    protected function mapFirestoreRecord(array $data): Attendance
    {
        $attendance = new Attendance();
        $attendance->forceFill($data);
        $attendance->exists = true;

        $student = new Student();
        $student->forceFill([
            'id'           => $data['student_id'] ?? null,
            'student_code' => $data['student_code'] ?? null,
            'year'         => $data['student_year'] ?? null,
        ]);

        $studentUser = new User();
        $studentUser->forceFill([
            'id'   => $data['user_id'] ?? null,
            'name' => $data['student_name'] ?? '—',
        ]);
        $student->setRelation('user', $studentUser);

        $faculty = new Faculty();
        $faculty->forceFill(['id' => $data['faculty_id'] ?? null, 'name' => $data['faculty_name'] ?? '—']);
        $student->setRelation('faculty', $faculty);

        $major = new Major();
        $major->forceFill(['id' => $data['major_id'] ?? null, 'name' => $data['major_name'] ?? '—']);
        $student->setRelation('major', $major);

        $shift = new Shift();
        $shift->forceFill(['id' => $data['shift_id'] ?? null, 'name' => $data['shift_name'] ?? '—']);
        $student->setRelation('shift', $shift);

        $attendance->setRelation('student', $student);

        $session = new AttendanceSession();
        $session->forceFill([
            'id' => $data['session_id'] ?? null,
        ]);
        $session->setRelation('faculty', $faculty);
        $session->setRelation('major', $major);
        $session->setRelation('shift', $shift);

        $teacher = new Teacher();
        $teacher->forceFill(['id' => $data['teacher_id'] ?? null]);
        $teacherUser = new User();
        $teacherUser->forceFill([
            'id'   => $data['teacher_user_id'] ?? null,
            'name' => $data['teacher_name'] ?? '—',
        ]);
        $teacher->setRelation('user', $teacherUser);
        $session->setRelation('teacher', $teacher);

        $attendance->setRelation('session', $session);

        return $attendance;
    }
}
