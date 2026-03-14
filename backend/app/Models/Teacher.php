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

    protected $appends = ['name', 'email', 'avatar_url'];

    protected $fillable = [
        'user_id',
        'gender',
        'major_id',
        'year',
        'schedule_id',
        'shift_id',
        'phone',
        'faculty_id',
        'profile_image_path',
    ];

    /**
     * Get the teacher's name from the associated user.
     */
    public function getNameAttribute()
    {
        return $this->user?->name;
    }

    /**
     * Get the teacher's email from the associated user.
     */
    public function getEmailAttribute()
    {
        return $this->user?->email;
    }

    /**
     * Get the full URL for the teacher's profile photo.
     */
    public function getAvatarUrlAttribute()
    {
        return $this->profile_image_path 
            ? url('storage/' . $this->profile_image_path)
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
public function shift()
{
    return $this->belongsTo(Shift::class);

}
}
