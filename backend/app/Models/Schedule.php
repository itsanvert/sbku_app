<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{

    use HasFactory;

    protected $fillable = [
        'day_of_the_week',
        'start_time',
        'end_time',
        'start_date',
        'end_date',
        'class_id',
        'teacher_id',
        'subject_id',
        'room_id',
    ];


    protected $casts = [
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
        'start_date' => 'date',
        'end_date' => 'date',
    ];


    public function class()
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }


    public function teacher()
    {
        return $this->belongsTo(Teacher::class, 'teacher_id');
    }

    public function subject()
    {
        return $this->belongsTo(Subject::class, 'subject_id');
    }

    public function room()
    {
        return $this->belongsTo(Room::class, 'room_id');
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }
}
