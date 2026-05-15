<?php

namespace App\Livewire\Majors;

use App\Models\Major;
use App\Models\Faculty;
use Livewire\Component;
use Livewire\WithPagination;

class MajorIndex extends Component
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
        if (config('app.env') === 'production') {
            $this->validate([
                'name' => 'required|min:3',
                'faculty_id' => 'required',
            ]);
            $this->firestore->create('majors', [
                'name' => $this->name,
                'faculty_id' => $this->faculty_id,
            ]);
        } else {
            $this->validate();
            Major::create([
                'name' => $this->name,
                'faculty_id' => $this->faculty_id,
            ]);
        }
        $this->showCreateModal = false;
        session()->flash('message', 'Major created successfully.');
    }

    public function edit($id)
    {
        $this->editMajorId = $id;
        
        if (config('app.env') === 'production') {
            $major = $this->firestore->getDocument('majors', (string)$id);
            $this->name = $major['name'] ?? '';
            $this->faculty_id = $major['faculty_id'] ?? '';
        } else {
            $major = Major::findOrFail($id);
            $this->name = $major->name;
            $this->faculty_id = $major->faculty_id;
        }
        
        $this->showEditModal = true;
    }

    public function update()
    {
        if (config('app.env') === 'production') {
            $this->validate([
                'name' => 'required|min:3',
                'faculty_id' => 'required',
            ]);
            $this->firestore->update('majors', (string)$this->editMajorId, [
                'name' => $this->name,
                'faculty_id' => $this->faculty_id,
            ]);
        } else {
            $this->validate();
            $major = Major::findOrFail($this->editMajorId);
            $major->update([
                'name' => $this->name,
                'faculty_id' => $this->faculty_id,
            ]);
        }

        $this->showEditModal = false;
        session()->flash('message', 'Major updated successfully.');
    }

    public function delete($id)
    {
        if (config('app.env') === 'production') {
            $this->firestore->delete('majors', (string)$id);
        } else {
            Major::findOrFail($id)->delete();
        }
        session()->flash('message', 'Major deleted successfully.');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $majors = $this->firestore->list('majors');
            $collection = collect($majors);
            if ($this->search) {
                $collection = $collection->filter(fn($m) => str_contains(strtolower($m['name'] ?? ''), strtolower($this->search)));
            }
            
            $items = $collection->forPage($this->getPage(), 10)->map(function ($data) {
                // Separate relations from attributes
                $facultyData = [
                    'id'   => $data['faculty_id'] ?? null,
                    'name' => $data['faculty_name'] ?? '—',
                ];

                // Remove potentially conflicting keys
                $cleanData = array_diff_key($data, array_flip(['faculty']));

                $m = new Major();
                $m->forceFill($cleanData);
                $m->exists = true;

                // Mock Faculty relationship
                $m->setRelation('faculty', (new \App\Models\Faculty())->forceFill($facultyData));

                return $m;
            });
            
            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );

            return view('livewire.majors.major-index', [
                'majors' => $paginated,
                'faculties' => collect($this->firestore->list('faculties'))->map(function($data) {
                    $f = new Faculty();
                    $f->forceFill($data);
                    $f->exists = true;
                    return $f;
                })->sortBy('name'),
            ])->layout('layouts.app');
        }

        return view('livewire.majors.major-index', [
            'majors' => Major::with('faculty')
                ->where('name', 'like', '%' . $this->search . '%')
                ->paginate(10),
            'faculties' => Faculty::orderBy('name')->get(),
        ])->layout('layouts.app');
    }
}
