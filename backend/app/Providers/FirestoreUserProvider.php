<?php

namespace App\Providers;

use App\Services\FirestoreService;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Contracts\Auth\UserProvider;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class FirestoreUserProvider implements UserProvider
{
    protected $firestore;

    public function __construct(FirestoreService $firestore)
    {
        $this->firestore = $firestore;
    }

    public function retrieveById($identifier)
    {
        $userData = Cache::remember("user_auth_id_{$identifier}", 300, function () use ($identifier) {
            return $this->firestore->getDocument('users', (string)$identifier);
        });

        return $userData ? $this->hydrateUser($userData) : null;
    }

    public function retrieveByToken($identifier, $token)
    {
        return null;
    }

    public function updateRememberToken(Authenticatable $user, $token)
    {
        // Not implemented for Firestore
    }

    public function retrieveByCredentials(array $credentials)
    {
        if (empty($credentials) || (count($credentials) === 1 && array_key_exists('password', $credentials))) {
            return null;
        }

        $email = $credentials['email'] ?? null;
        $cacheKey = $email ? "user_auth_email_" . md5($email) : null;

        $userData = $cacheKey ? Cache::get($cacheKey) : null;

        if (!$userData) {
            try {
                $query = $this->firestore->db->collection('users');

                foreach ($credentials as $key => $value) {
                    if (!str_contains($key, 'password')) {
                        $query = $query->where($key, '==', $value);
                    }
                }

                $snapshot = $query->documents();
                foreach ($snapshot as $doc) {
                    $userData = $doc->data();
                    $userData['id'] = $doc->id();
                    
                    if ($cacheKey) {
                        Cache::put($cacheKey, $userData, 300);
                        Cache::put("user_auth_id_{$userData['id']}", $userData, 300);
                    }
                    break;
                }
            } catch (\Exception $e) {
                \Log::error("Firestore auth error: " . $e->getMessage());
                return null;
            }
        }

        return $userData ? $this->hydrateUser($userData) : null;
    }

    public function validateCredentials(Authenticatable $user, array $credentials)
    {
        return Hash::check($credentials['password'], $user->getAuthPassword());
    }

    public function rehashPasswordIfRequired(Authenticatable $user, array $credentials, bool $force = false)
    {
        return false;
    }

    /**
     * Create a User model instance from Firestore data.
     */
    protected function hydrateUser(array $data)
    {
        $user = new User();
        $user->forceFill($data);
        $user->exists = true;
        return $user;
    }
}
