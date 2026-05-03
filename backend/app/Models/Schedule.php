<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;

class Schedule extends Model
{
    use SyncsToFirestore;

    protected $fillable = [
        'name',
        'day_of_the_week',
        'start_time',
        'end_time',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time'   => 'datetime',
    ];

    public function getFullDisplayAttribute()
    {
        $display = $this->name;
        if ($this->day_of_the_week) {
            $display .= " ({$this->day_of_the_week}";
            if ($this->start_time && $this->end_time) {
                $display .= ": " . $this->start_time->format('H:i') . "-" . $this->end_time->format('H:i');
            }
            $display .= ")";
        }
        return $display;
    }
}
