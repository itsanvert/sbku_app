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
            ->with(['user', 'major', 'faculty'])
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

    public function store(Request $request)
    {
        $validated = $request->validate([
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
        ]);

        $student = \DB::transaction(function () use ($validated, $request) {
            $user = \App\Models\User::create([
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'password' => \Hash::make($validated['password']),
                'role'     => 'student',
            ]);

            $studentData = [
                'gender'     => $validated['gender'],
                'dob'        => $validated['dob'],
                'faculty_id' => $validated['faculty_id'],
                'major_id'   => $validated['major_id'],
                'year'       => $validated['year'],
                'shift'      => $validated['shift'],
                'generation' => $validated['generation'],
            ];

            if ($request->hasFile('photo')) {
                $studentData['profile_image_path'] = $request->file('photo')->store('profile-photos', 'public');
            }

            $user->student()->update($studentData); // Use student() relationship to update
            return $user->student->load(['user', 'major', 'faculty']);
        });

        return response()->json($student, 201);
    }

    public function show(Student $student)
    {
        return response()->json(
            $student->load(['user', 'major', 'faculty'])
        );
    }

    public function update(Request $request, Student $student)
    {
        $validated = $request->validate([
            'name'       => 'sometimes|required|string|max:255',
            'email'      => 'sometimes|required|email|unique:users,email,'.$student->user_id,
            'password'   => 'nullable|min:8',
            'gender'     => 'sometimes|required|in:male,female',
            'dob'        => 'nullable|date',
            'faculty_id' => 'sometimes|required|exists:faculties,id',
            'major_id'   => 'sometimes|required|exists:majors,id',
            'year'       => 'sometimes|required|integer',
            'shift'      => 'sometimes|required|string',
            'generation' => 'sometimes|required|string',
            'photo'      => 'nullable|image|max:1024',
        ]);

        \DB::transaction(function () use ($validated, $request, $student) {
            $userData = $request->only(['name', 'email']);
            if ($request->password) {
                $userData['password'] = \Hash::make($request->password);
            }
            $student->user->update($userData);

            $studentData = $request->only(['gender', 'dob', 'faculty_id', 'major_id', 'year', 'shift', 'generation']);
            
            if ($request->hasFile('photo')) {
                $studentData['profile_image_path'] = $request->file('photo')->store('profile-photos', 'public');
            }

            $student->update($studentData);
        });

        return response()->json($student->load(['user', 'major', 'faculty']));
    }

    public function destroy(Student $student)
    {
        $student->user()->delete();
        return response()->json(['message' => 'Student deleted']);
    }
}
