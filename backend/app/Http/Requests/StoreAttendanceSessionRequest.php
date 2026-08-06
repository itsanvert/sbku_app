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
            'teacher_id'        => 'required|exists:teachers,id',
            'faculty_id'        => 'nullable|exists:faculties,id',
            'major_id'          => 'nullable|exists:majors,id',
            'schedule_id'       => 'nullable|exists:schedules,id',
            'syllabus_id'       => 'nullable|exists:syllabi,id',
            'subject_id'        => 'nullable|exists:subjects,id',
            'academic_class_id' => 'nullable|exists:academic_classes,id',
            'shift_id'          => 'nullable|exists:shifts,id',
            'year_id'           => 'nullable',
            'semester_id'       => 'nullable',
            'day_of_week'       => 'nullable|string|max:20',
            'start_time'        => 'nullable|string|max:5',
            'end_time'          => 'nullable|string|max:5',
            'latitude'          => 'nullable|numeric',
            'longitude'         => 'nullable|numeric',
            'radius'            => 'nullable|numeric|min:1|max:10000',
        ];
    }
}
