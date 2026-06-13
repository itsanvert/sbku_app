<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Syllabus;

use Illuminate\Http\JsonResponse;

class SyllabusController extends Controller
{
    public function __construct(
    ) {}

    /**
     * Display a listing of the syllabus records.
     */
    public function index(): JsonResponse
    {
        $syllabuses = Syllabus::with(['faculty', 'major', 'subject', 'teacher.user', 'shift'])->get();
        $data = $syllabuses->map(fn (Syllabus $s) => $this->formatSyllabusRow($s->toArray(), $s));

        return response()->json([
            'success' => true,
            'data'    => $data,
        ]);
    }

    private function formatSyllabusRow(array $s, ?Syllabus $model = null): array
    {
        $yearId = $s['year_id'] ?? null;

        return [
            'id'                   => (string) ($s['id'] ?? ''),
            'faculty_id'           => (string) ($s['faculty_id'] ?? ''),
            'faculty_name'         => $s['faculty_name'] ?? $model?->faculty?->name,
            'major_id'             => (string) ($s['major_id'] ?? ''),
            'major_name'           => $s['major_name'] ?? $model?->major?->name,
            'subject_id'           => (string) ($s['subject_id'] ?? ''),
            'subject_name'         => $s['subject_name'] ?? $model?->subject?->name,
            'teacher_id'           => (string) ($s['teacher_id'] ?? ''),
            'teacher_name'         => $s['teacher_name']
                ?? $model?->teacher?->user?->name
                ?? $s['teacher_user_name'],
            'shift_id'             => (string) ($s['shift_id'] ?? ''),
            'shift_name'           => $s['shift_name'] ?? $model?->shift?->name,
            'year_id'              => $yearId,
            'semester_id'          => (string) ($s['semester_id'] ?? ''),
            'semester_name'        => $s['semester_name'] ?? ('Semester ' . ($s['semester_id'] ?? '')),
            'year_name'            => $s['year_name'] ?? ($yearId ? 'ឆ្នាំទី ' . substr((string) $yearId, 1) : null),
            'credit_hours'         => (string) ($s['credit_hours'] ?? $model?->subject?->credit_hours ?? 3),
            'schedule_description' => $s['schedule_description'] ?? 'TBD',
        ];
    }
}
