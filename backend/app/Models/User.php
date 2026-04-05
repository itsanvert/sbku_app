<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Fortify\TwoFactorAuthenticatable;
use Laravel\Jetstream\HasProfilePhoto;
use Laravel\Jetstream\HasTeams;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory;
    use HasProfilePhoto;
    use HasTeams;
    use Notifiable;
    use TwoFactorAuthenticatable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'two_factor_recovery_codes',
        'two_factor_secret',
    ];

    /**
     * The accessors to append to the model's array form.
     *
     * @var array<int, string>
     */
    protected $appends = [
        'profile_photo_url',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Get the URL to the user's profile photo.
     * Overridden to fall back to teacher/student profile if exists.
     *
     * @return string
     */
    public function getProfilePhotoUrlAttribute()
    {
        // 1. Check if user has a direct photo path (Jetstream standard)
        if ($this->profile_photo_path) {
            return url('api/storage/' . $this->profile_photo_path);
        }

        // 2. Fall back to Teacher profile image
        if ($this->teacher && $this->teacher->profile_image_path) {
            return url('api/storage/' . $this->teacher->profile_image_path);
        }

        // 3. Fall back to Student profile image
        if ($this->student && $this->student->profile_image_path) {
            return url('api/storage/' . $this->student->profile_image_path);
        }

        // 4. Default ui-avatars
        return $this->defaultProfilePhotoUrl();
    }
    /**
     * The "booted" method of the model.
     */
    protected static function booted(): void
    {
        static::created(function (User $user) {
            if ($user->role === 'teacher') {
                $user->teacher()->create();
            } elseif ($user->role === 'student') {
                $user->student()->create();
            }
        });
    }

    // relationship model the teacher to users
    public function teacher()
    {
        return $this->hasOne(Teacher::class);
    }

    // relationship model the student to users
    public function student()
    {
        return $this->hasOne(Student::class);
    }
}
