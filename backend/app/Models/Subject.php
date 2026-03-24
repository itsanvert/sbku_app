<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    use HasFactory;

    protected $fillable = [
        'subject_name',
        'credits',
        'semester',
        'major_id',
    ];


    public function major()
    {
        return $this->belongsTo(Major::class);
    }

    public function teachers()
    {
        return $this->belongsToMany(Teacher::class, 'teacher_subject');
    }

    public function classes()
    {
        return $this->belongsToMany(ClassModel::class, 'subject_class');
    }

    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }

    public function syllabus()
    {
        return $this->hasOne(Syllabus::class);
    }

}
