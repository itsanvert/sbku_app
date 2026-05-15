<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Teacher;
use Illuminate\Http\Request;

class TeacherController extends Controller
{
    public function __construct(
        private readonly \App\Services\FirestoreService $firestore,
    ) {}

    public function index(Request $request)
    {
        if (\App\Services\FirestoreService::isActive() || $request->has('firestore')) {
            $teachers = $this->firestore->list('teachers');
            
            return response()->json([
                'data'         => $teachers,
                'current_page' => 1,
                'last_page'    => 1,
                'total'        => count($teachers),
                'per_page'     => count($teachers),
            ]);
        }

        $teachers = Teacher::query()
            ->with(['user', 'major', 'faculty', 'schedule', 'shift'])
            ->whereHas('user', function($q) use ($request) {
                $q->when($request->search, function($query) use ($request) {
                    $query->where('name', 'like', '%'.$request->search.'%')
                          ->orWhere('email', 'like', '%'.$request->search.'%');
                });
            })
            ->orderBy($request->sort_by ?? 'id', $request->sort_dir ?? 'asc')
            ->paginate($request->per_page ?? 10);

        return response()->json($teachers);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'       => 'required|string|max:255',
            'email'      => 'required|email|unique:users,email',
            'password'   => 'required|min:8',
            'gender'     => 'required|in:male,female',
            'phone'      => 'nullable|string',
            'year'       => 'nullable',
            'major_id'   => 'nullable|exists:majors,id',
            'faculty_id' => 'nullable|exists:faculties,id',
            'schedule_id'=> 'nullable|exists:schedules,id',
            'shift_id'   => 'nullable|exists:shifts,id',
            'photo'      => 'nullable|image|max:1024',
        ]);

        $teacher = \DB::transaction(function () use ($validated, $request) {
            $user = \App\Models\User::create([
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'password' => \Hash::make($validated['password']),
                'role'     => 'teacher',
            ]);

            $teacherData = [
                'gender'     => $validated['gender'],
                'phone'      => $validated['phone'],
                'year'       => $validated['year'],
                'major_id'   => $validated['major_id'],
                'faculty_id' => $validated['faculty_id'],
                'schedule_id'=> $validated['schedule_id'],
                'shift_id'   => $validated['shift_id'],
            ];

            if ($request->hasFile('photo')) {
                $teacherData['profile_image_path'] = $request->file('photo')->store('profile-photos', 'public');
            }

            $user->teacher->update($teacherData);
            return $user->teacher->load(['user', 'major', 'faculty', 'schedule', 'shift']);
        });

        return response()->json($teacher, 201);
    }

    public function show(Request $request, $id)
    {
        if (\App\Services\FirestoreService::isActive() || $request->has('firestore')) {
            $teacher = $this->firestore->getDocument('teachers', (string)$id);
            if (!$teacher) {
                return response()->json(['message' => 'Teacher not found'], 404);
            }
            return response()->json($teacher);
        }

        $teacher = Teacher::findOrFail($id);
        return response()->json(
            $teacher->load(['user', 'major', 'faculty', 'schedule', 'shift'])
        );
    }

    public function update(Request $request, $id)
    {
        if (\App\Services\FirestoreService::isActive() || $request->has('firestore')) {
            $data = $request->all();
            unset($data['id']); // Don't update the ID field itself
            $teacher = $this->firestore->set('teachers', (string)$id, $data);
            return response()->json($teacher);
        }

        $teacher = Teacher::findOrFail($id);
        $validated = $request->validate([
            'name'       => 'sometimes|required|string|max:255',
            'email'      => 'sometimes|required|email|unique:users,email,'.$teacher->user_id,
            'password'   => 'nullable|min:8',
            'gender'     => 'sometimes|required|in:male,female',
            'phone'      => 'nullable|string',
            'year'       => 'nullable',
            'major_id'   => 'nullable|exists:majors,id',
            'faculty_id' => 'nullable|exists:faculties,id',
            'schedule_id'=> 'nullable|exists:schedules,id',
            'shift_id'   => 'nullable|exists:shifts,id',
            'photo'      => 'nullable|image|max:1024',
        ]);

        \DB::transaction(function () use ($validated, $request, $teacher) {
            $userData = $request->only(['name', 'email']);
            if ($request->password) {
                $userData['password'] = \Hash::make($request->password);
            }
            $teacher->user->update($userData);

            $teacherData = $request->only(['gender', 'phone', 'year', 'major_id', 'faculty_id', 'schedule_id', 'shift_id']);
            
            if ($request->hasFile('photo')) {
                $teacherData['profile_image_path'] = $request->file('photo')->store('profile-photos', 'public');
            }

            $teacher->update($teacherData);
        });

        return response()->json($teacher->load(['user', 'major', 'faculty', 'schedule', 'shift']));
    }

    public function destroy(Request $request, $id)
    {
        if (\App\Services\FirestoreService::isActive() || $request->has('firestore')) {
            $this->firestore->delete('teachers', (string)$id);
            return response()->json(['message' => 'Teacher deleted']);
        }

        $teacher = Teacher::findOrFail($id);
        $teacher->user->delete();
        return response()->json(['message' => 'Teacher deleted']);
    }
}
