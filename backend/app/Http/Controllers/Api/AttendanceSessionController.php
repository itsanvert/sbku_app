<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAttendanceSessionRequest;
use App\Models\Attendance;
use App\Models\AttendanceSession;
use App\Models\Student;
use App\Services\AttendanceSessionService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

/**
 * Thin API controller for attendance sessions.
 *
 * Business logic lives in AttendanceSessionService.
 * Validation lives in Form Requests.
 *
 * NOTE: Responses maintain the ORIGINAL flat format for backward
 * compatibility with the existing Flutter AttendanceService.
 */
class AttendanceSessionController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AttendanceSessionService $sessionService,
    ) {
    }

    /**
     * Start a new attendance session (teacher).
     */
    public function store(StoreAttendanceSessionRequest $request)
    {
        $session = $this->sessionService->startSession($request->validated());

        return response()->json([
            'message' => 'Session started successfully',
            'session' => $session,
            'qr_token' => $session->qr_token,
        ], 201);
    }

    /**
     * List active sessions.
     */
    public function active(Request $request)
    {
        $sessions = AttendanceSession::active()
            ->with(['teacher.user', 'faculty', 'major', 'schedule'])
            ->withCount('attendances')
            ->when($request->teacher_id, fn($q) => $q->where('teacher_id', $request->teacher_id))
            ->orderBy('started_at', 'desc')
            ->get();

        return response()->json($sessions);
    }

    /**
     * Show session details with checked-in students.
     */
    public function show($id)
    {
        $session = AttendanceSession::with([
            'teacher.user',
            'faculty',
            'major',
            'schedule',
            'attendances.student.user',
        ])->findOrFail($id);

        return response()->json($session);
    }

    /**
     * Student QR check-in.
     */
    public function checkIn(Request $request, $id)
    {
        $request->validate([
            'qr_token' => 'required|string',
        ]);

        $student = Student::where('user_id', $request->user()->id)->first();

        if (!$student) {
            return response()->json(['message' => 'You are not registered as a student. Cannot check in.'], 403);
        }

        $session = AttendanceSession::findOrFail($id);

        try {
            $attendance = $this->sessionService->checkIn(
                $session,
                $student,
                $request->qr_token,
            );

            return response()->json([
                'message' => 'Check-in successful',
                'attendance' => $attendance->load('student.user'),
            ], 201);
        } catch (\Exception $e) {
            $code = $e->getCode() ?: 422;
            return response()->json(
                ['message' => $e->getMessage()],
                is_int($code) ? $code : 422,
            );
        }
    }

    /**
     * End a session and finalize attendance records.
     */
    public function end($id)
    {
        $session = AttendanceSession::findOrFail($id);

        try {
            $result = $this->sessionService->endSession($session);

            return response()->json([
                'message' => 'Session ended successfully',
                'session' => $result['session'],
                'total_present' => $result['total_present'],
                'total_absent' => $result['total_absent'],
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode() ?: 422;
            return response()->json(
                ['message' => $e->getMessage()],
                is_int($code) ? $code : 422,
            );
        }
    }

    /**
     * Renew the QR token for a session.
     *
     * Called when the teacher wants to regenerate the QR code
     * (e.g. at the start of a new session period).
     */
    public function renewToken($id)
    {
        $session = AttendanceSession::findOrFail($id);

        try {
            $updated = $this->sessionService->renewToken($session);

            return response()->json([
                'message' => 'QR token renewed successfully',
                'session' => $updated,
                'qr_token' => $updated->qr_token,
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode() ?: 422;
            return response()->json(
                ['message' => $e->getMessage()],
                is_int($code) ? $code : 422,
            );
        }
    }

    /**
     * List all check-ins for a session, grouped by verify_status.
     */
    public function approvalList($id)
    {
        $session = AttendanceSession::with([
            'teacher.user',
            'faculty',
            'major',
        ])->findOrFail($id);

        $attendances = Attendance::with(['student.user', 'student.faculty', 'student.major', 'student.shift'])
            ->where('session_id', $id)
            ->whereIn('status', ['Y', 'P'])
            ->orderBy('check_in_time')
            ->get()
            ->map(function ($a) {
                $student = $a->student;
                return [
                    'id' => $a->id,
                    'student_id' => $a->student_id,
                    'student_name' => $student?->user?->name ?? $student?->name ?? 'Unknown',
                    'student_code' => $student?->student_code ?? '',
                    'avatar_url' => $student?->avatar_url,
                    'faculty' => $student?->faculty?->name ?? '—',
                    'major' => $student?->major?->name ?? '—',
                    'year' => $student?->year ?? '—',
                    'shift' => $student?->shift?->name ?? '—',
                    'generation' => $student?->generation ?? '—',
                    'check_in_time' => $a->check_in_time?->format('H:i:s'),
                    'status' => $a->status,
                    'permission_reason' => $a->permission_reason,
                    'permission_image_url' => $a->permission_image_url,
                    'verify_status' => $a->verify_status,
                    'reject_reason' => $a->reject_reason,
                    'verified_at' => $a->verified_at?->format('H:i:s'),
                ];
            });

        $grouped = [
            'pending' => $attendances->where('verify_status', 'pending')->values(),
            'approved' => $attendances->where('verify_status', 'approved')->values(),
            'rejected' => $attendances->where('verify_status', 'rejected')->values(),
        ];

        return response()->json([
            'session' => $session,
            'attendances' => $grouped,
            'counts' => [
                'pending' => $grouped['pending']->count(),
                'approved' => $grouped['approved']->count(),
                'rejected' => $grouped['rejected']->count(),
            ],
        ]);
    }

    /**
     * Approve or reject a single student check-in.
     */
    public function verifyAttendance(Request $request, $sessionId, $attendanceId)
    {
        $request->validate([
            'action' => 'required|in:approved,rejected',
            'reason' => 'nullable|string|max:500',
        ]);

        $session = AttendanceSession::findOrFail($sessionId);
        $attendance = Attendance::where('session_id', $sessionId)->findOrFail($attendanceId);

        try {
            $result = $this->sessionService->verifyAttendance(
                $attendance,
                $request->action,
                $request->reason,
            );

            return response()->json([
                'message' => $request->action === 'approved'
                    ? 'Attendance approved successfully.'
                    : 'Attendance rejected — student marked as absent.',
                'attendance' => $result,
            ]);
        } catch (\Exception $e) {
            $code = $e->getCode() ?: 409;
            return response()->json(
                ['message' => $e->getMessage(), 'current_status' => $attendance->verify_status],
                is_int($code) ? $code : 409,
            );
        }
    }
}
