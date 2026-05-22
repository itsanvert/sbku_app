<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;

class AcademicClass extends Model
{
    protected $fillable = [
        'name',
        'code',
        'major_id',
        'academic_year',
        'semester',
    ];

    public function major()
    {
        return $this->belongsTo(Major::class);
    }
}
