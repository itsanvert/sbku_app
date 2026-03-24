<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
    ];

    public function users()
    {
        return $this->belongsToMany(User::class, 'user_role');


    }

    public function permissions()
    {
        return $this->belongsToMany(Permission::class, 'role_permission');
    }

    public function givePermission($permissionName)
    {
        $permission = Permission::where('name', $permissionName)->firstOrFail();
        $this->permissions()->syncWithoutDetaching([$permission->id]);
        return $this;
    }
}
