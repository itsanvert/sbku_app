<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

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
        'shift_id',
        'schedule_id',
        'generation',
        'academic_class_id',
        'profile_image_path',
    ];

    // ── Accessors ──────────────────────────────────────────────

    /**
     * Get the student's name from the associated user.
     */
    public function getNameAttribute(): ?string
    {
        return $this->user?->name;
    }

    /**
     * Get the student's email from the associated user.
     */
    public function getEmailAttribute(): ?string
    {
        return $this->user?->email;
    }

    /**
     * Get the full URL for the student's profile photo.
     */
    public function getAvatarUrlAttribute(): string
    {
        $baseUrl = request()->getSchemeAndHttpHost() . '/api/storage/';

        return $this->profile_image_path
            ? $baseUrl . $this->profile_image_path
            : 'https://ui-avatars.com/api/?name=' . urlencode($this->name ?? 'S') . '&background=6366f1&color=ffffff';
    }

    // ── Relationships ──────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function faculty(): BelongsTo
    {
        return $this->belongsTo(Faculty::class);
    }

    public function major(): BelongsTo
    {
        return $this->belongsTo(Major::class);
    }

    public function schedule(): BelongsTo
    {
        return $this->belongsTo(Schedule::class);
    }

    public function shift(): BelongsTo
    {
        return $this->belongsTo(Shift::class);
    }

    public function academicClass(): BelongsTo
    {
        return $this->belongsTo(AcademicClass::class);
    }
}
