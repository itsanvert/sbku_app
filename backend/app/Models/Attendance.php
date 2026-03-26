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
    ];

    protected $casts = [
        'attendance_date' => 'date',
        'check_in_time' => 'datetime',
        'check_out_time' => 'datetime',
    ];

    protected $appends = ['student_name'];

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
}
