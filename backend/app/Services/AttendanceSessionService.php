<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\AttendanceSession;
use App\Models\Message;
use App\Models\Student;
use App\Models\User;
use App\Services\PushNotificationService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

/**
 * Encapsulates attendance session business logic.
 *
 * Handles session lifecycle (start, check-in, end, verify)
 * with proper validation and data integrity.
 */
class AttendanceSessionService
{
    public function __construct(
        private readonly PushNotificationService $pushService,
    ) {}

    public function startSession(array $validated): AttendanceSession
    {
        $now = now();
        $startTimeString = $validated['start_time'] ?? '00:00';
        $endTimeString = $validated['end_time'] ?? null;

        // Parse start and end times
        $scheduledStart = Carbon::today()->setTimeFromTimeString($startTimeString);
        $scheduledEnd = $endTimeString ? Carbon::today()->setTimeFromTimeString($endTimeString) : null;

        // Smart Date Logic: 
        // 1. If end_time is before start_time, it must be the next day (e.g., 11 PM to 1 AM)
        if ($scheduledEnd && $scheduledEnd->lessThan($scheduledStart)) {
            $scheduledEnd->addDay();
        }

        // 2. If it's late at night and we're starting a session for early morning, 
        // it's likely intended for tomorrow.
        if ($now->hour > 18 && $scheduledStart->hour < 6) {
            $scheduledStart->addDay();
            if ($scheduledEnd) $scheduledEnd->addDay();
        }

        // Generate a fresh QR token
        $freshToken = Str::uuid()->toString();

        // If a teacher is manually starting a session, it should be active 
        // immediately so they can see the QR code and monitor check-ins.
        $isActive = true; 

        $session = AttendanceSession::create([
            'teacher_id'         => $validated['teacher_id'],
            'faculty_id'         => $validated['faculty_id']   ?? null,
            'major_id'           => $validated['major_id']     ?? null,
            'schedule_id'        => $validated['schedule_id']  ?? null,
            'syllabus_id'        => $validated['syllabus_id']  ?? null,
            'subject_id'         => $validated['subject_id']   ?? null,
            'year_id'            => $validated['year_id']      ?? null,
            'semester_id'        => $validated['semester_id']  ?? null,
            'academic_class_id'  => $validated['academic_class_id'] ?? null,
            'shift_id'           => $validated['shift_id']     ?? null,
            'day_of_week'        => $validated['day_of_week']  ?? null,
            'session_start_time' => $startTimeString,
            'session_end_time'   => $endTimeString,
            'latitude'           => $validated['latitude']     ?? null,
            'longitude'          => $validated['longitude']    ?? null,
            'room_id'            => $validated['room_id']      ?? null,
            'started_at'         => $scheduledStart,
            'expires_at'         => $scheduledEnd,
            'qr_token'           => $freshToken,
            'is_active'          => $isActive,
        ]);

        $session->load(['teacher.user', 'faculty', 'major', 'subject', 'syllabus', 'shift', 'academicClass']);

        // Send push notifications to eligible students
        $this->notifyStudentsOfNewSession($session);

        return $session;
    }

