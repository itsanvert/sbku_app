<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;

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
    public function getNameAttribute(): ?string
    {
        // If Firestore is active, return the value from attributes (loaded from Firestore)
        if (\App\Services\FirestoreService::isActive()) {
            return $this->attributes['name'] ?? ($this->attributes['user_name'] ?? null);
        }
        $user = $this->getRelationValue('user');
        return $user instanceof Model ? $user->name : ($this->user_name ?? null);
    }

    /**
     * Get the teacher's email from the associated user.
     */
    public function getEmailAttribute(): ?string
    {
        // If Firestore is active, return the value from attributes (loaded from Firestore)
        if (\App\Services\FirestoreService::isActive()) {
            return $this->attributes['email'] ?? ($this->attributes['user_email'] ?? null);
        }
        $user = $this->getRelationValue('user');
        return $user instanceof Model ? $user->email : ($this->user_email ?? null);
    }

    /**
     * Get the full URL for the teacher's profile photo.
     */
    public function getAvatarUrlAttribute(): string
    {
        $baseUrl = request()->getSchemeAndHttpHost() . '/api/storage/';
        $name = $this->name ?? 'T';
        return $this->profile_image_path
            ? $baseUrl . $this->profile_image_path
            : 'https://ui-avatars.com/api/?name=' . urlencode($name) . '&background=6366f1&color=ffffff';
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
