<?php

namespace App\Livewire\Users;

use App\Models\User;
use Livewire\Component;
use Illuminate\Support\Facades\Hash;

class UserCreate extends Component
{
    public $name     = '';
    public $email    = '';
    public $password = '';
    public $role     = '';

    protected $rules = [
        'name'     => 'required|string|max:255',
        'email'    => 'required|email|unique:users,email',
        'password' => 'required|min:8',
        'role'     => 'required|in:super_admin,admin,student,teacher',
    ];

    public function save()
    {
        $isFirestore = \App\Services\FirestoreService::isActive();

        $this->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email' . ($isFirestore ? '' : '|unique:users,email'),
            'password' => 'required|min:8',
            'role'     => 'required|in:super_admin,admin,student,teacher',
        ]);

        $data = [
            'name'     => $this->name,
            'email'    => $this->email,
            'password' => Hash::make($this->password),
            'role'     => $this->role,
            'created_at' => now()->format('Y-m-d H:i:s'),
            'updated_at' => now()->format('Y-m-d H:i:s'),
        ];

        if ($isFirestore) {
            $firestore = app(\App\Services\FirestoreService::class);
            $userId = $firestore->create('users', $data);
            if (in_array($this->role, ['teacher', 'student'])) {
                $firestore->create($this->role . 's', ['user_id' => $userId, 'role' => $this->role]);
            }
        } else {
            User::create($data);
        }

        $this->reset();
        $this->dispatch('userCreated');
    }

    public function render()
    {
        return view('livewire.users.user-create');
    }
}
