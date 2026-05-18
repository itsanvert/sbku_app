<?php

namespace App\Livewire\Users;

use App\Models\User;
use Livewire\Component;
use Illuminate\Support\Facades\Hash;

class UserEdit extends Component
{
    public $userId;
    public $name     = '';
    public $email    = '';
    public $password = '';
    public $role     = '';
    public $oldRole  = '';

    public function mount($userId)
    {
        if (\App\Services\FirestoreService::isActive()) {
            $user = app(\App\Services\FirestoreService::class)->getDocument('users', (string)$userId);
            if (!$user) abort(404);
            $this->userId = $user['id'];
            $this->name   = $user['name'];
            $this->email  = $user['email'];
            $this->role   = $user['role'] ?? 'user';
            $this->oldRole = $this->role;
        } else {
            $user = User::findOrFail($userId);
            $this->userId = $user->id;
            $this->name   = $user->name;
            $this->email  = $user->email;
            $this->role   = $user->role ?? 'user';
            $this->oldRole = $this->role;
        }
    }

    public function save()
    {
        $this->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email' . (\App\Services\FirestoreService::isActive() ? '' : '|unique:users,email,' . $this->userId),
            'password' => 'nullable|min:8',
            'role'     => 'required|in:super_admin,admin,student,teacher',
        ]);

        $data = [
            'name'  => $this->name,
            'email' => $this->email,
            'role'  => $this->role,
            'updated_at' => now()->format('Y-m-d H:i:s'),
        ];

        if ($this->password) {
            $data['password'] = Hash::make($this->password);
        }

        if (\App\Services\FirestoreService::isActive()) {
            app(\App\Services\FirestoreService::class)->update('users', (string)$this->userId, $data);
        } else {
            User::findOrFail($this->userId)->update($data);
        }

        if ($this->role !== $this->oldRole) {
            if (\App\Services\FirestoreService::isActive()) {
                $firestore = app(\App\Services\FirestoreService::class);
                if (in_array($this->oldRole, ['teacher', 'student'])) {
                    $firestore->delete($this->oldRole . 's', (string)$this->userId);
                }
                if (in_array($this->role, ['teacher', 'student'])) {
                    $firestore->create($this->role . 's', ['user_id' => (string)$this->userId, 'role' => $this->role]);
                }
            } else {
                $user = User::findOrFail($this->userId);
                if ($this->oldRole === 'teacher' && $this->role !== 'teacher') {
                    $user->teacher()->delete();
                }
                if ($this->oldRole === 'student' && $this->role !== 'student') {
                    $user->student()->delete();
                }
                if ($this->role === 'teacher' && $this->oldRole !== 'teacher') {
                    $user->teacher()->create();
                }
                if ($this->role === 'student' && $this->oldRole !== 'student') {
                    $user->student()->create();
                }
            }
        }

        $this->dispatch('userUpdated');
    }

    public function render()
    {
        return view('livewire.users.user-edit');
    }
}
