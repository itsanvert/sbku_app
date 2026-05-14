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
                'id'          => data_get($this->student, 'id'),
                'name'        => data_get($this->student, 'name'),
                'email'       => data_get($this->student, 'email'),
                'avatar_url'  => data_get($this->student, 'avatar_url'),
                'faculty'     => data_get($this->student, 'faculty.name') ?? data_get($this->student, 'faculty'),
                'major'       => data_get($this->student, 'major.name') ?? data_get($this->student, 'major'),
                'year'        => data_get($this->student, 'year'),
                'generation'  => data_get($this->student, 'generation'),
            ]),
            'created_at' => $this->created_at,
        ];
    }
}
