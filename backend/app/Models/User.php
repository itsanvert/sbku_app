<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Fortify\TwoFactorAuthenticatable;
use Laravel\Jetstream\HasProfilePhoto;
use Laravel\Sanctum\HasApiTokens;
use App\Models\Teacher;
use App\Models\Student;

class User extends Authenticatable
{
    use HasApiTokens;

    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory;
    use HasProfilePhoto;
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
        'fcm_token',
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
        'profile_image_path',
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
        $baseUrl = rtrim(config('app.url', request()->getSchemeAndHttpHost()), '/') . '/api/storage/';

        if ($this->profile_photo_path) {
            return $baseUrl . $this->profile_photo_path;
        }

        if ($this->relationLoaded('teacher')) {
            $teacherPath = data_get($this->teacher, 'profile_image_path');
            if ($teacherPath) {
                return $baseUrl . $teacherPath;
            }
        }

        if ($this->relationLoaded('student')) {
            $studentPath = data_get($this->student, 'profile_image_path');
            if ($studentPath) {
                return $baseUrl . $studentPath;
            }
        }

        return $this->defaultProfilePhotoUrl();
    }

    public function getProfileImagePathAttribute(): ?string
    {
        if ($this->relationLoaded('teacher')) {
            $teacherPath = data_get($this->teacher, 'profile_image_path');
            if ($teacherPath) {
                return $teacherPath;
            }
        }

        if ($this->relationLoaded('student')) {
            $studentPath = data_get($this->student, 'profile_image_path');
            if ($studentPath) {
                return $studentPath;
            }
        }

        return $this->profile_photo_path;
    }

    /**
     * Check if user is Super Admin.
     */
    public function isSuperAdmin(): bool
    {
        return $this->role === 'super_admin';
    }


    /**
     * Check if user is an Administrator (Super Admin or Admin).
     */
    public function isAdmin(): bool
    {
        return in_array($this->role, ['super_admin', 'admin']);
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

        static::saved(function (User $user) {
            if ($user->isDirty('profile_photo_path')) {
                $path = $user->profile_photo_path;
                if ($user->role === 'teacher' && $user->teacher) {
                    $user->teacher->update(['profile_image_path' => $path]);
                } elseif ($user->role === 'student' && $user->student) {
                    $user->student->update(['profile_image_path' => $path]);
                }
            }
        });
    }

    /**
     * The teacher profile associated with the user.
     */
    public function teacher()
    {
        return $this->hasOne(Teacher::class);
    }

    /**
     * The student profile associated with the user.
     */
    public function student()
    {
        return $this->hasOne(Student::class);
    }

    /**
     * Get the teacher profile.
     */
    public function getTeacherAttribute()
    {
        return $this->getRelationValue('teacher');
    }

    /**
     * Get the student profile.
     */
    public function getStudentAttribute()
    {
        return $this->getRelationValue('student');
    }
}
