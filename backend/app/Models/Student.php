<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'full_name',
        'date_of_birth',
        'gender',
        'address',
        'phone',
        'email',
        'user_id',
        'class_id',
    ];



    protected $casts = [
        'date_of_birth' => 'date',
    ];


    public function user()
    {
        return $this->belongsTo(User::class);
    }


    public function class()
    {
        return $this->belongsTo(ClassModel::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    public function locations()
    {
        return $this->hasMany(Location::class);
    }

    public function todayAttendance()
    {
        return $this->attendances()->whereDate('attendance_date', today())->latest()->first();
    }

    public function AttendancePercentage()
    {
        $total = $this->attendances()->count();
        $present = $this->attendances()->where('status', 'present')->count();
        return $total > 0 ? round(($present / $total) * 100, 2) : 0;
    }
}
