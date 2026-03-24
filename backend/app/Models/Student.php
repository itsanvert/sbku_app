<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    protected $appends = ['name', 'email', 'avatar_url'];
    protected $fillable = [
        'user_id',
        'gender',
        'dob',
        'faculty_id',
        'major_id',
        'year',
        'shift',
        'generation',
        'profile_image_path',
    ];

    /**
     * Get the student's name from the associated user.
     */
    public function getNameAttribute()
    {
        return $this->user?->name;
    }

    /**
     * Get the student's email from the associated user.
     */
    public function getEmailAttribute()
    {
        return $this->user?->email;
    }

    /**
     * Get the full URL for the student's profile photo.
     */
    public function getAvatarUrlAttribute()
    {
        return $this->profile_image_path
            ? url('api/storage/' . $this->profile_image_path)
            : 'https://ui-avatars.com/api/?name=' . urlencode($this->name) . '&background=6366f1&color=ffffff';
    }
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
