<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Syllabus extends Model
{
    protected $table = 'syllabuses';

    protected $fillable = [
        'faculty_id',
        'major_id',
        'subject_id',
        'teacher_id',
        'shift_id',
        'year_id',
        'semester_id',
        'schedule_description',
        'day_of_week',
        'start_time',
        'end_time',
        'academic_class_id',
    ];

    protected $casts = [
        'semester_id' => 'integer',
        'start_time'  => 'string', // Keep as H:i string for simple comparison
        'end_time'    => 'string',
    ];

    // ── Relationships ──────────────────────────────────────────────────────────

    public function faculty(): BelongsTo
    {
        return $this->belongsTo(Faculty::class);
    }

    public function major(): BelongsTo
    {
        return $this->belongsTo(Major::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(Teacher::class);
    }

    public function shift(): BelongsTo
    {
        return $this->belongsTo(Shift::class);
    }

    public function academicClass(): BelongsTo
    {
        return $this->belongsTo(AcademicClass::class);
    }

    // ── Query Scopes (used by ScheduleConflictDetector) ───────────────────────

    /**
     * Scope: find overlapping syllabus rows for a teacher on a given day.
     */
    public function scopeTeacherOverlap(
        $query,
        int    $teacherId,
        string $day,
        string $start,
        string $end,
        ?int   $excludeId = null
    ) {
        return $query
            ->where('teacher_id',  $teacherId)
            ->where('day_of_week', $day)
            ->where('start_time',  '<', $end)
            ->where('end_time',    '>', $start)
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId));
    }

    /**
     * Scope: find overlapping rows for a class group on a given day.
     */
    public function scopeClassGroupOverlap(
        $query,
        int    $majorId,
        string $yearId,
        int    $semesterId,
        string $day,
        string $start,
        string $end,
        ?int   $excludeId = null
    ) {
        return $query
            ->where('major_id',    $majorId)
            ->where('year_id',     $yearId)
            ->where('semester_id', $semesterId)
            ->where('day_of_week', $day)
            ->where('start_time',  '<', $end)
            ->where('end_time',    '>', $start)
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId));
    }
}
