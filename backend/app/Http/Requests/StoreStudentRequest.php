<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Validates input for creating a new student.
 *
 * Extracts validation from StudentController::store() so the
 * controller only deals with orchestration, not validation rules.
 */
class StoreStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // TODO: Replace with Policy check
    }

    public function rules(): array
    {
        return [
            'name'       => 'required|string|max:255',
            'email'      => 'required|email|unique:users,email',
            'password'   => 'required|min:8',
            'gender'     => 'required|in:male,female',
            'dob'        => 'nullable|date',
            'faculty_id' => 'required|exists:faculties,id',
            'major_id'   => 'required|exists:majors,id',
            'year'       => 'required|integer',
            'shift'      => 'required|string',
            'generation' => 'required|string',
            'photo'      => 'nullable|image|max:1024',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required'       => 'Student name is required.',
            'email.required'      => 'Email address is required.',
            'email.unique'        => 'This email is already registered.',
            'faculty_id.exists'   => 'Selected faculty does not exist.',
            'major_id.exists'     => 'Selected major does not exist.',
        ];
    }
}
