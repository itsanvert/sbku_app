<?php

namespace App\Livewire\Shifts;

use App\Models\Shift;
use Livewire\Component;
use Livewire\WithPagination;

class ShiftIndex extends Component
{
    use WithPagination;
    
    public function boot()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    private $firestore;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editShiftId = null;
    
    // Form fields
    public $name;

    protected $rules = [
        'name' => 'required|min:2',
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
        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->create('shifts', ['name' => $this->name]);
        } else {
            Shift::create([
                'name' => $this->name,
            ]);
        }
        $this->showCreateModal = false;
        session()->flash('message', 'Shift created successfully.');
    }

    public function edit($id)
    {
        $this->editShiftId = $id;
        if (\App\Services\FirestoreService::isActive()) {
            $shift = $this->firestore->getDocument('shifts', (string)$id);
            $this->name = $shift['name'] ?? '';
        } else {
            $shift = Shift::findOrFail($id);
            $this->name = $shift->name;
        }
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate();

        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->update('shifts', (string)$this->editShiftId, ['name' => $this->name]);
        } else {
            $shift = Shift::findOrFail($this->editShiftId);
            $shift->update([
                'name' => $this->name,
            ]);
        }

        $this->showEditModal = false;
        session()->flash('message', 'Shift updated successfully.');
    }

    public function delete($id)
    {
        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->delete('shifts', (string)$id);
        } else {
            Shift::findOrFail($id)->delete();
        }
        session()->flash('message', 'Shift deleted successfully.');
    }

    public function render()
    {
        if (\App\Services\FirestoreService::isActive()) {
            $shifts = $this->firestore->list('shifts');
            $collection = collect($shifts);
            if ($this->search) {
                $collection = $collection->filter(fn($s) => str_contains(strtolower($s['name'] ?? ''), strtolower($this->search)));
            }
            $items = $collection->forPage($this->getPage(), 10)->map(function($data) {
                $s = new Shift();
                $s->forceFill($data);
                $s->exists = true;
                return $s;
            });
            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $items, $collection->count(), 10, $this->getPage(), ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );
        } else {
            $paginated = Shift::where('name', 'like', '%' . $this->search . '%')->paginate(10);
        }

        return view('livewire.shifts.shift-index', [
            'shifts' => $paginated,
        ])->layout('layouts.app');
    }
}
