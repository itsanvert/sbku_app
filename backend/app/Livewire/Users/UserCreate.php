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
        'role'     => 'required|in:admin,user',
    ];

    public function save()
    {
        $this->validate();

        User::create([
            'name'     => $this->name,
            'email'    => $this->email,
            'password' => Hash::make($this->password),
            'role'     => $this->role,
        ]);

        $this->reset();
        $this->dispatch('userCreated');
    }

    public function render()
    {
        return view('livewire.users.user-create');
    }
}
