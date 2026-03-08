<?php

namespace App\Livewire\Teachers;

use App\Models\Teacher;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Computed;

class TeacherIndex extends Component
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
    public $editTeacherId      = null;
    public $deleteTeacherId    = null;

    protected $listeners = [
        'teacherCreated' => 'handleTeacherCreated',
        'teacherUpdated' => 'handleTeacherUpdated',
        'closeModal'  => 'closeModals',
    ];

    public function updatingSearch() { $this->resetPage(); }
    public function updatingRole() { $this->resetPage(); }

    public function updatedSelectAll($value)
    {
        if ($value) {
            $this->selected = $this->teachers->pluck('id')->map(fn($id) => (string)$id)->toArray();
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
    public function teachers()
    {
        return Teacher::query()
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
        $this->editTeacherId      = $id;
        $this->showCreateModal = false;
        $this->showEditModal   = true;
    }

    public function confirmDelete($id)
    {
        $this->deleteTeacherId = $id;
        $this->dispatch('modal-show', name: 'confirm-delete');
    }

    public function deleteTeacher()
    {
        if ($this->deleteTeacherId) {
            Teacher::findOrFail($this->deleteTeacherId)->delete();
            $this->deleteTeacherId = null;
            session()->flash('message', 'Teacher deleted successfully.');
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
            Teacher::whereIn('id', $this->selected)->delete();
            $count = count($this->selected);
            $this->selected = [];
            $this->selectAll = false;
            session()->flash('message', $count . ' teachers deleted successfully.');
            $this->dispatch('modal-close', name: 'confirm-bulk-delete');
        }
    }

    public function closeModals()
    {
        $this->showCreateModal = false;
        $this->showEditModal   = false;
        $this->editTeacherId      = null;
    }

    public function handleTeacherCreated()
    {
        $this->closeModals();
        session()->flash('message', 'Teacher created successfully.');
    }

    public function handleTeacherUpdated()
    {
        $this->closeModals();
        session()->flash('message', 'Teacher updated successfully.');
    }

    public function render()
    {
        return view('livewire.teachers.teacher-index')->layout('layouts.app');
    }

}
