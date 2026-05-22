<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;

class Major extends Model
{
    protected $fillable = [
        'faculty_id',
        'name',
    ];

    public function faculty()
    {
        return $this->belongsTo(Faculty::class);
    }

    public function academicClasses()
    {
        return $this->hasMany(AcademicClass::class);
    }
}
