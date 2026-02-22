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
        $user = User::findOrFail($userId);
        $this->userId = $user->id;
        $this->name   = $user->name;
        $this->email  = $user->email;
        $this->role   = $user->role ?? 'user';
    }

    public function save()
    {
        $this->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email,' . $this->userId,
            'password' => 'nullable|min:8',
            'role'     => 'required|in:admin,user',
        ]);

        $data = [
            'name'  => $this->name,
            'email' => $this->email,
            'role'  => $this->role,
        ];

        if ($this->password) {
            $data['password'] = Hash::make($this->password);
        }

        User::findOrFail($this->userId)->update($data);
        $this->dispatch('userUpdated');
    }

    public function render()
    {
        return view('livewire.users.user-edit');
    }
}
