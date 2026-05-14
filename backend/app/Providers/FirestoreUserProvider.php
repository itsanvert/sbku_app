<?php

namespace App\Providers;

use App\Services\FirestoreService;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Contracts\Auth\UserProvider;
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
        $data = $this->firestore->getDocument('users', (string)$identifier);
        
        if (!$data) {
            return null;
        }

        return $this->hydrateUser($data);
    }

    public function retrieveByToken($identifier, $token)
    {
        $users = $this->firestore->list('users', [
            'id' => $identifier,
            'remember_token' => $token
        ]);

        return !empty($users) ? $this->hydrateUser($users[0]) : null;
    }

    public function updateRememberToken(Authenticatable $user, $token)
    {
        $this->firestore->set('users', (string)$user->getAuthIdentifier(), [
            'remember_token' => $token
        ]);
    }

    public function retrieveByCredentials(array $credentials)
    {
        if (empty($credentials) ||
           (count($credentials) === 1 &&
            array_key_exists('password', $credentials))) {
            return null;
        }

        $query = $this->firestore->collection('users');
        
        foreach ($credentials as $key => $value) {
            if (str_contains($key, 'password')) continue;
            $query = $query->where($key, '=', $value);
        }

        $documents = $query->documents();
        
        foreach ($documents as $document) {
            $data = $document->data();
            $data['id'] = $document->id();
            return $this->hydrateUser($data);
        }

        return null;
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
