<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Teacher;
use Illuminate\Http\Request;

class TeacherController extends Controller
{
    public function index(Request $request)
    {
        $teachers = Teacher::query()
            ->select('teachers.*')
            ->join('users', 'teachers.user_id', '=', 'users.id')
            ->with(['user', 'major', 'faculty', 'schedule'])
            ->when($request->search, fn($q) =>
                $q->where('teachers.name', 'like', '%'.$request->search.'%')
                  ->orWhere('users.email', 'like', '%'.$request->search.'%')
            )
            ->orderBy($request->sort_by ?? 'teachers.id', $request->sort_dir ?? 'asc')
            ->paginate($request->per_page ?? 10);

        return response()->json($teachers);
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

        // Create user + teacher as needed
        // ...

        return response()->json(['message' => 'Teacher created'], 201);
    }

    public function show(Teacher $teacher)
    {
        return response()->json(
            $teacher->load(['user', 'major', 'faculty', 'schedule'])
        );
    }

    public function update(Request $request, Teacher $teacher)
    {
        $teacher->update($request->only(['name', 'phone', 'year', 'major_id', 'faculty_id', 'schedule_id']));
        return response()->json(['message' => 'Teacher updated']);
    }

    public function destroy(Teacher $teacher)
    {
        $teacher->user()->delete();
        return response()->json(['message' => 'Teacher deleted']);
    }
}
