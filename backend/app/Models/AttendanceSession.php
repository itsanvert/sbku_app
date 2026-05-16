<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use App\Traits\SyncsToFirestore;

class AttendanceSession extends Model
{
    protected $fillable = [
        'teacher_id',
        'faculty_id',
        'major_id',
        'schedule_id',
        'syllabus_id',
        'subject_id',
        'year_id',
        'semester_id',
        'academic_class_id',
        'shift_id',
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
        'room_id',
    ];

    protected $casts = [
        'teacher_id'         => 'integer',
        'faculty_id'         => 'integer',
        'major_id'           => 'integer',
        'schedule_id'        => 'integer',
        'syllabus_id'        => 'integer',
        'subject_id'         => 'integer',
        'academic_class_id'  => 'integer',
        'shift_id'           => 'integer',
        'started_at'         => 'datetime',
        'ended_at'           => 'datetime',
        'expires_at'         => 'datetime',
        'is_active'          => 'boolean',
        'latitude'           => 'decimal:7',
        'longitude'          => 'decimal:7',
        'time_limit_minutes' => 'integer',
        'semester_id'        => 'integer',
        'room_id'            => 'integer',
    ];

    protected $appends = ['teacher_name', 'scheduled_time_range', 'room_name', 'attendances_count'];

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

    public function academicClass()
    {
        return $this->belongsTo(AcademicClass::class);
    }

    public function shift()
    {
        return $this->belongsTo(Shift::class);
    }

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class, 'session_id');
    }

    // ── Accessors ──────────────────────────────────────────────

    public function getTeacherNameAttribute()
    {
        return $this->teacher?->user?->name;
    }

    public function getRoomNameAttribute()
    {
        return $this->room?->name ?: ($this->schedule?->room?->name ?? '—');
    }

    public function getScheduledTimeRangeAttribute()
    {
        if ($this->schedule) {
            $start = $this->schedule->start_time;
            $end = $this->schedule->end_time;
            
            // If they are strings (H:i:s), trim to H:i
            if (is_string($start)) $start = substr($start, 0, 5);
            if (is_string($end)) $end = substr($end, 0, 5);
            
            return "{$start} - {$end}";
        }

        if ($this->syllabus) {
            return "{$this->syllabus->start_time} - {$this->syllabus->end_time}";
        }
        
        if ($this->session_start_time && $this->session_end_time) {
            return "{$this->session_start_time} - {$this->session_end_time}";
        }
        
        return '—';
    }

    public function getScheduledDayTimeAttribute()
    {
        $day = $this->day_of_week ?: ($this->schedule?->day_of_the_week ?? ($this->syllabus?->day_of_week ?? '—'));
        return ucfirst($day) . ' (' . $this->scheduled_time_range . ')';
    }

    public function getAttendancesCountAttribute()
    {
        // If Firestore is active, return the value from the model attributes (loaded from Firestore)
        if (\App\Services\FirestoreService::isActive()) {
            return $this->attributes['attendances_count'] ?? 0;
        }
        return $this->attendances()->count();
    }

    /**
     * Override the sync data to ensure relationships needed by the Flutter app
     * are present in the Firestore document.
     */
    public function toFirestoreArray()
    {
        // Load relationships if not already present
        if (!$this->relationLoaded('teacher')) $this->load('teacher.user');
        if (!$this->relationLoaded('faculty')) $this->load('faculty');
        if (!$this->relationLoaded('major')) $this->load('major');
        if (!$this->relationLoaded('schedule')) $this->load('schedule');
        if (!$this->relationLoaded('room')) $this->load('room');

        $data = $this->toArray();
        
        // Ensure count is explicitly set (in case it wasn't in toArray)
        $data['attendances_count'] = $this->attendances_count;
        
        return $data;
    }

    // ── Scopes ─────────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            });
    }

    /**
     * Prepare a date for array / JSON serialization.
     */
    protected function serializeDate(\DateTimeInterface $date)
    {
        return $date->format('Y-m-d H:i:s');
    }
}
