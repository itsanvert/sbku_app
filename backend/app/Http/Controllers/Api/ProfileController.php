<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Laravel\Fortify\Contracts\UpdatesUserProfileInformation;
use Laravel\Fortify\Contracts\UpdatesUserPasswords;

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
    public function updateProfile(Request $request, UpdatesUserProfileInformation $updater)
    {
        $updater->update($request->user(), $request->only(['name', 'email']));

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'user'    => (new UserResource($request->user()->fresh()))->resolve(),
        ]);
    }

    /**
     * Update user password
     */
    public function updatePassword(Request $request, UpdatesUserPasswords $updater)
    {
        $updater->update($request->user(), $request->all());

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

        return response()->json([
            'success' => true,
            'message' => 'Profile photo updated successfully',
            'user'    => (new UserResource($user->fresh()))->resolve(),
        ]);
    }

    /**
     * Delete profile photo
     */
    public function deleteProfilePhoto(Request $request)
    {
        $user = $request->user();

        $user->deleteProfilePhoto();

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

        \Log::info('updateFcmToken called', [
            'user_id' => $user?->id,
            'token_length' => strlen($request->token),
        ]);

        $saved = $user->forceFill(['fcm_token' => $request->token])->save();

        \Log::info('updateFcmToken result', [
            'user_id' => $user->id,
            'saved' => $saved,
            'fresh_token' => $user->fresh()?->fcm_token ? 'set' : 'null',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token updated successfully',
        ]);
    }
}
