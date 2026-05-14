<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Fortify\TwoFactorAuthenticatable;
use Laravel\Jetstream\HasProfilePhoto;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory;
    use HasProfilePhoto;
    use Notifiable;
    use TwoFactorAuthenticatable;
    use \App\Traits\SyncsToFirestore;

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
        $baseUrl = request()->getSchemeAndHttpHost() . '/api/storage/';

        // 1. Check if user has a direct photo path (Jetstream standard)
        if ($this->profile_photo_path) {
            return $baseUrl . $this->profile_photo_path;
        }

        // 2. Fall back to Teacher profile image (handles both Model and Firestore array)
        $teacher = $this->teacher;
        $teacherPath = is_array($teacher) ? ($teacher['profile_image_path'] ?? null) : ($teacher->profile_image_path ?? null);
        if ($teacherPath) {
            return $baseUrl . $teacherPath;
        }

        // 3. Fall back to Student profile image (handles both Model and Firestore array)
        $student = $this->student;
        $studentPath = is_array($student) ? ($student['profile_image_path'] ?? null) : ($student->profile_image_path ?? null);
        if ($studentPath) {
            return $baseUrl . $studentPath;
        }

        // 4. Default ui-avatars
        return $this->defaultProfilePhotoUrl();
    }
    /**
     * Check if user is Super Admin.
     */
    public function isSuperAdmin(): bool
    {
        return $this->role === 'super_admin';
    }

    /**
     * Mock method to satisfy Jetstream templates after disabling Teams.
     */
    public function hasTeamPermission($team, string $permission): bool
    {
        return true;
    }

    public function currentTeam()
    {
        return null;
    }

    public function allTeams()
    {
        return collect([]);
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
     * Get the teacher profile from Firestore.
     */
    public function getTeacherAttribute()
    {
        // Cache the result for the duration of the request
        return $this->attributes['teacher_profile'] ??= app(\App\Services\FirestoreService::class)
            ->list('teachers', ['user_id' => (int)$this->id])[0] ?? null;
    }

    /**
     * Get the student profile from Firestore.
     */
    public function getStudentAttribute()
    {
        // Cache the result for the duration of the request
        return $this->attributes['student_profile'] ??= app(\App\Services\FirestoreService::class)
            ->list('students', ['user_id' => (int)$this->id])[0] ?? null;
    }

    // Traditional relationships commented out to prevent SQL queries
    // public function teacher() { return $this->hasOne(Teacher::class); }
    // public function student() { return $this->hasOne(Student::class); }
}
