<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'attendance_date',
        'check_in',
        'check_out',
        'status',
        'noted',
        'student_id',
        'schedule_id',
    ];

    protected $casts = [
        'attendance_date' => 'date',
        'check_in' => 'datetime:H:i',
        'check_out' => 'datetime:H:i',
    ];


    public function student()
    {
        return $this->belongsTo(Student::class);
    }
    public function schedule()
    {
        return $this->belongsTo(Schedule::class);
    }
    public function scopePresent($query)
    {
        return $query->where('status', 'present');
    }
    public function scopeAbsent($query)
    {
        return $query->where('status', 'absent');
    }
    public function scopeToday()
    {
        return $this->whereDate('attendance_date', today());
    }
}
