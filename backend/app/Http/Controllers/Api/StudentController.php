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
        private readonly \App\Services\FirestoreService $firestore,
    ) {}

    public function index(Request $request)
    {
        if (config('app.env') === 'production' || $request->has('firestore')) {
            $filters = [];
            if ($request->search) {
                // Firestore doesn't support 'like' easily, so we might just filter in memory
                // for small lists or use a prefix search if implemented.
                // For now, let's just fetch all or filter by simple equality if possible.
            }

            $students = $this->firestore->list('students', $filters);

            return response()->json([
                'data'         => $students,
                'current_page' => 1,
                'last_page'    => 1,
                'total'        => count($students),
                'per_page'     => count($students),
            ]);
        }

        $students = Student::query()
            ->with(['user', 'major', 'faculty', 'academicClass'])
            ->whereHas('user', function($q) use ($request) {
                $q->when($request->search, function($query) use ($request) {
                    $query->where('name', 'like', '%'.$request->search.'%')
                          ->orWhere('email', 'like', '%'.$request->search.'%');
                });
            })
            ->orderBy($request->sort_by ?? 'id', $request->sort_dir ?? 'asc')
            ->paginate($request->per_page ?? 10);

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

    public function show(Student $student)
    {
        return response()->json(
            $student->load(['user', 'major', 'faculty', 'academicClass'])
        );
    }

    public function update(UpdateStudentRequest $request, Student $student)
    {
        $student = $this->studentService->update(
            $student,
            $request->validated(),
            $request->file('photo'),
        );

        return response()->json($student);
    }

    public function destroy(Student $student)
    {
        $this->studentService->delete($student);

        return response()->json(['message' => 'Student deleted']);
    }
}
