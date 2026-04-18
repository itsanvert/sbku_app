<?php

namespace App\Policies;

use App\Models\AttendanceSession;
use App\Models\User;

/**
 * Authorization policy for AttendanceSession resource.
 */
class AttendanceSessionPolicy
{
    /**
     * Anyone authenticated can view sessions.
     */
    public function viewAny(User $user): bool
    {
        return true;
    }

    /**
     * Anyone authenticated can view a session.
     */
    public function view(User $user, AttendanceSession $session): bool
    {
        return true;
    }

    /**
     * Only teachers can create sessions.
     */
    public function create(User $user): bool
    {
        return in_array($user->role, ['teacher', 'admin']);
    }

    /**
     * Only the session's teacher or an admin can end it.
     */
    public function end(User $user, AttendanceSession $session): bool
    {
        if ($user->role === 'admin') {
            return true;
        }

        return $user->teacher?->id === $session->teacher_id;
    }

    /**
     * Only the session's teacher or an admin can verify attendance.
     */
    public function verify(User $user, AttendanceSession $session): bool
    {
        if ($user->role === 'admin') {
            return true;
        }

        return $user->teacher?->id === $session->teacher_id;
    }
}
