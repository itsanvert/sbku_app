<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Location extends Model
{
    use HasFactory;

    protected $fillable = [
        'latitude',
        'longitude',
        'record_at',
        'accuracy_meter',
        'student_id',
    ];

    protected $casts = [
        'record_at' => 'datetime',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'accuracy_meter' => 'decimal:2',
    ];


    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public static function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // meters

        $lat1 = deg2rad($lat1);
        $lon1 = deg2rad($lon1);
        $lat2 = deg2rad($lat2);
        $lon2 = deg2rad($lon2);

        $dLat = $lat2 - $lat1;
        $dLon = $lon2 - $lon1;

        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos($lat1) * cos($lat2) *
            sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }

    public function isWithinRange($targetLat, $targetLon, $maxDistance = 50)
    {
        $distance = self::calculateDistance(
            $this->latitude,
            $this->longitude,
            $targetLat,
            $targetLon
        );

        return $distance <= $maxDistance;
    }
}
