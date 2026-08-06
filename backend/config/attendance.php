<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Check-in Radius
    |--------------------------------------------------------------------------
    |
    | Default geofence radius (in meters) used when an attendance session
    | does not specify its own radius. Students must be within this distance
    | of the session's location to check in via QR.
    |
    */

    'default_radius' => env('ATTENDANCE_RADIUS_METERS', 100),

];
