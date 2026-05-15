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

    public function mount($userId)
    {
        if (config('app.env') === 'production') {
            $user = app(\App\Services\FirestoreService::class)->getDocument('users', (string)$userId);
            if (!$user) abort(404);
            $this->userId = $user['id'];
            $this->name   = $user['name'];
            $this->email  = $user['email'];
            $this->role   = $user['role'] ?? 'user';
        } else {
            $user = User::findOrFail($userId);
            $this->userId = $user->id;
            $this->name   = $user->name;
            $this->email  = $user->email;
            $this->role   = $user->role ?? 'user';
        }
    }

    public function save()
    {
        $this->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email' . (config('app.env') === 'production' ? '' : '|unique:users,email,' . $this->userId),
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

        if (config('app.env') === 'production') {
            app(\App\Services\FirestoreService::class)->update('users', (string)$this->userId, $data);
        } else {
            User::findOrFail($this->userId)->update($data);
        }
        $this->dispatch('userUpdated');
    }

    public function render()
    {
        return view('livewire.users.user-edit');
    }
}
