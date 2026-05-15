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
        private readonly FirestoreService $firestore,
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

        $data = [
            'teacher_id'         => (string) $validated['teacher_id'],
            'faculty_id'         => isset($validated['faculty_id']) ? (string) $validated['faculty_id'] : null,
            'major_id'           => isset($validated['major_id']) ? (string) $validated['major_id'] : null,
            'syllabus_id'        => isset($validated['syllabus_id']) ? (string) $validated['syllabus_id'] : null,
            'subject_id'         => isset($validated['subject_id']) ? (string) $validated['subject_id'] : null,
            'year_id'            => $validated['year_id']      ?? null,
            'semester_id'        => $validated['semester_id']  ?? null,
            'academic_class_id'  => isset($validated['academic_class_id']) ? (string) $validated['academic_class_id'] : null,
            'shift_id'           => isset($validated['shift_id']) ? (string) $validated['shift_id'] : null,
            'day_of_week'        => $validated['day_of_week']  ?? null,
            'session_start_time' => $startTimeString,
            'session_end_time'   => $endTimeString,
            'latitude'           => $validated['latitude']     ?? null,
            'longitude'          => $validated['longitude']    ?? null,
            'room_id'            => isset($validated['room_id']) ? (string) $validated['room_id'] : null,
            'started_at'         => $scheduledStart->format('Y-m-d H:i:s'),
            'expires_at'         => $scheduledEnd ? $scheduledEnd->format('Y-m-d H:i:s') : null,
            'qr_token'           => $freshToken,
            'is_active'          => $isActive,
            'created_at'         => now()->format('Y-m-d H:i:s'),
            'updated_at'         => now()->format('Y-m-d H:i:s'),
        ];

        if (\App\Services\FirestoreService::isActive()) {
            $id = $this->firestore->create('attendance_sessions', $data);
            $session = new AttendanceSession();
            $session->forceFill(array_merge(['id' => $id], $data));
            $session->exists = true;
        } else {
            $session = AttendanceSession::create($data);
        }

        // Try to load some basic names for the notification
        if (\App\Services\FirestoreService::isActive()) {
            $teacher = $this->firestore->getDocument('teachers', $data['teacher_id']);
            $subject = $data['subject_id'] ? $this->firestore->getDocument('subjects', $data['subject_id']) : null;
            
            // Hydrate relationships for the notification logic
            $session->setRelation('teacher', (new \App\Models\Teacher())->forceFill($teacher ?: []));
            if ($subject) $session->setRelation('subject', (new \App\Models\Subject())->forceFill($subject));
        } else {
            $session->load(['teacher.user', 'subject']);
        }

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

    public function checkIn(
        AttendanceSession $session,
        Student $student,
        string $qrToken,
        string $latitude,
        string $longitude,
    ): Attendance {
        // 1. Validate session status and time window
        $this->validateSessionAccess($session);

        // 2. Validate QR Token
        if ($session->qr_token !== $qrToken) {
            throw new \Exception('Invalid or expired QR code. Please scan the latest one.', 403);
        }

        // 3. Prevent duplicate check-ins
        if (\App\Services\FirestoreService::isActive()) {
            $exists = $this->firestore->list('attendances', [
                'session_id' => (string)$session->id,
                'student_id' => (string)$student->id
            ]);
            if (!empty($exists)) {
                throw new \Exception('You have already checked in for this session.', 409);
            }
        } else {
            $exists = Attendance::where('session_id', $session->id)
                ->where('student_id', $student->id)
                ->exists();
            if ($exists) {
                throw new \Exception('You have already checked in for this session.', 409);
            }
        }

        $data = [
            'attendance_date' => now()->toDateString(),
            'status'          => 'Y',
            'verify_status'   => 'pending',
            'student_id'      => (string)$student->id,
            'session_id'      => (string)$session->id,
            'schedule_id'     => isset($session->schedule_id) ? (string)$session->schedule_id : null,
            'latitude'        => $latitude,
            'longitude'       => $longitude,
            'created_at'      => now()->format('Y-m-d H:i:s'),
            'updated_at'      => now()->format('Y-m-d H:i:s'),
        ];

        if (\App\Services\FirestoreService::isActive()) {
            $id = $this->firestore->create('attendances', $data);
            $attendance = new Attendance();
            $attendance->forceFill(array_merge(['id' => $id], $data));
            $attendance->exists = true;
        } else {
            $attendance = Attendance::create($data);
        }

        return $attendance;
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

        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->update('attendance_sessions', (string)$session->id, [
                'qr_token' => $newToken,
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ]);
            $session->qr_token = $newToken;
            return $session;
        }

        $session->update([
            'qr_token' => $newToken,
        ]);

        return $session->fresh();
    }


    public function endSession(AttendanceSession $session): array
    {
        if (!$session->is_active) {
            // Fetch attendances from Firestore if in production
            if (config('app.env') === 'production') {
                $attendances = $this->firestore->list('attendances', ['session_id' => (string)$session->id]);
                return [
                    'session'       => $session,
                    'attendances'   => $attendances,
                    'total_present' => collect($attendances)->where('status', 'Y')->count(),
                    'total_absent'  => collect($attendances)->where('status', 'N')->count(),
                    'message'       => 'Session was already closed.',
                ];
            }
            return [
                'session'       => $session->load(['attendances.student.user']),
                'total_present' => $session->attendances()->where('status', 'Y')->count(),
                'total_absent'  => $session->attendances()->where('status', 'N')->count(),
                'message'       => 'Session was already closed.',
            ];
        }

        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->update('attendance_sessions', (string)$session->id, [
                'is_active' => false,
                'ended_at'  => now()->format('Y-m-d H:i:s'),
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ]);
            $session->is_active = false;
            $session->ended_at = now();

            // Absent logic
            $filters = [];
            if ($session->academic_class_id) $filters['academic_class_id'] = (string)$session->academic_class_id;
            else {
                if ($session->faculty_id) $filters['faculty_id'] = (string)$session->faculty_id;
                if ($session->major_id) $filters['major_id'] = (string)$session->major_id;
                if ($session->year_id) $filters['year'] = (string)$session->year_id;
            }
            
            $allStudents = $this->firestore->list('students', $filters);
            $allStudentIds = collect($allStudents)->pluck('id');
            
            $checkedIn = $this->firestore->list('attendances', ['session_id' => (string)$session->id]);
            $checkedInIds = collect($checkedIn)->pluck('student_id');
            
            $absentIds = $allStudentIds->diff($checkedInIds);
            
            foreach ($absentIds as $studentId) {
                $this->firestore->create('attendances', [
                    'attendance_date' => $session->started_at->toDateString(),
                    'status'          => 'N',
                    'verify_status'   => 'approved',
                    'student_id'      => (string)$studentId,
                    'session_id'      => (string)$session->id,
                    'schedule_id'     => isset($session->schedule_id) ? (string)$session->schedule_id : null,
                    'created_at'      => now()->format('Y-m-d H:i:s'),
                    'updated_at'      => now()->format('Y-m-d H:i:s'),
                ]);
            }
            
            $finalAttendances = $this->firestore->list('attendances', ['session_id' => (string)$session->id]);

            return [
                'session'       => $session,
                'attendances'   => $finalAttendances,
                'total_present' => collect($finalAttendances)->where('status', 'Y')->count(),
                'total_absent'  => collect($finalAttendances)->where('status', 'N')->count(),
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

        $data = [
            'verify_status' => $action,
            'reject_reason' => $reason,
            'verified_at'   => now()->format('Y-m-d H:i:s'),
            'status'        => $action === 'approved'
                ? ($attendance->status === 'P' ? 'P' : 'Y')
                : 'N',
            'updated_at'    => now()->format('Y-m-d H:i:s'),
        ];

        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->update('attendances', (string)$attendance->id, $data);
            $attendance->forceFill($data);
        } else {
            $attendance->update($data);
        }

        return $attendance;
    }
}
