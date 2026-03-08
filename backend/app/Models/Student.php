<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
     protected $fillable = [
    'user_id',
    'name',
    'gender',
    'dob',
    'faculty_id',
    'major_id',
    'year', 
    'shift',
    'generation',
    'email',
    'profileImagePath',

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
