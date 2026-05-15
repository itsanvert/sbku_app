<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$rolesAndPermissions): Response
    {
        $user = $request->user();

        if (! $user) {
             abort(403);
        }

        // Global bypass for super_admin
        if ($user->role === 'super_admin') {
            return $next($request);
        }

        foreach ($rolesAndPermissions as $item) {
            // Priority 1: Check global database role field
            if ($user->role === $item) {
                return $next($request);
            }

            // Priority 2: Check Jetstream role/permission on the current team
            if ($user->currentTeam && $user->hasTeamPermission($user->currentTeam, $item)) {
                return $next($request);
            }
        }

        abort(403, 'Unauthorized. This action requires specific role or permissions.');
    }
}
