<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class AttendanceSession extends Model
{
    protected $fillable = [
        'teacher_id',
        'faculty_id',
        'major_id',
        'schedule_id',
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
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
        'expires_at' => 'datetime',
        'is_active' => 'boolean',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
        'time_limit_minutes' => 'integer',
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
}
