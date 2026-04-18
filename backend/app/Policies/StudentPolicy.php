<?php

namespace App\Policies;

use App\Models\Student;
use App\Models\User;

/**
 * Authorization policy for Student resource.
 *
 * Determines who can view, create, update, and delete students.
 */
class StudentPolicy
{
    /**
     * Anyone authenticated can view students list.
     */
    public function viewAny(User $user): bool
    {
        return true;
    }

    /**
     * Anyone authenticated can view a single student.
     */
    public function view(User $user, Student $student): bool
    {
        // Students can view their own record
        if ($user->role === 'student') {
            return $user->student?->id === $student->id;
        }

        // Teachers and admins can view any student
        return in_array($user->role, ['teacher', 'admin']);
    }

    /**
     * Only admins can create students.
     */
    public function create(User $user): bool
    {
        return $user->role === 'admin';
    }

    /**
     * Only admins can update students.
     */
    public function update(User $user, Student $student): bool
    {
        return $user->role === 'admin';
    }

    /**
     * Only admins can delete students.
     */
    public function delete(User $user, Student $student): bool
    {
        return $user->role === 'admin';
    }
}