    /**
     * Send FCM push notifications and create a Firestore message
     * when a new attendance session starts.
     */
    protected function notifyStudentsOfNewSession(AttendanceSession $session): void
    {
        try {
            $teacherName = $session->teacher?->user?->name ?? 'Teacher';
            $subjectName = $session->subject?->name ?? 'Class';
            $majorName   = $session->major?->name ?? '';
            $shiftName   = $session->shift?->name ?? '';
            $className   = $session->academicClass?->name ?? '';
            $timeSlot    = '';

            if ($session->session_start_time && $session->session_end_time) {
                $timeSlot = \Carbon\Carbon::parse($session->session_start_time)->format('H:i')
                    . ' - ' . \Carbon\Carbon::parse($session->session_end_time)->format('H:i');
            }

            $title = "📋 Attendance Open: {$subjectName}";
            $body  = "{$teacherName} has started attendance check-in";
            if ($timeSlot) {
                $body .= " ({$timeSlot})";
            }
            if ($className) {
                $body .= " — Class: {$className}";
            } elseif ($majorName) {
                $body .= " — {$majorName}";
            }

            // Build the notification data payload for the Flutter app
            $data = [
                'type'              => 'attendance_session_started',
                'session_id'        => (string) $session->id,
                'teacher_name'      => $teacherName,
                'subject_name'      => $subjectName,
                'major_name'        => $majorName,
                'class_name'        => $className,
                'shift_name'        => $shiftName,
                'time_slot'         => $timeSlot,
                'day_of_week'       => $session->day_of_week ?? '',
                'qr_token'          => $session->qr_token ?? '',
                'started_at'        => $session->started_at?->toIso8601String() ?? '',
                'expires_at'        => $session->expires_at?->toIso8601String() ?? '',
            ];

            // 1. Create a Message record (syncs to Firestore automatically via SyncsToFirestore trait)
            Message::create([
                'sender_id'   => $session->teacher?->user_id,
                'receiver_id' => null, // broadcast
                'title'       => $title,
                'body'        => $body,
                'type'        => 'alert',
                'metadata'    => $data,
            ]);

            // 2. Find eligible students and send individual push notifications
            $query = Student::with('user')->whereNotNull('user_id');

            if ($session->academic_class_id) {
                $query->where('academic_class_id', $session->academic_class_id);
            } elseif ($session->major_id) {
                $query->where('major_id', $session->major_id);
                if ($session->year_id) {
                    $query->where('year', $session->year_id);
                }
            }

            if ($session->shift_id) {
                $query->where('shift_id', $session->shift_id);
            }

            $students = $query->get();

            foreach ($students as $student) {
                if ($student->user && $student->user->fcm_token) {
                    $this->pushService->sendToUser($student->user, $title, $body, $data);
                }
            }

            // 3. Also broadcast to the 'all' topic as a fallback
            $this->pushService->sendToTopic('all', $title, $body, $data);

        } catch (\Exception $e) {
            \Log::warning("Failed to notify students about session #{$session->id}: " . $e->getMessage());
        }
    }

    public function checkIn(AttendanceSession $session, Student $student, string $qrToken): Attendance
    {
        $this->validateSessionAccess($session);

        if ($session->qr_token !== $qrToken) {
            throw new \Exception('QR កូដមិនត្រឹមត្រូវ ឬផុតកំណត់។ សូមស្កេន QR ថ្មី។', 422);
        }

        $existing = Attendance::where('session_id', $session->id)
            ->where('student_id', $student->id)
            ->first();

        if ($existing) {
            throw new \Exception('អ្នកបានចុះវត្តមានរួចហើយ។', 409);
        }

        return Attendance::create([
            'attendance_date' => now()->toDateString(),
            'check_in_time'   => now(),
            'status'          => 'Y',
            'student_id'      => $student->id,
            'schedule_id'     => $session->schedule_id,
            'session_id'      => $session->id,
            'verify_status'   => 'pending',
        ]);
    }

    public function validateSessionAccess(AttendanceSession $session): void
    {
        if (!$session->is_active) {
            throw new \Exception('វេនវត្តមានបានបិទរួចហើយ។ មិនអាចចុះវត្តមានបានទេ។', 422);
        }

        $now = now();
        $baseDate = $session->started_at ? $session->started_at->copy()->startOfDay() : Carbon::today();

        if ($session->session_start_time) {
            $scheduledStart = $baseDate->copy()->setTimeFromTimeString($session->session_start_time);
            if ($now->lessThan($scheduledStart)) {
                throw new \Exception('វេនវត្តមានមិនទាន់ចាប់ផ្តើមទេ។ សូមរង់ចាំដល់ម៉ោង ' . $session->session_start_time, 422);
            }
        }

        if ($session->session_end_time) {
            $scheduledEnd = $baseDate->copy()->setTimeFromTimeString($session->session_end_time);
            if ($now->greaterThan($scheduledEnd)) {
                $this->autoEndExpiredSession($session);
                throw new \Exception('ពេលវេលាវេនវត្តមានបានផុតកំណត់។ មិនអាចចុះវត្តមានបានទេ។', 422);
            }
        }
    }

    protected function autoEndExpiredSession(AttendanceSession $session): void
    {
        if (!$session->is_active) return;

        try {
            $this->endSession($session);
        } catch (\Exception $e) {
            \Log::info("Auto-end for session #{$session->id}: {$e->getMessage()}");
        }
    }

