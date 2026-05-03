<?php

namespace App\Livewire\Shifts;

use App\Models\Shift;
use Livewire\Component;
use Livewire\WithPagination;

class ShiftIndex extends Component
{
    use WithPagination;

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
        Shift::create([
            'name' => $this->name,
        ]);
        $this->showCreateModal = false;
        session()->flash('message', 'Shift created successfully.');
    }

    public function edit($id)
    {
        $this->editShiftId = $id;
        $shift = Shift::findOrFail($id);
        $this->name = $shift->name;
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate();

        $shift = Shift::findOrFail($this->editShiftId);
        $shift->update([
            'name' => $this->name,
        ]);

        $this->showEditModal = false;
        session()->flash('message', 'Shift updated successfully.');
    }

    public function delete($id)
    {
        Shift::findOrFail($id)->delete();
        session()->flash('message', 'Shift deleted successfully.');
    }

    public function render()
    {
        return view('livewire.shifts.shift-index', [
            'shifts' => Shift::where('name', 'like', '%' . $this->search . '%')
                ->paginate(10),
        ])->layout('layouts.app');
    }
}
