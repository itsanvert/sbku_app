<?php

namespace App\Services;

use App\Models\Syllabus;

class ScheduleConflictDetector
{
    /**
     * Check for teacher scheduling conflicts.
     *
     * A conflict exists when the same teacher is assigned to two sessions
     * on the same day whose time ranges OVERLAP:
     *
     *   existing.start_time < new.end_time  AND  existing.end_time > new.start_time
     *
     * Back-to-back sessions share an endpoint but do NOT overlap:
     *   Session A ends 08:30, Session B starts 08:30 → end_time > start_time = false → OK ✓
     *
     * @param  array    $data       ['teacher_id', 'day_of_week', 'start_time', 'end_time']
     * @param  int|null $excludeId  Syllabus ID to exclude (own row when updating)
     * @return array    ['valid' => bool, 'errors' => string[]]
     */
    public function validate(array $data, ?int $excludeId = null): array
    {
        $errors = [];

        // 1. Sanity: end must be after start
        if ($data['start_time'] >= $data['end_time']) {
            return [
                'valid'  => false,
                'errors' => ['End time must be later than start time.'],
            ];
        }

        // 2. Teacher conflict — same teacher, same day, overlapping times
        $teacherConflict = Syllabus::where('teacher_id', $data['teacher_id'])
            ->where('day_of_week', $data['day_of_week'])
            ->where('start_time', '<', $data['end_time'])   // overlap part 1
            ->where('end_time',   '>', $data['start_time']) // overlap part 2
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId))
            ->with([
                'subject:id,name',
                'teacher.user:id,name',
            ])
            ->first();

        if ($teacherConflict) {
            $errors[] = sprintf(
                'Teacher conflict: "%s" is already assigned to "%s" on %s from %s to %s.',
                $teacherConflict->teacher?->user?->name ?? 'this teacher',
                $teacherConflict->subject?->name         ?? 'another subject',
                ucfirst($data['day_of_week']),
                \Carbon\Carbon::parse($teacherConflict->start_time)->format('H:i'),
                \Carbon\Carbon::parse($teacherConflict->end_time)->format('H:i'),
            );
        }

        // 3. Class-level conflict — same major/year/semester, same day, overlapping times
        //    (a class group can't have two subjects at the same time)
        if (isset($data['major_id'], $data['year_id'], $data['semester_id'])) {
            $classConflict = Syllabus::where('major_id',    $data['major_id'])
                ->where('year_id',      $data['year_id'])
                ->where('semester_id',  $data['semester_id'])
                ->where('day_of_week',  $data['day_of_week'])
                ->where('start_time',   '<', $data['end_time'])
                ->where('end_time',     '>', $data['start_time'])
                ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId))
                ->with([
                    'subject:id,name',
                    'teacher.user:id,name',
                ])
                ->first();

            if ($classConflict) {
                $errors[] = sprintf(
                    'Class conflict: this group already has "%s" (with %s) on %s from %s to %s.',
                    $classConflict->subject?->name        ?? 'another subject',
                    $classConflict->teacher?->user?->name ?? 'another teacher',
                    ucfirst($data['day_of_week']),
                    \Carbon\Carbon::parse($classConflict->start_time)->format('H:i'),
                    \Carbon\Carbon::parse($classConflict->end_time)->format('H:i'),
                );
            }
        }

        return [
            'valid'  => empty($errors),
            'errors' => $errors,
        ];
    }

    /**
     * Get all of a teacher's existing syllabus slots for a given week.
     * Useful for displaying a teacher's schedule grid without extra queries.
     *
     * @param  int $teacherId
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function teacherWeeklySlots(int $teacherId): \Illuminate\Database\Eloquent\Collection
    {
        return Syllabus::where('teacher_id', $teacherId)
            ->whereNotNull('day_of_week')
            ->whereNotNull('start_time')
            ->whereNotNull('end_time')
            ->with(['subject:id,name,code', 'major:id,name'])
            ->orderByRaw("CASE 
                WHEN day_of_week = 'monday' THEN 1 
                WHEN day_of_week = 'tuesday' THEN 2 
                WHEN day_of_week = 'wednesday' THEN 3 
                WHEN day_of_week = 'thursday' THEN 4 
                WHEN day_of_week = 'friday' THEN 5 
                WHEN day_of_week = 'saturday' THEN 6 
                WHEN day_of_week = 'sunday' THEN 7 
                ELSE 8 
            END")
            ->orderBy('start_time')
            ->get();
    }
}
