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
    // relationship model the teacher to users
    public function student()
    {
        return $this->hasOne((Student::class));
    }

    public function teacher()
    {
        return $this->hasOne((Teacher::class));
    }

    public function staff()
    {
        return $this->hasOne((Staff::class));
    }


    public function roles()
    {
        return $this->belongsToMany(Role::class, 'user_role');
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    // check if user has specific role
    public function hasRole($roleName)
    {
        return $this->roles()->where('name', '$roleName')->exists();
    }

    public function hasPermission($permissionName)
    {
        return $this->roles()->whereHas('permissions', function ($query) use ($permissionName) {
            $query->where('name', $permissionName);
        })->exists();
    }

    //assign role to user

    public function assignRole($roleName)
    {
        $role = Role::where('name', $roleName)->firstOrFail();
        $this->roles()->syncWithoutDetaching([$role->id]);
        return $this;
    }

    //check if user which role 

    public function isAdmin()
    {
        return $this->user_type === 'admin' || $this->hasRole('admin');
    }

    public function isStudent()
    {
        return $this->user_type === 'student';
    }
    public function isTeacher()
    {
        return $this->user_type === 'teacher';
    }

    public function isStaff()
    {
        return $this->user_type === 'staff';
    }

}
