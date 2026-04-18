<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Validates attendance session creation input.
 */
class StoreAttendanceSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // TODO: Replace with Policy — only teachers should create sessions
    }

    public function rules(): array
    {
        return [
            'teacher_id'  => 'required|exists:teachers,id',
            'faculty_id'  => 'nullable|exists:faculties,id',
            'major_id'    => 'nullable|exists:majors,id',
            'schedule_id' => 'nullable|exists:schedules,id',
            'latitude'    => 'nullable|numeric',
            'longitude'   => 'nullable|numeric',
        ];
    }
}
