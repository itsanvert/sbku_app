<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Services\FirestoreService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

/**
 * API controller for profile management.
 *
 * Uses UserResource for consistent user serialization.
 *
 * NOTE: Profile responses use a FLAT format (user at top level)
 * for backward compatibility with the existing Flutter AuthService.
 */
class ProfileController extends Controller
{
    use ApiResponse;

    /**
     * Update user profile information
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        if (FirestoreService::isActive()) {
            $validated = $request->validate([
                'name'  => 'required|string|max:255',
                'email' => 'required|email|max:255',
            ]);

            app(FirestoreService::class)->update('users', (string) $user->id, array_merge($validated, [
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ]));

            $user->forceFill($validated);
        } else {
            $validated = $request->validate([
                'name'  => 'required|string|max:255',
                'email' => ['required', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
            ]);

            $user->forceFill($validated)->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'user'    => (new UserResource($user))->resolve(),
        ]);
    }

    /**
     * Update user password
     */
    public function updatePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'The current password is incorrect.',
            ], 422);
        }

        if (FirestoreService::isActive()) {
            app(FirestoreService::class)->update('users', (string) $user->id, [
                'password'   => Hash::make($request->password),
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ]);
        } else {
            $user->forceFill([
                'password' => Hash::make($request->password),
            ])->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Password updated successfully',
        ]);
    }

    /**
     * Upload profile photo
     */
    public function updateProfilePhoto(Request $request)
    {
        $request->validate([
            'photo' => 'required|image|max:1024', // 1MB max
        ]);

        $user = $request->user();

        $user->updateProfilePhoto($request->file('photo'));

        $photoPath = $user->profile_photo_path;

        if (FirestoreService::isActive()) {
            $firestore = app(\App\Services\FirestoreService::class);
            
            if ($teacher = $user->teacher) {
                $firestore->set('teachers', (string)$teacher['id'], ['profile_image_path' => $photoPath]);
            }
            if ($student = $user->student) {
                $firestore->set('students', (string)$student['id'], ['profile_image_path' => $photoPath]);
            }
        } else {
            if ($user->teacher) {
                $user->teacher->update(['profile_image_path' => $photoPath]);
            }
            if ($user->student) {
                $user->student->update(['profile_image_path' => $photoPath]);
            }
        }

        // Flat format for Flutter AuthService compatibility
        return response()->json([
            'success' => true,
            'message' => 'Profile photo updated successfully',
            'user'    => (new UserResource($user))->resolve(),
        ]);
    }

    /**
     * Delete profile photo
     */
    public function deleteProfilePhoto(Request $request)
    {
        $user = $request->user();
        $user->deleteProfilePhoto();

        // Flat format for Flutter AuthService compatibility
        return response()->json([
            'success' => true,
            'message' => 'Profile photo deleted successfully',
            'user'    => (new UserResource($user->fresh()))->resolve(),
        ]);
    }

    /**
     * Update FCM token
     */
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
        ]);

        $user = $request->user();

        if (FirestoreService::isActive()) {
            app(FirestoreService::class)->update('users', (string) $user->id, [
                'fcm_token'  => $request->token,
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ]);
        } else {
            $user->forceFill(['fcm_token' => $request->token])->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'FCM token updated successfully',
        ]);
    }
}
