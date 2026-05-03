<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Validates input for updating an existing student.
 *
 * Uses 'sometimes' rules so PATCH-style partial updates work.
 * The unique email check excludes the current student's user.
 */
class UpdateStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // TODO: Replace with Policy check
    }

    public function rules(): array
    {
        $userId = $this->route('student')?->user_id;

        return [
            'name'       => 'sometimes|required|string|max:255',
            'email'      => 'sometimes|required|email|unique:users,email,' . $userId,
            'password'   => 'nullable|min:8',
            'gender'     => 'sometimes|required|in:male,female',
            'dob'        => 'nullable|date',
            'faculty_id' => 'sometimes|required|exists:faculties,id',
            'major_id'   => 'sometimes|required|exists:majors,id',
            'year'       => 'sometimes|required|integer',
            'shift'      => 'sometimes|required|string',
            'generation' => 'sometimes|required|string',
            'academic_class_id' => 'nullable|exists:academic_classes,id',
            'photo'      => 'nullable|image|max:1024',
        ];
    }
}
