<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    protected $fillable = [
        'attendance_date',
        'check_in_time',
        'check_out_time',
        'status',
        'noted',
        'schedule_id',
        'student_id',
        'session_id',
        'verify_status',
        'reject_reason',
        'verified_at',
        'permission_reason',
        'permission_image',
    ];

    protected $casts = [
        'attendance_date' => 'date',
        'check_in_time'   => 'datetime',
        'check_out_time'  => 'datetime',
        'verified_at'     => 'datetime',
    ];

    protected $appends = ['student_name', 'permission_image_url'];

    // ── Relationships ──────────────────────────────────────────
    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function schedule()
    {
        return $this->belongsTo(Schedule::class);
    }

    public function session()
    {
        return $this->belongsTo(AttendanceSession::class, 'session_id');
    }

    // ── Accessors ──────────────────────────────────────────────
    public function getStudentNameAttribute()
    {
        return $this->student?->name;
    }

    // ── Scopes ─────────────────────────────────────────────────
    public function scopeForDate($query, $date)
    {
        return $query->whereDate('attendance_date', $date);
    }

    public function scopeForMonth($query, $month, $year)
    {
        return $query->whereMonth('attendance_date', $month)
                     ->whereYear('attendance_date', $year);
    }

    public function scopeForYear($query, $year)
    {
        return $query->whereYear('attendance_date', $year);
    }

    public function scopeForStudent($query, $studentId)
    {
        return $query->where('student_id', $studentId);
    }

    public function scopePresent($query)
    {
        return $query->where('status', 'Y');
    }

    public function scopeAbsent($query)
    {
        return $query->where('status', 'N');
    }

    public function scopePermission($query)
    {
        return $query->where('status', 'P');
    }

    public function scopePending($query)
    {
        return $query->where('verify_status', 'pending');
    }

    public function scopeApproved($query)
    {
        return $query->where('verify_status', 'approved');
    }

    public function scopeRejected($query)
    {
        return $query->where('verify_status', 'rejected');
    }

    // Helper: is the check-in fully verified?
    public function getIsVerifiedAttribute(): bool
    {
        return $this->verify_status === 'approved';
    }

    public function getPermissionImageUrlAttribute()
    {
        if ($this->permission_image) {
            // Check if it's already a full URL or just a path
            if (str_starts_with($this->permission_image, 'http')) {
                return $this->permission_image;
            }
            return asset('storage/' . $this->permission_image);
        }
        return null;
    }

    /**
     * Prepare a date for array / JSON serialization.
     */
    protected function serializeDate(\DateTimeInterface $date)
    {
        return $date->format('Y-m-d H:i:s');
    }
}
