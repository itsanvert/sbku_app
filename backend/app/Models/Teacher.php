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
    'user_id',
    'name',
    'gender',
    'major_id',
    'year',
    'role',
    'schedule_id',
    'phone',
    'faculty_id',
];
public function user()
{
    return $this->belongsTo(User::class);
}
public function faculty()
{
    return $this->belongsTo(Faculty::class);
}
public function major()
{
    return $this->belongsTo(Major::class);
}
public function schedule()
{
    return $this->belongsTo(Schedule::class);
}

}
