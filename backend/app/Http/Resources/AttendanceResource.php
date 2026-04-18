<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Transforms an Attendance model into a consistent JSON shape.
 */
class AttendanceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                   => $this->id,
            'attendance_date'      => $this->attendance_date,
            'check_in_time'        => $this->check_in_time?->format('H:i:s'),
            'status'               => $this->status,
            'verify_status'        => $this->verify_status,
            'reject_reason'        => $this->reject_reason,
            'verified_at'          => $this->verified_at?->format('Y-m-d H:i:s'),
            'permission_reason'    => $this->permission_reason,
            'permission_image_url' => $this->permission_image_url,
            'student_id'           => $this->student_id,
            'session_id'           => $this->session_id,
            'schedule_id'          => $this->schedule_id,
            'student' => $this->whenLoaded('student', fn() => [
                'id'          => $this->student->id,
                'name'        => $this->student->name,
                'email'       => $this->student->email,
                'avatar_url'  => $this->student->avatar_url,
                'faculty'     => $this->student->faculty?->name,
                'major'       => $this->student->major?->name,
                'year'        => $this->student->year,
                'generation'  => $this->student->generation,
            ]),
            'created_at' => $this->created_at,
        ];
    }
}
