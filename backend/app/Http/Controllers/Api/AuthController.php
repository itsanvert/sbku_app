<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Thin API controller for authentication.
 *
 * Uses ApiResponse trait for consistent JSON envelope.
 * Uses UserResource for consistent user serialization.
 *re
 * NOTE: Auth responses use a FLAT format (token/user at top level)
 * for backward compatibility with the existing Flutter AuthService.
 */
class AuthController extends Controller
{
    use ApiResponse;

    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('mobile-app')->plainTextToken;

        // Flat format for Flutter AuthService compatibility
        return response()->json([
            'success' => true,
            'user'    => (new UserResource($user))->resolve(),
            'token'   => $token,
        ], 201);
    }

    /**
     * Login user
     */
    public function login(LoginRequest $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('mobile-app')->plainTextToken;

        // Flat format for Flutter AuthService compatibility
        return response()->json([
            'success' => true,
            'user'    => (new UserResource($user))->resolve(),
            'token'   => $token,
        ]);
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return $this->success(null, 'Logged out successfully');
    }

    /**
     * Get authenticated user
     */
    public function user(Request $request)
    {
        // Flat format for Flutter AuthService compatibility
        return response()->json([
            'success' => true,
            'user'    => (new UserResource($request->user()))->resolve(),
        ]);
    }
}
