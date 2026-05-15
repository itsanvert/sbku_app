<?php

namespace App\Livewire\Subjects;

use App\Models\Subject;
use Livewire\Component;
use Livewire\WithPagination;

class SubjectIndex extends Component
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
        if (config('app.env') === 'production') {
            $this->validate([
                'name' => 'required|min:3',
                'code' => 'required',
                'credit_hours' => 'required|integer|min:1',
            ]);
            $this->firestore->create('subjects', [
                'name' => $this->name,
                'code' => $this->code,
                'credit_hours' => $this->credit_hours,
            ]);
        } else {
            $this->validate();
            Subject::create([
                'name' => $this->name,
                'code' => $this->code,
                'credit_hours' => $this->credit_hours,
            ]);
        }
        $this->showCreateModal = false;
        session()->flash('message', 'Subject created successfully.');
    }

    public function edit($id)
    {
        $this->editSubjectId = $id;
        
        if (config('app.env') === 'production') {
            $subject = $this->firestore->getDocument('subjects', (string)$id);
            $this->name = $subject['name'] ?? '';
            $this->code = $subject['code'] ?? '';
            $this->credit_hours = $subject['credit_hours'] ?? 3;
        } else {
            $subject = Subject::findOrFail($id);
            $this->name = $subject->name;
            $this->code = $subject->code;
            $this->credit_hours = $subject->credit_hours;
        }
        
        $this->showEditModal = true;
    }

    public function update()
    {
        if (config('app.env') === 'production') {
            $this->validate([
                'name' => 'required|min:3',
                'code' => 'required',
                'credit_hours' => 'required|integer|min:1',
            ]);
            $this->firestore->update('subjects', (string)$this->editSubjectId, [
                'name' => $this->name,
                'code' => $this->code,
                'credit_hours' => $this->credit_hours,
            ]);
        } else {
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
        }

        $this->showEditModal = false;
        session()->flash('message', 'Subject updated successfully.');
    }

    public function delete($id)
    {
        if (config('app.env') === 'production') {
            $this->firestore->delete('subjects', (string)$id);
        } else {
            Subject::findOrFail($id)->delete();
        }
        session()->flash('message', 'Subject deleted successfully.');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $subjects = $this->firestore->list('subjects');
            $collection = collect($subjects);
            if ($this->search) {
                $collection = $collection->filter(fn($s) => 
                    str_contains(strtolower($s['name'] ?? ''), strtolower($this->search)) ||
                    str_contains(strtolower($s['code'] ?? ''), strtolower($this->search))
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
        } else {
            $paginated = Subject::where('name', 'like', '%' . $this->search . '%')
                ->orWhere('code', 'like', '%' . $this->search . '%')
                ->paginate(10);
        }

        return view('livewire.subjects.subject-index', [
            'subjects' => $paginated,
        ])->layout('layouts.app');
    }
}
