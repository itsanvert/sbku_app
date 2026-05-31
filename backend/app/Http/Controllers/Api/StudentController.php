<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreStudentRequest;
use App\Http\Requests\UpdateStudentRequest;
use App\Models\Student;
use App\Services\StudentService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

/**
 * Thin API controller for student CRUD.
 *
 * Business logic lives in StudentService.
 * Validation lives in Form Requests.
 *
 * NOTE: Responses maintain the ORIGINAL flat format for backward
 * compatibility with the existing Flutter StudentService/StudentPaginated.
 */
class StudentController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly StudentService $studentService,
    ) {}

    public function index(Request $request)
    {
        $sortBy = in_array($request->sort_by, ['id', 'user_id', 'faculty_id', 'major_id', 'year', 'generation', 'created_at'], true)
            ? $request->sort_by
            : 'id';
        $sortDir = $request->sort_dir === 'desc' ? 'desc' : 'asc';
        $perPage = min(max((int) $request->per_page ?: 10, 1), 100);

        $students = Student::select('students.*')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->with([
                'user' => fn ($q) => $q->select('id', 'name', 'email'),
                'major' => fn ($q) => $q->select('id', 'name'),
                'faculty' => fn ($q) => $q->select('id', 'name'),
                'academicClass' => fn ($q) => $q->select('id', 'name'),
            ])
            ->when($request->search, function ($q) use ($request) {
                $q->where(function ($query) use ($request) {
                    $query->where('users.name', 'like', '%'.$request->search.'%')
                          ->orWhere('users.email', 'like', '%'.$request->search.'%');
                });
            })
            ->orderBy($sortBy === 'id' ? 'students.id' : 'students.'.$sortBy, $sortDir)
            ->paginate($perPage);

        return response()->json($students);
    }

    public function store(StoreStudentRequest $request)
    {
        $student = $this->studentService->create(
            $request->validated(),
            $request->file('photo'),
        );

        // Flutter expects the raw student model JSON on 201
        return response()->json($student, 201);
    }

    public function show(Request $request, $id)
    {
        $student = Student::findOrFail($id);
        return response()->json(
            $student->load(['user', 'major', 'faculty', 'academicClass'])
        );
    }

    public function update(UpdateStudentRequest $request, $id)
    {
        $student = Student::findOrFail($id);
        $student = $this->studentService->update(
            $student,
            $request->validated(),
            $request->file('photo'),
        );

        return response()->json($student);
    }

    public function destroy(Request $request, $id)
    {
        $student = Student::findOrFail($id);
        $this->studentService->delete($student);

        return response()->json(['message' => 'Student deleted']);
    }
}
