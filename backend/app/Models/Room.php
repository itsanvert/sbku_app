<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    use HasFactory;

    protected $fillable = [
        'room_code',
        'room_name',
        'building',
    ];


    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }
}
