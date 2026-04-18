<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Transforms a Student model into a consistent JSON shape.
 *
 * Includes the related user, faculty, and major data.
 */
class StudentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                 => $this->id,
            'user_id'            => $this->user_id,
            'name'               => $this->name,
            'email'              => $this->email,
            'gender'             => $this->gender,
            'dob'                => $this->dob,
            'year'               => $this->year,
            'shift'              => $this->shift?->name ?? $this->shift_id,
            'generation'         => $this->generation,
            'avatar_url'         => $this->avatar_url,
            'profile_image_path' => $this->profile_image_path,
            'faculty' => $this->whenLoaded('faculty', fn() => [
                'id'   => $this->faculty->id,
                'name' => $this->faculty->name,
            ]),
            'major' => $this->whenLoaded('major', fn() => [
                'id'   => $this->major->id,
                'name' => $this->major->name,
            ]),
            'user' => $this->whenLoaded('user', fn() => [
                'id'    => $this->user->id,
                'name'  => $this->user->name,
                'email' => $this->user->email,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
