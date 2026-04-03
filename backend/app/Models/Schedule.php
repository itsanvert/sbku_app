<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{

    protected $fillable = [
        'day_of_the_week',
        'start_time',
        'end_time',

    ];
    // app/Models/Schedule.php

protected $casts = [
    'start_time' => 'datetime',
    'end_time'   => 'datetime',
];
}
