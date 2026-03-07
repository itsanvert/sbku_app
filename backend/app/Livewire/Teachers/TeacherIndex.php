<?php

namespace App\Livewire\Teachers;

use App\Models\Teacher;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Computed;

class TeacherIndex extends Component
{
    use WithPagination;

    protected $paginationTheme = 'tailwind';

    public $search = '';
    public $sortBy = 'teachers.id';
    public $sortDirection = 'asc';

    public $selected = [];
    public $selectAll = false;

    public $showCreateModal = false;
    public $showEditModal   = false;
    public $editTeacherId   = null;
    public $deleteTeacherId = null;

    protected $listeners = [
        'teacherCreated' => 'handleTeacherCreated',
        'teacherUpdated' => 'handleTeacherUpdated',
        'closeModal'     => 'closeModals',
    ];

    /* -----------------------------
        Lifecycle
    ----------------------------- */

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function updatedSelectAll($value)
    {
        if ($value) {
            $this->selected = $this->teachers
                ->pluck('id')
                ->map(fn ($id) => (string) $id)
                ->toArray();
        } else {
            $this->selected = [];
        }
    }

    /* -----------------------------
        Sorting
    ----------------------------- */

    public function sort($column)
    {
        if ($this->sortBy === $column) {
            $this->sortDirection = $this->sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            $this->sortBy = $column;
            $this->sortDirection = 'asc';
        }

        $this->resetPage();
    }

    /* -----------------------------
        Teachers Query
    ----------------------------- */

    #[Computed]
    public function teachers()
    {
        return Teacher::query()
            ->select('teachers.*')
            ->join('users', 'teachers.user_id', '=', 'users.id')
            ->with('user')
            ->when($this->search, function ($query) {
                $query->where(function ($q) {
                    $q->where('teachers.name', 'like', '%' . $this->search . '%')
                      ->orWhere('users.email', 'like', '%' . $this->search . '%');
                });
            })
            ->orderBy($this->sortBy, $this->sortDirection)
            ->paginate(10);
    }

    /* -----------------------------
        Modals
    ----------------------------- */

    public function openCreateModal()
    {
        $this->reset(['showEditModal', 'editTeacherId']);
        $this->showCreateModal = true;
    }

    public function openEditModal($id)
    {
        $this->reset(['showCreateModal']);
        $this->editTeacherId = $id;
        $this->showEditModal = true;
    }

    public function closeModals()
    {
        $this->reset([
            'showCreateModal',
            'showEditModal',
            'editTeacherId',
        ]);
    }

    /* -----------------------------
        Delete Single
    ----------------------------- */

    public function confirmDelete($id)
    {
        $this->deleteTeacherId = $id;
        $this->dispatch('modal-show', name: 'confirm-delete');
    }

    public function deleteTeacher()
    {
        if (!$this->deleteTeacherId) return;

        $teacher = Teacher::with('user')->findOrFail($this->deleteTeacherId);

        $teacher->user()->delete(); // cascade removes teacher if FK is set

        $this->deleteTeacherId = null;

        session()->flash('message', 'Teacher deleted successfully.');
        $this->dispatch('modal-close', name: 'confirm-delete');
    }

    /* -----------------------------
        Bulk Delete
    ----------------------------- */

    public function confirmBulkDelete()
    {
        if (empty($this->selected)) return;

        $this->dispatch('modal-show', name: 'confirm-bulk-delete');
    }

    public function deleteSelected()
    {
        if (empty($this->selected)) return;

        $teachers = Teacher::with('user')
            ->whereIn('id', $this->selected)
            ->get();

        foreach ($teachers as $teacher) {
            $teacher->user()->delete();
        }

        $count = count($this->selected);

        $this->reset(['selected', 'selectAll']);

        session()->flash('message', "{$count} teachers deleted successfully.");
        $this->dispatch('modal-close', name: 'confirm-bulk-delete');
    }

    /* -----------------------------
        Events
    ----------------------------- */

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
        return view('livewire.teachers.teacher-index')
            ->layout('layouts.app');
    }
}