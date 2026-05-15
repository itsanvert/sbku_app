<?php

namespace App\Support;

use App\Models\AcademicClass;
use App\Models\AttendanceSession;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Room;
use App\Models\Schedule;
use App\Models\Shift;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\User;
use Carbon\Carbon;

/**
 * Maps Firestore document arrays to Eloquent models for Livewire / Blade views.
 */
class FirestoreHydrator
{
    public static function attendanceSession(array $data): AttendanceSession
    {
        $session = new AttendanceSession();
        $session->forceFill($data);
        $session->exists = true;

        $teacher = new Teacher();
        $teacher->forceFill(['id' => $data['teacher_id'] ?? null]);
        $teacher->setRelation('user', (new User())->forceFill([
            'id'   => $data['teacher_user_id'] ?? null,
            'name' => $data['teacher_name'] ?? $data['teacher_user_name'] ?? 'Unknown',
        ]));
        $session->setRelation('teacher', $teacher);

        $session->setRelation('faculty', (new Faculty())->forceFill([
            'id'   => $data['faculty_id'] ?? null,
            'name' => $data['faculty_name'] ?? '—',
        ]));
        $session->setRelation('major', (new Major())->forceFill([
            'id'   => $data['major_id'] ?? null,
            'name' => $data['major_name'] ?? '—',
        ]));
        $session->setRelation('shift', (new Shift())->forceFill([
            'id'   => $data['shift_id'] ?? null,
            'name' => $data['shift_name'] ?? '',
        ]));
        $session->setRelation('academicClass', (new AcademicClass())->forceFill([
            'id'   => $data['academic_class_id'] ?? null,
            'name' => $data['academic_class_name'] ?? $data['class_name'] ?? '—',
        ]));
        $session->setRelation('room', (new Room())->forceFill([
            'id'   => $data['room_id'] ?? null,
            'name' => $data['room_name'] ?? '—',
        ]));

        $schedule = new Schedule();
        $schedule->forceFill([
            'id'               => $data['schedule_id'] ?? null,
            'name'             => $data['schedule_name'] ?? '—',
            'day_of_the_week'  => $data['day_of_week'] ?? $data['schedule_day'] ?? null,
            'start_time'       => $data['session_start_time'] ?? $data['schedule_start_time'] ?? null,
            'end_time'         => $data['session_end_time'] ?? $data['schedule_end_time'] ?? null,
        ]);
        $session->setRelation('schedule', $schedule);

        if (! isset($data['attendances_count'])) {
            $session->setAttribute('attendances_count', 0);
        }

        return $session;
    }

    public static function subject(array $data): Subject
    {
        $subject = new Subject();
        $subject->forceFill($data);
        $subject->exists = true;

        if (! empty($data['created_at']) && is_string($data['created_at'])) {
            $subject->setAttribute('created_at', Carbon::parse($data['created_at']));
        }

        return $subject;
    }
}
