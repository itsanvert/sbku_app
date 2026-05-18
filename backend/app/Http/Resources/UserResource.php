<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Transforms a User model into a consistent JSON shape.
 *
 * Replaces the manually-built user arrays scattered across
 * AuthController, ProfileController, etc.
 *
 * Usage: `new UserResource($user)` or `UserResource::make($user)`
 */
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                 => $this->id,
            'name'               => $this->name,
            'email'              => $this->email,
            'email_verified_at'  => $this->email_verified_at,
            'profile_photo_path' => $this->profile_photo_path,
            'profile_image_path' => $this->profile_image_path,
            'two_factor_enabled' => $this->two_factor_secret !== null,
            'role'               => $this->role,
            'student_id'         => $this->student_id ?? data_get($this->student, 'id'),
            'teacher_id'         => $this->teacher_id ?? data_get($this->teacher, 'id'),
            'created_at'         => $this->created_at,
            'updated_at'         => $this->updated_at,
        ];
    }
}
