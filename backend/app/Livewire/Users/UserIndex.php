<?php

namespace App\Livewire\Users;

use App\Models\User;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Computed;

class UserIndex extends Component
{
    use WithPagination;

    public $search       = '';
    public $role         = '';
    public $sortBy        = 'id';
    public $sortDirection = 'asc';
    
    public $selected      = [];
    public $selectAll     = false;

    public $showCreateModal = false;
    public $showEditModal   = false;
    public $editUserId      = null;
    public $deleteUserId    = null;

    protected $listeners = [
        'userCreated' => 'handleUserCreated',
        'userUpdated' => 'handleUserUpdated',
        'closeModal'  => 'closeModals',
    ];

    public function updatingSearch() { $this->resetPage(); }
    public function updatingRole() { $this->resetPage(); }

    public function updatedSelectAll($value)
    {
        if ($value) {
            $this->selected = $this->users->pluck('id')->map(fn($id) => (string)$id)->toArray();
        } else {
            $this->selected = [];
        }
    }

    public function sort($column)
    {
        if ($this->sortBy === $column) {
            $this->sortDirection = $this->sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            $this->sortBy        = $column;
            $this->sortDirection = 'asc';
        }
        $this->resetPage();
    }

    #[Computed]
    public function users()
    {
        return User::query()
            ->when($this->search, function ($q) {
                $q->where(function($query) {
                    $query->where('name', 'like', '%' . $this->search . '%')
                          ->orWhere('email', 'like', '%' . $this->search . '%');
                });
            })
            ->when($this->role, function ($q) {
                $q->where('role', $this->role);
            })
            ->orderBy($this->sortBy, $this->sortDirection)
            ->paginate(10);
    }

    public function openCreateModal()
    {
        $this->showEditModal   = false;
        $this->showCreateModal = true;
    }

    public function openEditModal($id)
    {
        $this->editUserId      = $id;
        $this->showCreateModal = false;
        $this->showEditModal   = true;
    }

    public function confirmDelete($id)
    {
        $this->deleteUserId = $id;
        $this->dispatch('modal-show', name: 'confirm-delete');
    }

    public function deleteUser()
    {
        if ($this->deleteUserId) {
            User::findOrFail($this->deleteUserId)->delete();
            $this->deleteUserId = null;
            session()->flash('message', 'User deleted successfully.');
            $this->dispatch('modal-close', name: 'confirm-delete');
        }
    }

    public function confirmBulkDelete()
    {
        if (empty($this->selected)) {
            return;
        }
        $this->dispatch('modal-show', name: 'confirm-bulk-delete');
    }

    public function deleteSelected()
    {
        if (!empty($this->selected)) {
            User::whereIn('id', $this->selected)->delete();
            $count = count($this->selected);
            $this->selected = [];
            $this->selectAll = false;
            session()->flash('message', $count . ' users deleted successfully.');
            $this->dispatch('modal-close', name: 'confirm-bulk-delete');
        }
    }

    public function closeModals()
    {
        $this->showCreateModal = false;
        $this->showEditModal   = false;
        $this->editUserId      = null;
    }

    public function handleUserCreated()
    {
        $this->closeModals();
        session()->flash('message', 'User created successfully.');
    }

    public function handleUserUpdated()
    {
        $this->closeModals();
        session()->flash('message', 'User updated successfully.');
    }

    public function render()
    {
        return view('livewire.users.user-index')->layout('layouts.app');
    }
}
