<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Syllabus;
use Illuminate\Http\JsonResponse;

class SyllabusController extends Controller
{
    /**
     * Display a listing of the syllabus records.
     */
    public function index(): JsonResponse
    {
        $syllabuses = Syllabus::with(['faculty', 'major', 'subject', 'teacher.user', 'shift'])->get();

        $data = $syllabuses->map(function ($s) {
            return [
                'id' => (string)$s->id,
                'faculty_id' => (string)$s->faculty_id,
                'faculty_name' => $s->faculty->name ?? 'Unknown',
                'major_id' => (string)$s->major_id,
                'major_name' => $s->major->name ?? 'Unknown',
                'subject_id' => (string)$s->subject_id,
                'subject_name' => $s->subject->name ?? 'Unknown',
                'teacher_id' => (string)$s->teacher_id,
                'teacher_name' => $s->teacher->user->name ?? 'Unknown',
                'shift_id' => (string)$s->shift_id,
                'shift_name' => $s->shift->name ?? 'Unknown',
                'year_id' => $s->year_id,
                'semester_id' => (string)$s->semester_id,
                'semester_name' => 'Semester ' . $s->semester_id,
                'year_name' => 'ឆ្នាំទី ' . substr($s->year_id, 1), // Converts Y1 to Year 1 in Khmer local format if needed
                'credit_hours' => (string)($s->subject->credit_hours ?? 3),
                'schedule_description' => $s->schedule_description ?? 'TBD',
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
