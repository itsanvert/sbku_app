<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\AttendanceSession;
use App\Models\Student;
use Illuminate\Support\Facades\DB;

/**
 * Encapsulates attendance session business logic.
 *
 * Handles session lifecycle (start, check-in, end, verify)
 * with proper validation and data integrity.
 */
class AttendanceSessionService
{
    /**
     * Start a new attendance session.
     */
    public function startSession(array $validated): AttendanceSession
    {
        $session = AttendanceSession::create([
            'teacher_id'         => $validated['teacher_id'],
            'faculty_id'         => $validated['faculty_id']   ?? null,
            'major_id'           => $validated['major_id']     ?? null,
            'schedule_id'        => $validated['schedule_id']  ?? null,
            'syllabus_id'        => $validated['syllabus_id']  ?? null,
            'subject_id'         => $validated['subject_id']   ?? null,
            'year_id'            => $validated['year_id']      ?? null,
            'semester_id'        => $validated['semester_id']  ?? null,
            'day_of_week'        => $validated['day_of_week']  ?? null,
            'session_start_time' => $validated['start_time']   ?? null,
            'session_end_time'   => $validated['end_time']     ?? null,
            'latitude'           => $validated['latitude']     ?? null,
            'longitude'          => $validated['longitude']    ?? null,
            'started_at'         => \Carbon\Carbon::today()->setTimeFromTimeString($validated['start_time'] ?? '00:00'),
            'is_active'          => true,
        ]);

        return $session->load(['teacher.user', 'faculty', 'major', 'subject', 'syllabus']);
    }

    /**
     * Process a student QR check-in.
     *
     * @throws \Exception if validation fails
     */
    public function checkIn(AttendanceSession $session, Student $student, string $qrToken): Attendance
    {
        if (!$session->is_active) {
            throw new \Exception('Session is no longer active', 422);
        }

        if ($session->qr_token !== $qrToken) {
            throw new \Exception('Invalid QR token', 422);
        }

        $existing = Attendance::where('session_id', $session->id)
            ->where('student_id', $student->id)
            ->first();

        if ($existing) {
            throw new \Exception('Already checked in', 409);
        }

        return Attendance::create([
            'attendance_date' => now()->toDateString(),
            'check_in_time'   => now(),
            'status'          => 'Y',
            'student_id'      => $student->id,
            'schedule_id'     => $session->schedule_id,
            'session_id'      => $session->id,
        ]);
    }

    /**
     * End a session and finalize all attendance records.
     *
     * - Rejects unverified pending check-ins
     * - Creates absent records for students who didn't check in
     */
    public function endSession(AttendanceSession $session): array
    {
        if (!$session->is_active) {
            throw new \Exception('Session already ended', 422);
        }

        DB::transaction(function () use ($session) {
            $session->update([
                'is_active' => false,
                'ended_at'  => now(),
            ]);

            // Get eligible students — filtered by major, faculty, and year (from syllabus)
            $query = Student::query();
            if ($session->faculty_id) {
                $query->where('faculty_id', $session->faculty_id);
            }
            if ($session->major_id) {
                $query->where('major_id', $session->major_id);
            }
            // Narrow to the specific year from syllabus if available
            if ($session->year_id) {
                $query->where('year', $session->year_id);
            }

            $allStudents = $query->pluck('id');
            $checkedInStudents = $session->attendances()->pluck('student_id');

            // Reject unverified pending check-ins
            $session->attendances()
                ->where('verify_status', 'pending')
                ->update([
                    'verify_status' => 'rejected',
                    'reject_reason' => 'Session ended without teacher verification',
                    'verified_at'   => now(),
                    'status'        => 'N',
                ]);

            // Create absent records
            $absentStudents = $allStudents->diff($checkedInStudents);
            foreach ($absentStudents as $studentId) {
                Attendance::create([
                    'attendance_date' => $session->started_at->toDateString(),
                    'status'          => 'N',
                    'verify_status'   => 'approved',
                    'student_id'      => $studentId,
                    'schedule_id'     => $session->schedule_id,
                    'session_id'      => $session->id,
                ]);
            }
        });

        return [
            'session'       => $session->fresh()->load(['attendances.student.user']),
            'total_present' => $session->attendances()->where('status', 'Y')->count(),
            'total_absent'  => $session->attendances()->where('status', 'N')->count(),
        ];
    }

    /**
     * Verify (approve/reject) a student attendance check-in.
     */
    public function verifyAttendance(
        Attendance $attendance,
        string $action,
        ?string $reason = null,
    ): Attendance {
        if ($attendance->verify_status !== 'pending') {
            throw new \Exception('This attendance has already been verified', 409);
        }

        $attendance->update([
            'verify_status' => $action,
            'reject_reason' => $reason,
            'verified_at'   => now(),
            'status'        => $action === 'approved'
                ? ($attendance->status === 'P' ? 'P' : 'Y')
                : 'N',
        ]);

        return $attendance->load('student.user');
    }
}
