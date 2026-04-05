<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Syllabus extends Model
{
    protected $table = 'syllabuses';

    protected $fillable = [
        'faculty_id',
        'major_id',
        'subject_id',
        'teacher_id',
        'shift_id',
        'year_id',
        'semester_id',
        'schedule_description',
    ];

    public function faculty(): BelongsTo {
        return $this->belongsTo(Faculty::class);
    }

    public function major(): BelongsTo {
        return $this->belongsTo(Major::class);
    }

    public function subject(): BelongsTo {
        return $this->belongsTo(Subject::class);
    }

    public function teacher(): BelongsTo {
        return $this->belongsTo(Teacher::class);
    }

    public function shift(): BelongsTo {
        return $this->belongsTo(Shift::class);
    }
}
