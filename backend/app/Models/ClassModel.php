<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ClassModel extends Model
{
    use HasFactory;

    protected $fillable = [
        'class_name',
        'class_code',
        'major_id',
        'academic_year',
        'semester',
    ];

    public function major()
    {
        return $this->belongsTo(Major::class);

    }

    public function students()
    {
        return $this->hasMany(Student::class);
    }

    public function subjects()
    {
        return $this->belongsToMany(Subject::class, 'subject_class');
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
