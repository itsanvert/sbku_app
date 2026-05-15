<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Traits\SyncsToFirestore;

class Schedule extends Model
{
    use SyncsToFirestore;

    protected $fillable = [
        'name',
        'day_of_the_week',
        'start_time',
        'end_time',
        'start_date',
        'end_date',
        'class_id',
        'teacher_id',
        'subject_id',
        'room_id',
        'syllabus_id',
    ];

    /**
     * Keep start_time / end_time as raw strings (H:i:s) to avoid timezone
     * ambiguity with MySQL TIME columns. Use Carbon::parse() explicitly when
     * formatting is needed. start_date / end_date are proper dates.
     */
    protected $casts = [
        'start_time' => 'string',
        'end_time'   => 'string',
        'start_date' => 'date',
        'end_date'   => 'date',
    ];

    // ── Relationships ──────────────────────────────────────────────────────────

    public function syllabus(): BelongsTo
    {
        return $this->belongsTo(Syllabus::class);
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(Teacher::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /** The class group assigned to this time slot. */
    public function academicClass(): BelongsTo
    {
        return $this->belongsTo(AcademicClass::class, 'class_id');
    }

    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class);
    }

    /** All attendance sessions that were run under this schedule slot. */
    public function attendanceSessions(): HasMany
    {
        return $this->hasMany(AttendanceSession::class);
    }

    // ── Scopes ────────────────────────────────────────────────────────────────

    /**
     * Filter schedules for a specific day of the week.
     * Accepts "Monday", "monday", etc. (case-insensitive).
     */
    public function scopeForDay($query, string $day)
    {
        return $query->whereRaw('LOWER(day_of_the_week) = ?', [strtolower($day)]);
    }

    /**
     * Filter schedules active on a given date (within start_date..end_date range).
     */
    public function scopeActiveOn($query, string $date)
    {
        return $query->where(function ($q) use ($date) {
            $q->whereNull('start_date')->orWhere('start_date', '<=', $date);
        })->where(function ($q) use ($date) {
            $q->whereNull('end_date')->orWhere('end_date', '>=', $date);
        });
    }

    /**
     * Find schedules whose time range overlaps with [start, end].
     * Uses the standard overlap formula: existing.start < new.end AND existing.end > new.start
     */
    public function scopeOverlapping($query, string $start, string $end, ?int $excludeId = null)
    {
        return $query
            ->where('start_time', '<', $end)
            ->where('end_time',   '>', $start)
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId));
    }

    /**
     * Filter to schedules belonging to a specific teacher.
     */
    public function scopeForTeacher($query, int $teacherId)
    {
        return $query->where('teacher_id', $teacherId);
    }

    // ── Accessors ─────────────────────────────────────────────────────────────

    /**
     * Human-readable time range string: "08:00 - 10:00"
     */
    public function getTimeRangeAttribute(): string
    {
        if ($this->start_time && $this->end_time) {
            return substr($this->start_time, 0, 5) . ' - ' . substr($this->end_time, 0, 5);
        }
        return '—';
    }

    /**
     * Full display label: "Schedule Name (Monday: 08:00-10:00)"
     */
    public function getFullDisplayAttribute(): string
    {
        $display = (string)($this->name ?? '—');

        if ($this->day_of_the_week) {
            $display .= " ({$this->day_of_the_week}";

            if ($this->start_time && $this->end_time) {
                $display .= ': ' . substr($this->start_time, 0, 5) . '-' . substr($this->end_time, 0, 5);
            }

            $display .= ')';
        }

        return $display;
    }
}
