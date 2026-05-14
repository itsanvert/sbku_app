<?php

namespace App\Providers;

use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Contracts\Auth\UserProvider;
use App\Services\FirestoreService;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class FirestoreUserProvider implements UserProvider
{
    protected $firestore;

    public function __construct(FirestoreService $firestore)
    {
        $this->firestore = $firestore;
    }

    public function retrieveById($identifier)
    {
        $userData = $this->firestore->find('users', $identifier);
        if (!$userData) return null;

        return $this->arrayToUser($userData);
    }

    public function retrieveByToken($identifier, $token)
    {
        // For simplicity, we'll implement this if needed for "remember me"
        return null;
    }

    public function updateRememberToken(Authenticatable $user, $token)
    {
        $this->firestore->update('users', $user->getAuthIdentifier(), [
            'remember_token' => $token
        ]);
    }

    public function retrieveByCredentials(array $credentials)
    {
        if (empty($credentials) || (count($credentials) === 1 && array_key_exists('password', $credentials))) {
            return null;
        }

        $email = $credentials['email'] ?? null;
        if (!$email) return null;

        $results = $this->firestore->all('users', [['email', '=', $email]], [], 1);
        
        if ($results->isEmpty()) return null;

        return $this->arrayToUser($results->first());
    }

    public function validateCredentials(Authenticatable $user, array $credentials)
    {
        return Hash::check($credentials['password'], $user->getAuthPassword());
    }

    public function rehashPasswordIfRequired(Authenticatable $user, array $credentials, bool $force = false)
    {
        // Not implemented for now
    }

    protected function arrayToUser(array $data)
    {
        $user = new User();
        $user->forceFill($data);
        $user->exists = true;
        return $user;
    }
}
