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
use App\Models\Syllabus;
use App\Models\Teacher;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Collection;

/**
 * Maps Firestore document arrays to Eloquent models for Livewire / Blade views.
 */
class FirestoreHydrator
{
    /**
     * Dropdown rows with ->id and ->name (and other scalar fields as object properties).
     */
    public static function selectOptions(array $rows, string $sortBy = 'name'): Collection
    {
        return collect($rows)
            ->sortBy($sortBy)
            ->map(fn (array $row) => (object) $row)
            ->values();
    }

    public static function teacherSelectOptions(array $rows): Collection
    {
        return collect($rows)->map(function (array $row) {
            $teacher = (object) $row;
            $teacher->user = (object) [
                'name' => $row['user_name'] ?? $row['name'] ?? '—',
            ];
            $teacher->major = ! empty($row['major_name'])
                ? (object) ['name' => $row['major_name']]
                : null;

            return $teacher;
        })->values();
    }

    public static function teacher(array $data): Teacher
    {
        $teacher = new Teacher();
        $teacher->forceFill($data);
        $teacher->exists = true;

        $teacher->setRelation('user', (new User())->forceFill([
            'id'    => $data['user_id'] ?? null,
            'name'  => $data['user_name'] ?? $data['name'] ?? '—',
            'email' => $data['user_email'] ?? $data['email'] ?? null,
        ]));
        $teacher->setRelation('major', (new Major())->forceFill([
            'id'   => $data['major_id'] ?? null,
            'name' => $data['major_name'] ?? '—',
        ]));
        $teacher->setRelation('faculty', (new Faculty())->forceFill([
            'id'   => $data['faculty_id'] ?? null,
            'name' => $data['faculty_name'] ?? '—',
        ]));
        $teacher->setRelation('shift', (new Shift())->forceFill([
            'id'   => $data['shift_id'] ?? null,
            'name' => $data['shift_name'] ?? '—',
        ]));

        return $teacher;
    }

    public static function syllabus(array $data): Syllabus
    {
        $syllabus = new Syllabus();
        $syllabus->forceFill($data);
        $syllabus->exists = true;

        $syllabus->setRelation('subject', (new Subject())->forceFill([
            'id'   => $data['subject_id'] ?? null,
            'name' => $data['subject_name'] ?? '—',
            'code' => $data['subject_code'] ?? null,
        ]));
        $syllabus->setRelation('faculty', (new Faculty())->forceFill([
            'id'   => $data['faculty_id'] ?? null,
            'name' => $data['faculty_name'] ?? '—',
        ]));
        $syllabus->setRelation('major', (new Major())->forceFill([
            'id'   => $data['major_id'] ?? null,
            'name' => $data['major_name'] ?? '—',
        ]));
        $syllabus->setRelation('shift', (new Shift())->forceFill([
            'id'   => $data['shift_id'] ?? null,
            'name' => $data['shift_name'] ?? '—',
        ]));

        $teacher = new Teacher();
        $teacher->forceFill(['id' => $data['teacher_id'] ?? null]);
        $teacher->setRelation('user', (new User())->forceFill([
            'name' => $data['teacher_name'] ?? $data['teacher_user_name'] ?? '—',
        ]));
        $syllabus->setRelation('teacher', $teacher);

        return $syllabus;
    }

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
            'id'              => $data['schedule_id'] ?? null,
            'name'            => $data['schedule_name'] ?? '—',
            'day_of_the_week' => $data['day_of_week'] ?? $data['schedule_day'] ?? null,
            'start_time'      => $data['session_start_time'] ?? $data['schedule_start_time'] ?? null,
            'end_time'        => $data['session_end_time'] ?? $data['schedule_end_time'] ?? null,
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

    public static function schedule(array $data): Schedule
    {
        $schedule = new Schedule();
        $schedule->forceFill($data);
        $schedule->exists = true;

        return $schedule;
    }

    public static function academicClass(array $data): AcademicClass
    {
        $class = new AcademicClass();
        $class->forceFill($data);
        $class->exists = true;

        return $class;
    }

    public static function room(array $data): Room
    {
        $room = new Room();
        $room->forceFill($data);
        $room->exists = true;

        return $room;
    }

    /** @return Collection<int, Schedule> */
    public static function scheduleCollection(array $rows): Collection
    {
        return collect($rows)->map(fn (array $row) => self::schedule($row))->values();
    }

    /** @return Collection<int, AcademicClass> */
    public static function academicClassCollection(array $rows): Collection
    {
        return collect($rows)->map(fn (array $row) => self::academicClass($row))->values();
    }

    /** @return Collection<int, Teacher> */
    public static function teacherCollection(array $rows): Collection
    {
        return collect($rows)->map(fn (array $row) => self::teacher($row))->values();
    }

    /** @return Collection<int, Syllabus> */
    public static function syllabusCollection(array $rows): Collection
    {
        return collect($rows)->map(fn (array $row) => self::syllabus($row))->values();
    }
}
