<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Syllabus extends Model
{
    use HasFactory;

    protected $fillable = [
        'class_id',
        'teacher_id',
        'subject_id',


    ];


    public function class()
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }

    public function teacher()
    {
        return $this->belongTo(Teacher::class);
    }

    public function subject()
    {
        return $this->belongTo(Subject::class);
    }
}