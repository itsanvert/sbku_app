<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

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

    /**
     * Keep times as plain strings (H:i:s) — consistent with Schedule model.
     * This avoids timezone shifting when comparing or displaying time values.
     */
    protected $casts = [
        'semester_id' => 'integer',
        'start_time' => 'string',
        'end_time' => 'string',
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

    /**
     * The concrete time slots (Schedule rows) derived from this syllabus entry.
     * A syllabus defines the course; Schedules define individual occurrences.
     */
    public function schedules(): HasMany
    {
        return $this->hasMany(Schedule::class);
    }

    /**
     * All attendance sessions ever run under this syllabus (across all its Schedules).
     */
    public function attendanceSessions(): HasMany
    {
        return $this->hasMany(AttendanceSession::class);
    }

    // ── Accessors ─────────────────────────────────────────────────────────────

    /**
     * A concise, human-readable label for dropdowns and display.
     * Example: "Advanced Mathematics — Monday 08:00-10:00"
     */
    public function getDisplayNameAttribute(): string
    {
        $name = $this->subject?->name ?? 'Unknown Subject';

        if ($this->day_of_week && $this->start_time && $this->end_time) {
            $name .= ' — ' . ucfirst($this->day_of_week)
                . ' ' . substr($this->start_time, 0, 5)
                . '-' . substr($this->end_time, 0, 5);
        }

        return $name;
    }

    /**
     * Human-readable time range: "08:00 - 10:00"
     */
    public function getTimeRangeAttribute(): string
    {
        if ($this->start_time && $this->end_time) {
            return substr($this->start_time, 0, 5) . ' - ' . substr($this->end_time, 0, 5);
        }
        return '—';
    }

    // ── Scopes ─────────────────────────────────────────────────────────────────

    /**
     * Filter to a specific semester.
     */
    public function scopeForSemester($query, int $semesterId)
    {
        return $query->where('semester_id', $semesterId);
    }

    /**
     * Filter to a specific year level.
     */
    public function scopeForYear($query, string $yearId)
    {
        return $query->where('year_id', $yearId);
    }

    /**
     * Filter to a specific teacher.
     */
    public function scopeForTeacher($query, int $teacherId)
    {
        return $query->where('teacher_id', $teacherId);
    }

    /**
     * Filter to a specific academic class.
     */
    public function scopeForClass($query, int $classId)
    {
        return $query->where('academic_class_id', $classId);
    }

    /**
     * Scope: find overlapping syllabus rows for a teacher on a given day.
     * Used by ScheduleConflictDetector.
     */
    public function scopeTeacherOverlap(
        $query,
        int $teacherId,
        string $day,
        string $start,
        string $end,
        ?int $excludeId = null
    ) {
        return $query
            ->where('teacher_id', $teacherId)
            ->where('day_of_week', $day)
            ->where('start_time', '<', $end)
            ->where('end_time', '>', $start)
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId));
    }

    /**
     * Scope: find overlapping rows for a class group on a given day.
     * Used by ScheduleConflictDetector.
     */
    public function scopeClassGroupOverlap(
        $query,
        int $majorId,
        string $yearId,
        int $semesterId,
        string $day,
        string $start,
        string $end,
        ?int $excludeId = null
    ) {
        return $query
            ->where('major_id', $majorId)
            ->where('year_id', $yearId)
            ->where('semester_id', $semesterId)
            ->where('day_of_week', $day)
            ->where('start_time', '<', $end)
            ->where('end_time', '>', $start)
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId));
    }
}
