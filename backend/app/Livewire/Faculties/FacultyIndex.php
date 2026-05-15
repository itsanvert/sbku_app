<?php

namespace App\Livewire\Faculties;

use App\Models\Faculty;
use Livewire\Component;
use Livewire\WithPagination;

class FacultyIndex extends Component
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
        
        if (config('app.env') === 'production') {
            $this->firestore->create('faculties', [
                'name' => $this->name,
            ]);
        } else {
            Faculty::create([
                'name' => $this->name,
            ]);
        }
        
        $this->showCreateModal = false;
        session()->flash('message', 'Faculty created successfully.');
    }

    public function edit($id)
    {
        $this->editFacultyId = $id;
        
        if (config('app.env') === 'production') {
            $faculty = $this->firestore->getDocument('faculties', (string)$id);
            $this->name = $faculty['name'] ?? '';
        } else {
            $faculty = Faculty::findOrFail($id);
            $this->name = $faculty->name;
        }
        
        $this->showEditModal = true;
    }

    public function update()
    {
        if (config('app.env') === 'production') {
            $this->validate([
                'name' => 'required|min:3',
            ]);
            $this->firestore->update('faculties', (string)$this->editFacultyId, [
                'name' => $this->name,
            ]);
        } else {
            $this->validate([
                'name' => 'required|min:3|unique:faculties,name,' . $this->editFacultyId,
            ]);
            $faculty = Faculty::findOrFail($this->editFacultyId);
            $faculty->update([
                'name' => $this->name,
            ]);
        }

        $this->showEditModal = false;
        session()->flash('message', 'Faculty updated successfully.');
    }

    public function delete($id)
    {
        if (config('app.env') === 'production') {
            $this->firestore->delete('faculties', (string)$id);
        } else {
            Faculty::findOrFail($id)->delete();
        }
        session()->flash('message', 'Faculty deleted successfully.');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $faculties = $this->firestore->list('faculties');
            $collection = collect($faculties);
            if ($this->search) {
                $collection = $collection->filter(fn($f) => str_contains(strtolower($f['name'] ?? ''), strtolower($this->search)));
            }
            
            $items = $collection->forPage($this->getPage(), 10);
            
            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );
        } else {
            $paginated = Faculty::where('name', 'like', '%' . $this->search . '%')
                ->paginate(10);
        }

        return view('livewire.faculties.faculty-index', [
            'faculties' => $paginated,
        ])->layout('layouts.app');
    }
}
