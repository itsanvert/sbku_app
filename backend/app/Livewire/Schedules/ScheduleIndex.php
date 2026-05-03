<?php

namespace App\Livewire\Schedules;

use App\Models\Schedule;
use Livewire\Component;
use Livewire\WithPagination;

class ScheduleIndex extends Component
{
    use WithPagination;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editScheduleId = null;
    
    // Form fields
    public $name;
    public $day_of_the_week;
    public $start_time;
    public $end_time;

    protected $rules = [
        'name' => 'required|min:2',
        'day_of_the_week' => 'nullable|string',
        'start_time' => 'nullable',
        'end_time' => 'nullable',
    ];

    public function updatingSearch() { $this->resetPage(); }

    public function openCreateModal()
    {
        $this->reset(['name', 'day_of_the_week', 'start_time', 'end_time']);
        $this->showCreateModal = true;
    }

    public function store()
    {
        $this->validate();
        Schedule::create([
            'name' => $this->name,
            'day_of_the_week' => $this->day_of_the_week,
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
        ]);
        $this->showCreateModal = false;
        session()->flash('message', 'Schedule created successfully.');
    }

    public function edit($id)
    {
        $this->editScheduleId = $id;
        $schedule = Schedule::findOrFail($id);
        $this->name = $schedule->name;
        $this->day_of_the_week = $schedule->day_of_the_week;
        // Format times for input[type="time"] if they are Carbon objects
        $this->start_time = $schedule->start_time ? $schedule->start_time->format('H:i') : null;
        $this->end_time = $schedule->end_time ? $schedule->end_time->format('H:i') : null;
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate();

        $schedule = Schedule::findOrFail($this->editScheduleId);
        $schedule->update([
            'name' => $this->name,
            'day_of_the_week' => $this->day_of_the_week,
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
        ]);

        $this->showEditModal = false;
        session()->flash('message', 'Schedule updated successfully.');
    }

    public function delete($id)
    {
        Schedule::findOrFail($id)->delete();
        session()->flash('message', 'Schedule deleted successfully.');
    }

    public function render()
    {
        return view('livewire.schedules.schedule-index', [
            'schedules' => Schedule::where('name', 'like', '%' . $this->search . '%')
                ->orWhere('day_of_the_week', 'like', '%' . $this->search . '%')
                ->paginate(10),
        ])->layout('layouts.app');
    }
}
