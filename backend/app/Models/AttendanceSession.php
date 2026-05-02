<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use App\Traits\SyncsToFirestore;

class AttendanceSession extends Model
{
    use SyncsToFirestore;
    protected $fillable = [
        'teacher_id',
        'faculty_id',
        'major_id',
        'schedule_id',
        'syllabus_id',
        'subject_id',
        'year_id',
        'semester_id',
        'day_of_week',
        'session_start_time',
        'session_end_time',
        'qr_token',
        'latitude',
        'longitude',
        'started_at',
        'ended_at',
        'expires_at',
        'time_limit_minutes',
        'is_active',
    ];

    protected $casts = [
        'started_at'         => 'datetime',
        'ended_at'           => 'datetime',
        'expires_at'         => 'datetime',
        'is_active'          => 'boolean',
        'latitude'           => 'decimal:7',
        'longitude'          => 'decimal:7',
        'time_limit_minutes' => 'integer',
        'semester_id'        => 'integer',
    ];

    protected $appends = ['teacher_name'];

    // ── Boot ───────────────────────────────────────────────────
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($session) {
            if (empty($session->qr_token)) {
                $session->qr_token = Str::uuid()->toString();
            }
        });
    }

    // ── Relationships ──────────────────────────────────────────

    public function teacher()
    {
        return $this->belongsTo(Teacher::class);
    }

    public function faculty()
    {
        return $this->belongsTo(Faculty::class);
    }

    public function major()
    {
        return $this->belongsTo(Major::class);
    }

    public function schedule()
    {
        return $this->belongsTo(Schedule::class);
    }

    public function syllabus()
    {
        return $this->belongsTo(Syllabus::class);
    }

    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class, 'session_id');
    }

    // ── Accessors ──────────────────────────────────────────────

    public function getTeacherNameAttribute()
    {
        return $this->teacher?->name;
    }

    // ── Scopes ─────────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Prepare a date for array / JSON serialization.
     */
    protected function serializeDate(\DateTimeInterface $date)
    {
        return $date->format('Y-m-d H:i:s');
    }
}