    public function renewToken(AttendanceSession $session): AttendanceSession
    {
        if (!$session->is_active) {
            throw new \Exception('Cannot renew token for an inactive session', 422);
        }

        $newToken = Str::uuid()->toString();

        $session->update([
            'qr_token' => $newToken,
        ]);

        return $session->fresh();
    }

    /**
     * Validate if a session is currently accessible for check-in.
     * 
     * @throws \Exception if session is closed or out of time window
     */
    public function validateSessionAccess(AttendanceSession $session): void
    {
        // Check if session is explicitly closed
        if (!$session->is_active) {
            throw new \Exception('វេនវត្តមានបានបិទរួចហើយ។ មិនអាចចុះវត្តមានបានទេ។', 422);
        }

        $now = now();
        // Use started_at date as the base for time comparisons
        $baseDate = $session->started_at ? $session->started_at->copy()->startOfDay() : Carbon::today();

        // Check if session hasn't started yet based on scheduled start time
        if ($session->session_start_time) {
            $scheduledStart = $baseDate->copy()->setTimeFromTimeString($session->session_start_time);
            if ($now->lessThan($scheduledStart)) {
                throw new \Exception('វេនវត្តមានមិនទាន់ចាប់ផ្តើមទេ។ សូមរង់ចាំដល់ម៉ោង ' . $session->session_start_time, 422);
            }
        }

        // Check if session has expired based on scheduled end time
        if ($session->session_end_time) {
            $scheduledEnd = $baseDate->copy()->setTimeFromTimeString($session->session_end_time);
            if ($now->greaterThan($scheduledEnd)) {
                // Auto-end the session since it has expired logically
                $this->autoEndExpiredSession($session);
                throw new \Exception('ពេលវេលាវេនវត្តមានបានផុតកំណត់។ មិនអាចចុះវត្តមានបានទេ។', 422);
            }
        }
    }

    /**
     * Auto-end an expired session (triggered when a student tries to check in
     * after the session's scheduled end time).
     */
    protected function autoEndExpiredSession(AttendanceSession $session): void
    {
        if (!$session->is_active) return;

        try {
            $this->endSession($session);
        } catch (\Exception $e) {
            // Session may have already been ended by another request
            \Log::info("Auto-end for session #{$session->id}: {$e->getMessage()}");
        }
    }

    /**
     * Renew the QR token for a session.
     *
     * Called when a new session period starts to ensure that old QR codes
     * from previous sessions cannot be reused.
     *
     * @throws \Exception if the session is not active
     */
    public function renewToken(AttendanceSession $session): AttendanceSession
    {
        if (!$session->is_active) {
            throw new \Exception('Cannot renew token for an inactive session', 422);
        }

        $newToken = Str::uuid()->toString();

        $session->update([
            'qr_token' => $newToken,
        ]);

        return $session->fresh();
    }

    public function endSession(AttendanceSession $session): array
    {
        if (!$session->is_active) {
            return [
                'session'       => $session->load(['attendances.student.user']),
                'total_present' => $session->attendances()->where('status', 'Y')->count(),
                'total_absent'  => $session->attendances()->where('status', 'N')->count(),
                'message'       => 'Session was already closed.',
            ];
        }

        DB::transaction(function () use ($session) {
            $session->update([
                'is_active' => false,
                'ended_at'  => now(),
            ]);

            $query = Student::query();
            if ($session->academic_class_id) {
                $query->where('academic_class_id', $session->academic_class_id);
            } else {
                if ($session->faculty_id) $query->where('faculty_id', $session->faculty_id);
                if ($session->major_id) $query->where('major_id', $session->major_id);
                if ($session->year_id) $query->where('year', $session->year_id);
            }

            $allStudents = $query->pluck('id');
            $checkedInStudents = $session->attendances()->pluck('student_id');

            $session->attendances()
                ->where('verify_status', 'pending')
                ->update([
                    'verify_status' => 'rejected',
                    'reject_reason' => 'Session ended without teacher verification',
                    'verified_at'   => now(),
                    'status'        => 'N',
                ]);

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
