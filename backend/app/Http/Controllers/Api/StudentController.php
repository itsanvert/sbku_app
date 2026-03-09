<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\Request;

class StudentController extends Controller
{
    public function index(Request $request)
    {
        $students = Student::query()
            ->select('students.*')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->with(['user', 'major', 'faculty', 'schedule'])
            ->when($request->search, fn($q) =>
                $q->where(  'students.name', 'like', '%'.$request->search.'%')  
                  ->orWhere('users.email', 'like', '%'.$request->search.'%')
            )
            ->orderBy($request->sort_by ?? 'students.id', $request->sort_dir ?? 'asc')
            ->paginate($request->per_page ?? 10);

        return response()->json($students); 
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'        => 'required|string|max:255',
            'email'       => 'required|email|unique:users,email',
            'phone'       => 'nullable|string',
            'year'        => 'nullable|integer',
            'major_id'    => 'nullable|exists:majors,id',
            'faculty_id'  => 'nullable|exists:faculties,id',
            'schedule_id' => 'nullable|exists:schedules,id',
        ]);

        // Create user + student as needed
        // ...

        return response()->json(['message' => 'Student created'], 201);
    }

    public function show(Student $student)
    {
        return response()->json(
            $student->load(['user', 'major', 'faculty', 'schedule'])
        );
    }

    public function update(Request $request, Student $student)
    {
        $student->update($request->only(['name', 'phone', 'year', 'major_id', 'faculty_id', 'schedule_id']));
        return response()->json(['message' => 'Student updated']);
    }

    public function destroy(Student $student)
    {
        $student->user()->delete();
        return response()->json(['message' => 'Student deleted']);
    }
}
