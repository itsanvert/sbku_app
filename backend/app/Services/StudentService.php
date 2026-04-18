<?php

namespace App\Services;

use App\Models\Student;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

/**
 * Encapsulates student business logic.
 *
 * Keeps the StudentController thin — controllers only orchestrate
 * (receive request → call service → return response).
 */
class StudentService
{
    /**
     * Create a new student and its associated user in a transaction.
     */
    public function create(array $validated, ?UploadedFile $photo = null): Student
    {
        return DB::transaction(function () use ($validated, $photo) {
            $user = User::create([
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role'     => 'student',
            ]);

            $studentData = collect($validated)
                ->only(['gender', 'dob', 'faculty_id', 'major_id', 'year', 'shift', 'generation'])
                ->toArray();

            if ($photo) {
                $studentData['profile_image_path'] = $photo->store('profile-photos', 'public');
            }

            $user->student()->update($studentData);

            return $user->student->load(['user', 'major', 'faculty']);
        });
    }

    /**
     * Update an existing student and its associated user.
     */
    public function update(Student $student, array $validated, ?UploadedFile $photo = null): Student
    {
        return DB::transaction(function () use ($student, $validated, $photo) {
            // Update user fields
            $userData = collect($validated)->only(['name', 'email'])->toArray();
            if (!empty($validated['password'])) {
                $userData['password'] = Hash::make($validated['password']);
            }
            if (!empty($userData)) {
                $student->user->update($userData);
            }

            // Update student fields
            $studentData = collect($validated)
                ->only(['gender', 'dob', 'faculty_id', 'major_id', 'year', 'shift', 'generation'])
                ->toArray();

            if ($photo) {
                $studentData['profile_image_path'] = $photo->store('profile-photos', 'public');
            }

            if (!empty($studentData)) {
                $student->update($studentData);
            }

            return $student->load(['user', 'major', 'faculty']);
        });
    }

    /**
     * Delete a student by removing its associated user (cascade).
     */
    public function delete(Student $student): void
    {
        $student->user()->delete();
    }
}
