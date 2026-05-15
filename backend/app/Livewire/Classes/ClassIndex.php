<?php

namespace App\Livewire\Classes;

use App\Models\AcademicClass;
use App\Models\Major;
use Livewire\Component;
use Livewire\WithPagination;

class ClassIndex extends Component
{
    use WithPagination;
    
    public function __construct()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    private $firestore;

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
        if (config('app.env') === 'production') {
            $this->validate([
                'name' => 'required|min:2',
                'code' => 'required',
                'major_id' => 'required',
                'academic_year' => 'required',
                'semester' => 'required|integer|min:1|max:2',
            ]);
            $this->firestore->create('academic_classes', [
                'name' => $this->name,
                'code' => $this->code,
                'major_id' => $this->major_id,
                'academic_year' => $this->academic_year,
                'semester' => $this->semester,
            ]);
        } else {
            $this->validate();
            AcademicClass::create([
                'name' => $this->name,
                'code' => $this->code,
                'major_id' => $this->major_id,
                'academic_year' => $this->academic_year,
                'semester' => $this->semester,
            ]);
        }
        $this->showCreateModal = false;
        session()->flash('message', 'Class created successfully.');
    }

    public function edit($id)
    {
        $this->editClassId = $id;
        
        if (config('app.env') === 'production') {
            $class = $this->firestore->getDocument('academic_classes', (string)$id);
            $this->name = $class['name'] ?? '';
            $this->code = $class['code'] ?? '';
            $this->major_id = $class['major_id'] ?? '';
            $this->academic_year = $class['academic_year'] ?? '';
            $this->semester = $class['semester'] ?? 1;
        } else {
            $class = AcademicClass::findOrFail($id);
            $this->name = $class->name;
            $this->code = $class->code;
            $this->major_id = $class->major_id;
            $this->academic_year = $class->academic_year;
            $this->semester = $class->semester;
        }
        
        $this->showEditModal = true;
    }

    public function update()
    {
        if (config('app.env') === 'production') {
            $this->validate([
                'name' => 'required|min:2',
                'code' => 'required',
                'major_id' => 'required',
                'academic_year' => 'required',
                'semester' => 'required|integer|min:1|max:2',
            ]);
            $this->firestore->update('academic_classes', (string)$this->editClassId, [
                'name' => $this->name,
                'code' => $this->code,
                'major_id' => $this->major_id,
                'academic_year' => $this->academic_year,
                'semester' => $this->semester,
            ]);
        } else {
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
        }

        $this->showEditModal = false;
        session()->flash('message', 'Class updated successfully.');
    }

    public function delete($id)
    {
        if (config('app.env') === 'production') {
            $this->firestore->delete('academic_classes', (string)$id);
        } else {
            AcademicClass::findOrFail($id)->delete();
        }
        session()->flash('message', 'Class deleted successfully.');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $classes = $this->firestore->list('academic_classes');
            $collection = collect($classes);
            if ($this->search) {
                $collection = $collection->filter(fn($c) => 
                    str_contains(strtolower($c['name'] ?? ''), strtolower($this->search)) ||
                    str_contains(strtolower($c['code'] ?? ''), strtolower($this->search))
                );
            }
            
            $items = $collection->forPage($this->getPage(), 10);
            
            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );

            return view('livewire.classes.class-index', [
                'classes' => $paginated,
                'majors' => collect($this->firestore->list('majors'))->map(function($data) {
                    $m = new Major();
                    $m->forceFill($data);
                    $m->exists = true;
                    return $m;
                })->sortBy('name'),
            ])->layout('layouts.app');
        }

        return view('livewire.classes.class-index', [
            'classes' => AcademicClass::with('major.faculty')
                ->where('name', 'like', '%' . $this->search . '%')
                ->orWhere('code', 'like', '%' . $this->search . '%')
                ->paginate(10),
            'majors' => Major::orderBy('name')->get(),
        ])->layout('layouts.app');
    }
}
