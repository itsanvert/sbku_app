<?php

namespace App\Livewire\Majors;

use App\Models\Major;
use App\Models\Faculty;
use Livewire\Component;
use Livewire\WithPagination;

class MajorIndex extends Component
{
    use WithPagination;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editMajorId = null;
    
    // Form fields
    public $name;
    public $faculty_id;

    protected $rules = [
        'name' => 'required|min:3',
        'faculty_id' => 'required|exists:faculties,id',
    ];

    public function updatingSearch() { $this->resetPage(); }

    public function openCreateModal()
    {
        $this->reset(['name', 'faculty_id']);
        $this->showCreateModal = true;
    }

    public function store()
    {
        $this->validate();
        Major::create([
            'name' => $this->name,
            'faculty_id' => $this->faculty_id,
        ]);
        $this->showCreateModal = false;
        session()->flash('message', 'Major created successfully.');
    }

    public function edit($id)
    {
        $this->editMajorId = $id;
        $major = Major::findOrFail($id);
        $this->name = $major->name;
        $this->faculty_id = $major->faculty_id;
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate();

        $major = Major::findOrFail($this->editMajorId);
        $major->update([
            'name' => $this->name,
            'faculty_id' => $this->faculty_id,
        ]);

        $this->showEditModal = false;
        session()->flash('message', 'Major updated successfully.');
    }

    public function delete($id)
    {
        Major::findOrFail($id)->delete();
        session()->flash('message', 'Major deleted successfully.');
    }

    public function render()
    {
        return view('livewire.majors.major-index', [
            'majors' => Major::with('faculty')
                ->where('name', 'like', '%' . $this->search . '%')
                ->paginate(10),
            'faculties' => Faculty::orderBy('name')->get(),
        ])->layout('layouts.app');
    }
}
