<?php

namespace App\Livewire\Faculties;

use App\Models\Faculty;
use Livewire\Component;
use Livewire\WithPagination;

class FacultyIndex extends Component
{
    use WithPagination;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editFacultyId = null;
    
    // Form fields
    public $name;

    protected $rules = [
        'name' => 'required|min:3|unique:faculties,name',
    ];

    public function updatingSearch() { $this->resetPage(); }

    public function openCreateModal()
    {
        $this->reset(['name']);
        $this->showCreateModal = true;
    }

    public function store()
    {
        $this->validate();
        Faculty::create([
            'name' => $this->name,
        ]);
        $this->showCreateModal = false;
        session()->flash('message', 'Faculty created successfully.');
    }

    public function edit($id)
    {
        $this->editFacultyId = $id;
        $faculty = Faculty::findOrFail($id);
        $this->name = $faculty->name;
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate([
            'name' => 'required|min:3|unique:faculties,name,' . $this->editFacultyId,
        ]);

        $faculty = Faculty::findOrFail($this->editFacultyId);
        $faculty->update([
            'name' => $this->name,
        ]);

        $this->showEditModal = false;
        session()->flash('message', 'Faculty updated successfully.');
    }

    public function delete($id)
    {
        Faculty::findOrFail($id)->delete();
        session()->flash('message', 'Faculty deleted successfully.');
    }

    public function render()
    {
        return view('livewire.faculties.faculty-index', [
            'faculties' => Faculty::where('name', 'like', '%' . $this->search . '%')
                ->paginate(10),
        ])->layout('layouts.app');
    }
}
