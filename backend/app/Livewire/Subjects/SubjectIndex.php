<?php

namespace App\Livewire\Subjects;

use App\Models\Subject;
use Livewire\Component;
use Livewire\WithPagination;

class SubjectIndex extends Component
{
    use WithPagination;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editSubjectId = null;
    
    // Form fields
    public $name;
    public $code;
    public $credit_hours = 3;

    protected $rules = [
        'name' => 'required|min:3',
        'code' => 'required|unique:subjects,code',
        'credit_hours' => 'required|integer|min:1',
    ];

    public function updatingSearch() { $this->resetPage(); }

    public function openCreateModal()
    {
        $this->reset(['name', 'code', 'credit_hours']);
        $this->showCreateModal = true;
    }

    public function store()
    {
        $this->validate();
        Subject::create([
            'name' => $this->name,
            'code' => $this->code,
            'credit_hours' => $this->credit_hours,
        ]);
        $this->showCreateModal = false;
        session()->flash('message', 'Subject created successfully.');
    }

    public function edit($id)
    {
        $this->editSubjectId = $id;
        $subject = Subject::findOrFail($id);
        $this->name = $subject->name;
        $this->code = $subject->code;
        $this->credit_hours = $subject->credit_hours;
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate([
            'name' => 'required|min:3',
            'code' => 'required|unique:subjects,code,' . $this->editSubjectId,
            'credit_hours' => 'required|integer|min:1',
        ]);

        $subject = Subject::findOrFail($this->editSubjectId);
        $subject->update([
            'name' => $this->name,
            'code' => $this->code,
            'credit_hours' => $this->credit_hours,
        ]);

        $this->showEditModal = false;
        session()->flash('message', 'Subject updated successfully.');
    }

    public function delete($id)
    {
        Subject::findOrFail($id)->delete();
        session()->flash('message', 'Subject deleted successfully.');
    }

    public function render()
    {
        return view('livewire.subjects.subject-index', [
            'subjects' => Subject::where('name', 'like', '%' . $this->search . '%')
                ->orWhere('code', 'like', '%' . $this->search . '%')
                ->paginate(10),
        ])->layout('layouts.app');
    }
}
