<?php

namespace App\Livewire\Classes;

use App\Models\AcademicClass;
use App\Models\Major;
use Livewire\Component;
use Livewire\WithPagination;

class ClassIndex extends Component
{
    use WithPagination;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editClassId = null;
    
    // Form fields
    public $name;
    public $code;
    public $major_id;
    public $academic_year;
    public $semester = 1;

    protected $rules = [
        'name' => 'required|min:2',
        'code' => 'required|unique:academic_classes,code',
        'major_id' => 'required|exists:majors,id',
        'academic_year' => 'required',
        'semester' => 'required|integer|min:1|max:2',
    ];

    public function updatingSearch() { $this->resetPage(); }

    public function openCreateModal()
    {
        $this->reset(['name', 'code', 'major_id', 'academic_year', 'semester']);
        $this->showCreateModal = true;
    }

    public function store()
    {
        $this->validate();
        AcademicClass::create([
            'name' => $this->name,
            'code' => $this->code,
            'major_id' => $this->major_id,
            'academic_year' => $this->academic_year,
            'semester' => $this->semester,
        ]);
        $this->showCreateModal = false;
        session()->flash('message', 'Class created successfully.');
    }

    public function edit($id)
    {
        $this->editClassId = $id;
        $class = AcademicClass::findOrFail($id);
        $this->name = $class->name;
        $this->code = $class->code;
        $this->major_id = $class->major_id;
        $this->academic_year = $class->academic_year;
        $this->semester = $class->semester;
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate([
            'name' => 'required|min:2',
            'code' => 'required|unique:academic_classes,code,' . $this->editClassId,
            'major_id' => 'required|exists:majors,id',
            'academic_year' => 'required',
            'semester' => 'required|integer|min:1|max:2',
        ]);

        $class = AcademicClass::findOrFail($this->editClassId);
        $class->update([
            'name' => $this->name,
            'code' => $this->code,
            'major_id' => $this->major_id,
            'academic_year' => $this->academic_year,
            'semester' => $this->semester,
        ]);

        $this->showEditModal = false;
        session()->flash('message', 'Class updated successfully.');
    }

    public function delete($id)
    {
        AcademicClass::findOrFail($id)->delete();
        session()->flash('message', 'Class deleted successfully.');
    }

    public function render()
    {
        return view('livewire.classes.class-index', [
            'classes' => AcademicClass::with('major.faculty')
                ->where('name', 'like', '%' . $this->search . '%')
                ->orWhere('code', 'like', '%' . $this->search . '%')
                ->paginate(10),
            'majors' => Major::orderBy('name')->get(),
        ])->layout('layouts.app');
    }
}
