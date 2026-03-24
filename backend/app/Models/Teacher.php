<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Teacher extends Model
{
    /**
     * Default attribute values.
     */
    protected $attributes = [
        'role' => 'teacher',
    ];

    protected $fillable = [
        'teacher_id',
        'full_name',
        'specialization',
        'phone',
        'email',
        'user_id',
        'faculty_id',
    ];




    public function faculty()
    {
        return $this->belongsTo(Faculty::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function subjects()
    {
        return $this->belongsToMany(Subject::class, 'teacher_subject');
    }

    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }

    public function syllabus()
    {
        return $this->hasMany(Syllabus::class);
    }

}
