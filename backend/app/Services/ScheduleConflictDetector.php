<?php

namespace App\Services;

use App\Models\Syllabus;
use Illuminate\Support\Collection;

class ScheduleConflictDetector
{
    public function __construct(
        private readonly FirestoreService $firestore,
    ) {}

    /**
     * @param  array    $data       ['teacher_id', 'day_of_week', 'start_time', 'end_time']
     * @param  int|string|null $excludeId  Syllabus ID to exclude (own row when updating)
     * @return array    ['valid' => bool, 'errors' => string[]]
     */
    public function validate(array $data, int|string|null $excludeId = null): array
    {
        $errors = [];

        if ($data['start_time'] >= $data['end_time']) {
            return [
                'valid'  => false,
                'errors' => ['End time must be later than start time.'],
            ];
        }

        if (FirestoreService::isActive()) {
            $syllabuses = collect($this->firestore->list('syllabuses'));
            $teacherConflict = $this->findFirestoreConflict(
                $syllabuses,
                fn (array $s) => (string) ($s['teacher_id'] ?? '') === (string) $data['teacher_id'],
                $data,
                $excludeId,
            );

            if ($teacherConflict) {
                $errors[] = sprintf(
                    'Teacher conflict: "%s" is already assigned to "%s" on %s from %s to %s.',
                    $teacherConflict['teacher_name'] ?? $teacherConflict['teacher_user_name'] ?? 'this teacher',
                    $teacherConflict['subject_name'] ?? 'another subject',
                    ucfirst($data['day_of_week']),
                    \Carbon\Carbon::parse($teacherConflict['start_time'])->format('H:i'),
                    \Carbon\Carbon::parse($teacherConflict['end_time'])->format('H:i'),
                );
            }

            if (isset($data['major_id'], $data['year_id'], $data['semester_id'])) {
                $classConflict = $this->findFirestoreConflict(
                    $syllabuses,
                    fn (array $s) => (string) ($s['major_id'] ?? '') === (string) $data['major_id']
                        && (string) ($s['year_id'] ?? '') === (string) $data['year_id']
                        && (int) ($s['semester_id'] ?? 0) === (int) $data['semester_id'],
                    $data,
                    $excludeId,
                );

                if ($classConflict) {
                    $errors[] = sprintf(
                        'Class conflict: this group already has "%s" (with %s) on %s from %s to %s.',
                        $classConflict['subject_name'] ?? 'another subject',
                        $classConflict['teacher_name'] ?? $classConflict['teacher_user_name'] ?? 'another teacher',
                        ucfirst($data['day_of_week']),
                        \Carbon\Carbon::parse($classConflict['start_time'])->format('H:i'),
                        \Carbon\Carbon::parse($classConflict['end_time'])->format('H:i'),
                    );
                }
            }

            return [
                'valid'  => empty($errors),
                'errors' => $errors,
            ];
        }

        $teacherConflict = Syllabus::where('teacher_id', $data['teacher_id'])
            ->where('day_of_week', $data['day_of_week'])
            ->where('start_time', '<', $data['end_time'])
            ->where('end_time', '>', $data['start_time'])
            ->when($excludeId, fn ($q) => $q->where('id', '!=', $excludeId))
            ->with(['subject:id,name', 'teacher.user:id,name'])
            ->first();

        if ($teacherConflict) {
            $errors[] = sprintf(
                'Teacher conflict: "%s" is already assigned to "%s" on %s from %s to %s.',
                $teacherConflict->teacher?->user?->name ?? 'this teacher',
                $teacherConflict->subject?->name ?? 'another subject',
                ucfirst($data['day_of_week']),
                \Carbon\Carbon::parse($teacherConflict->start_time)->format('H:i'),
                \Carbon\Carbon::parse($teacherConflict->end_time)->format('H:i'),
            );
        }

        if (isset($data['major_id'], $data['year_id'], $data['semester_id'])) {
            $classConflict = Syllabus::where('major_id', $data['major_id'])
                ->where('year_id', $data['year_id'])
                ->where('semester_id', $data['semester_id'])
                ->where('day_of_week', $data['day_of_week'])
                ->where('start_time', '<', $data['end_time'])
                ->where('end_time', '>', $data['start_time'])
                ->when($excludeId, fn ($q) => $q->where('id', '!=', $excludeId))
                ->with(['subject:id,name', 'teacher.user:id,name'])
                ->first();

            if ($classConflict) {
                $errors[] = sprintf(
                    'Class conflict: this group already has "%s" (with %s) on %s from %s to %s.',
                    $classConflict->subject?->name ?? 'another subject',
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

    private function findFirestoreConflict(
        Collection $syllabuses,
        callable $scopeFilter,
        array $data,
        int|string|null $excludeId,
    ): ?array {
        return $syllabuses->first(function (array $s) use ($scopeFilter, $data, $excludeId) {
            if ($excludeId !== null && (string) ($s['id'] ?? '') === (string) $excludeId) {
                return false;
            }

            if (($s['day_of_week'] ?? '') !== $data['day_of_week']) {
                return false;
            }

            if (! $scopeFilter($s)) {
                return false;
            }

            return $this->timesOverlap(
                $s['start_time'] ?? '',
                $s['end_time'] ?? '',
                $data['start_time'],
                $data['end_time'],
            );
        });
    }

    private function timesOverlap(string $existingStart, string $existingEnd, string $newStart, string $newEnd): bool
    {
        return $existingStart < $newEnd && $existingEnd > $newStart;
    }
}
