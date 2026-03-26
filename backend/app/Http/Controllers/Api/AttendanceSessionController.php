<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\AttendanceSession;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AttendanceSessionController extends Controller
{
    /**
     * Start a new attendance session (teacher).
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'teacher_id' => 'required|exists:teachers,id',
            'faculty_id' => 'nullable|exists:faculties,id',
            'major_id' => 'nullable|exists:majors,id',
            'schedule_id' => 'nullable|exists:schedules,id',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $session = AttendanceSession::create([
            'teacher_id' => $validated['teacher_id'],
            'faculty_id' => $validated['faculty_id'] ?? null,
            'major_id' => $validated['major_id'] ?? null,
            'schedule_id' => $validated['schedule_id'] ?? null,
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'started_at' => now(),
            'is_active' => true,
        ]);

        return response()->json([
            'message' => 'Session started successfully',
            'session' => $session->load(['teacher.user', 'faculty', 'major']),
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
        $validated = $request->validate([
            'qr_token' => 'required|string',
        ]);

        // Find the student linked to the currently authenticated user
        $student = Student::where('user_id', $request->user()->id)->first();

        if (!$student) {
            return response()->json(['message' => 'You are not registered as a student. Cannot check in.'], 403);
        }

        $session = AttendanceSession::findOrFail($id);

        // Validate session is active
        if (!$session->is_active) {
            return response()->json(['message' => 'Session is no longer active'], 422);
        }

        // Validate QR token
        if ($session->qr_token !== $validated['qr_token']) {
            return response()->json(['message' => 'Invalid QR token'], 422);
        }

        // Check if student already checked in
        $existing = Attendance::where('session_id', $session->id)
            ->where('student_id', $student->id)
            ->first();

        if ($existing) {
            return response()->json([
                'message' => 'Already checked in',
                'attendance' => $existing,
            ], 409);
        }

        // Create attendance record
        $attendance = Attendance::create([
            'attendance_date' => now()->toDateString(),
            'check_in_time' => now(),
            'status' => 'Y',
            'student_id' => $student->id,
            'schedule_id' => $session->schedule_id,
            'session_id' => $session->id,
        ]);

        return response()->json([
            'message' => 'Check-in successful',
            'attendance' => $attendance->load('student.user'),
        ], 201);
    }

    /**
     * End a session and finalize attendance records.
     */
    public function end($id)
    {
        $session = AttendanceSession::findOrFail($id);

        if (!$session->is_active) {
            return response()->json(['message' => 'Session already ended'], 422);
        }

        DB::transaction(function () use ($session) {
            // Mark session as ended
            $session->update([
                'is_active' => false,
                'ended_at' => now(),
            ]);

            // Get all students who should have attended (by faculty + major)
            $query = Student::query();

            if ($session->faculty_id) {
                $query->where('faculty_id', $session->faculty_id);
            }
            if ($session->major_id) {
                $query->where('major_id', $session->major_id);
            }

            $allStudents = $query->pluck('id');
            $checkedInStudents = $session->attendances()->pluck('student_id');

            // Create absent records for students who didn't check in
            $absentStudents = $allStudents->diff($checkedInStudents);

            foreach ($absentStudents as $studentId) {
                Attendance::create([
                    'attendance_date' => $session->started_at->toDateString(),
                    'status' => 'N',
                    'student_id' => $studentId,
                    'schedule_id' => $session->schedule_id,
                    'session_id' => $session->id,
                ]);
            }
        });

        return response()->json([
            'message' => 'Session ended successfully',
            'session' => $session->fresh()->load(['attendances.student.user']),
            'total_present' => $session->attendances()->where('status', 'Y')->count(),
            'total_absent' => $session->attendances()->where('status', 'N')->count(),
        ]);
    }
}
