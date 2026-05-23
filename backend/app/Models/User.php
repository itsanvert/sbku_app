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

        // 1. Check if user has a direct photo path (Jetstream standard)
        if ($this->profile_photo_path) {
            return $baseUrl . $this->profile_photo_path;
        }

        // 2. Fall back to Teacher profile image (handles both Model and Firestore array)
        $teacher = $this->teacher;
        $teacherPath = data_get($teacher, 'profile_image_path');
        if ($teacherPath) {
            return $baseUrl . $teacherPath;
        }

        // 3. Fall back to Student profile image (handles both Model and Firestore array)
        $student = $this->student;
        $studentPath = data_get($student, 'profile_image_path');
        if ($studentPath) {
            return $baseUrl . $studentPath;
        }

        // 4. Default ui-avatars
        return $this->defaultProfilePhotoUrl();
    }
    /**
     * Get the profile image path from teacher/student, falling back to
     * the user's own profile_photo_path.
     */
    public function getProfileImagePathAttribute(): ?string
    {
        // 1. Check Teacher profile_image_path
        $teacher = $this->teacher;
        $teacherPath = data_get($teacher, 'profile_image_path');
        if ($teacherPath) {
            return $teacherPath;
        }

        // 2. Check Student profile_image_path
        $student = $this->student;
        $studentPath = data_get($student, 'profile_image_path');
        if ($studentPath) {
            return $studentPath;
        }

        // 3. Fall back to the user's own profile_photo_path
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
