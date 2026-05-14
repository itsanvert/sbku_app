<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Student;
use App\Services\FirestoreService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AttendanceController extends Controller
{
    public function __construct(
        private readonly FirestoreService $firestore,
    ) {}
    /**
     * List attendances with filters.
     */
    public function index(Request $request)
    {
        $filters = [];

        if ($request->student_id) {
            $filters['student_id'] = (int) $request->student_id;
        }

        if ($request->date) {
            $filters['attendance_date'] = $request->date;
        }

        if ($request->status) {
            $filters['status'] = $request->status;
        }

        $attendances = $this->firestore->list(
            'attendances', 
            $filters, 
            $request->sort_by ?? 'attendance_date', 
            $request->sort_dir ?? 'desc'
        );

        return response()->json([
            'data' => $attendances,
            'total' => count($attendances),
        ]);
    }

    /**
     * Show a single attendance record.
     */
    public function show(Attendance $attendance)
    {
        return response()->json(
            $attendance->load(['student.user', 'schedule', 'session'])
        );
    }

    /**
     * Daily report: all attendance records for a specific date.
     */
    public function dailyReport(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
        ]);

        $date = $request->date;

        $attendances = Attendance::with(['student.user', 'schedule'])
            ->forDate($date)
            ->orderBy('student_id')
            ->get();

        $totalStudents = $attendances->count();
        $presentCount = $attendances->where('status', 'Y')->count();
        $absentCount = $attendances->where('status', 'N')->count();

        return response()->json([
            'date' => $date,
            'summary' => [
                'total' => $totalStudents,
                'present' => $presentCount,
                'absent' => $absentCount,
                'present_percentage' => $totalStudents > 0
                    ? round(($presentCount / $totalStudents) * 100, 1)
                    : 0,
            ],
            'records' => $attendances,
        ]);
    }

    /**
     * Monthly report: attendance summary per student for a month.
     */
    public function monthlyReport(Request $request)
    {
        $request->validate([
            'month' => 'required|integer|between:1,12',
            'year' => 'required|integer|min:2020',
        ]);

        $month = $request->month;
        $year = $request->year;

        $students = DB::table('attendances')
            ->join('students', 'attendances.student_id', '=', 'students.id')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->whereMonth('attendance_date', $month)
            ->whereYear('attendance_date', $year)
            ->select(
                'students.id as student_id',
                'users.name as student_name',
                'students.profile_image_path',
                DB::raw("COUNT(*) as total_days"),
                DB::raw("SUM(CASE WHEN status = 'Y' THEN 1 ELSE 0 END) as present_days"),
                DB::raw("SUM(CASE WHEN status = 'N' THEN 1 ELSE 0 END) as absent_days"),
                DB::raw("ROUND(SUM(CASE WHEN status = 'Y' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as attendance_rate")
            )
            ->groupBy('students.id', 'users.name')
            ->orderBy('users.name')
            ->get();

        return response()->json([
            'month' => $month,
            'year' => $year,
            'students' => $students,
        ]);
    }

    /**
     * Yearly report: attendance summary per student for a year.
     */
    public function yearlyReport(Request $request)
    {
        $request->validate([
            'year' => 'required|integer|min:2020',
        ]);

        $year = $request->year;

        $students = DB::table('attendances')
            ->join('students', 'attendances.student_id', '=', 'students.id')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->whereYear('attendance_date', $year)
            ->select(
                'students.id as student_id',
                'users.name as student_name',
                'students.profile_image_path',
                DB::raw("COUNT(*) as total_days"),
                DB::raw("SUM(CASE WHEN status = 'Y' THEN 1 ELSE 0 END) as present_days"),
                DB::raw("SUM(CASE WHEN status = 'N' THEN 1 ELSE 0 END) as absent_days"),
                DB::raw("ROUND(SUM(CASE WHEN status = 'Y' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as attendance_rate")
            )
            ->groupBy('students.id', 'users.name')
            ->orderBy('users.name')
            ->get();

        // Monthly breakdown
        $monthlyBreakdown = DB::table('attendances')
            ->whereYear('attendance_date', $year)
            ->select(
                DB::raw("MONTH(attendance_date) as month"),
                DB::raw("COUNT(*) as total"),
                DB::raw("SUM(CASE WHEN status = 'Y' THEN 1 ELSE 0 END) as present"),
                DB::raw("SUM(CASE WHEN status = 'N' THEN 1 ELSE 0 END) as absent")
            )
            ->groupBy(DB::raw("MONTH(attendance_date)"))
            ->orderBy('month')
            ->get();

        return response()->json([
            'year' => $year,
            'students' => $students,
            'monthly_breakdown' => $monthlyBreakdown,
        ]);
    }

    /**
     * Student's own attendance history.
     */
    public function studentHistory(Request $request, $id)
    {
        // Resolve student model. Check if $id is student.id or student.user_id
        $student = Student::where('id', $id)
            ->orWhere('user_id', $id)
            ->firstOrFail();

        $studentId = $student->id;

        $query = Attendance::with(['schedule', 'session.teacher.user'])
            ->forStudent($studentId);

        if ($request->month && $request->year) {
            $query->forMonth($request->month, $request->year);
        } elseif ($request->year) {
            $query->forYear($request->year);
        }

        $attendances = $query
            ->orderBy('attendance_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 30);

        // Summary stats - global or filtered
        $totalQuery = Attendance::forStudent($studentId);
        if ($request->month && $request->year) {
            $totalQuery->forMonth($request->month, $request->year);
        } elseif ($request->year) {
            $totalQuery->forYear($request->year);
        }

        $total = $totalQuery->count();
        $present = (clone $totalQuery)->present()->count();

        // Anti-cheating status summary
        $pending = (clone $totalQuery)->pending()->count();
        $approved = (clone $totalQuery)->approved()->count();
        $rejected = (clone $totalQuery)->rejected()->count();

        return response()->json([
            'summary' => [
                'total' => $total,
                'present' => $present,
                'absent' => $total - $present,
                'pending' => $pending,
                'approved' => $approved,
                'rejected' => $rejected,
                'attendance_rate' => $total > 0 ? round(($present / $total) * 100, 1) : 0,
            ],
            'attendances' => $attendances,
        ]);
    }
    /**
     * Student request permission for a date.
     */
    public function requestPermission(Request $request)
    {
        $request->validate([
            'student_id' => 'required|exists:students,id',
            'attendance_date' => 'required|date',
            'reason' => 'required|string',
            'image' => 'nullable|image|max:2048', // 2MB max
            'schedule_id' => 'nullable|exists:schedules,id',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('permissions', 'public');
        }

        // We use updateOrCreate because there might already be an "Absent" record if the session was ended.
        // Or if the student is pre-emptively asking for permission.
        $attendance = Attendance::updateOrCreate(
            [
                'student_id' => $request->student_id,
                'attendance_date' => $request->attendance_date,
                'schedule_id' => $request->schedule_id,
            ],
            [
                'status' => 'P', // Permission
                'verify_status' => 'pending',
                'permission_reason' => $request->reason,
                'permission_image' => $imagePath,
            ]
        );

        return response()->json([
            'message' => 'Permission request submitted successfully',
            'attendance' => $attendance->load(['student.user', 'schedule']),
        ], 201);
    }
    /**
     * Export attendance to PDF.
     */
    public function exportPdf(Request $request)
    {
        $query = Attendance::with([
            'student.user',
            'student.faculty',
            'student.major',
            'student.shift',
            'schedule',
            'session.teacher.user',
            'session.faculty',
            'session.major',
        ]);

        if ($request->studentId || $request->student_id) {
            $query->forStudent($request->studentId ?? $request->student_id);
        }
        if ($request->date)
            $query->forDate($request->date);
        if ($request->month && $request->year)
            $query->forMonth($request->month, $request->year);
        elseif ($request->year)
            $query->forYear($request->year);
        if ($request->status)
            $query->where('status', $request->status);

        $records = $query->orderBy('attendance_date', 'desc')->get();

        // Build a human-readable filter summary for the report header
        $filterParts = [];
        if ($request->date)
            $filterParts[] = 'Date: ' . $request->date;
        if ($request->month)
            $filterParts[] = 'Month: ' . $request->month;
        if ($request->year)
            $filterParts[] = 'Year: ' . $request->year;
        if ($request->status)
            $filterParts[] = 'Status: ' . $request->status;
        $filterInfo = $filterParts ? implode(' | ', $filterParts) : 'All records';

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('exports.attendance-pdf', [
            'records' => $records,
            'title' => 'Attendance Report',
            'reportedBy' => auth()->user()?->name ?? 'System',
            'filterInfo' => $filterInfo,
        ])->setPaper('a4', 'landscape');

        return $pdf->download('attendance-report-' . now()->format('Y-m-d') . '.pdf');
    }

    /**
     * Export attendance to Excel (XLSX).
     */
    public function exportExcel(Request $request)
    {
        $query = Attendance::with([
            'student.user',
            'student.faculty',
            'student.major',
            'student.shift',
            'schedule',
            'session.teacher.user',
            'session.faculty',
            'session.major'
        ]);

        if ($request->studentId || $request->student_id) {
            $query->forStudent($request->studentId ?? $request->student_id);
        }
        if ($request->date)
            $query->forDate($request->date);
        if ($request->month && $request->year)
            $query->forMonth($request->month, $request->year);
        elseif ($request->year)
            $query->forYear($request->year);
        if ($request->status)
            $query->where('status', $request->status);

        $records = $query->orderBy('attendance_date', 'desc')->get();

        // Build a human-readable filter summary
        $filterParts = [];
        if ($request->date)
            $filterParts[] = 'Date: ' . $request->date;
        if ($request->month)
            $filterParts[] = 'Month: ' . $request->month;
        if ($request->year)
            $filterParts[] = 'Year: ' . $request->year;
        if ($request->status)
            $filterParts[] = 'Status: ' . $request->status;
        $filterInfo = $filterParts ? implode(' | ', $filterParts) : 'All records';

        return (new \App\Exports\AttendanceExport(
            $records,
            auth()->user()?->name ?? 'System',
            $filterInfo
        ))->download('attendance-report-' . now()->format('Y-m-d') . '.xlsx');
    }
}
