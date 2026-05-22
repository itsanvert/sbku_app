<?php

namespace App\Livewire\Rooms;

use App\Models\Room;
use Livewire\Component;
use Livewire\WithPagination;

class RoomIndex extends Component
{
    use WithPagination;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editRoomId = null;

    public $name;
    public $code;

    protected $rules = [
        'name' => 'required|min:2',
        'code' => 'nullable|string|max:50',
    ];

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function openCreateModal()
    {
        $this->reset(['name', 'code']);
        $this->showCreateModal = true;
    }

    public function store()
    {
        $this->validate();
        Room::create([
            'name' => $this->name,
            'code' => $this->code,
        ]);
        $this->showCreateModal = false;
        session()->flash('message', 'Room created successfully.');
    }

    public function edit($id)
    {
        $this->editRoomId = $id;
        $room = Room::findOrFail($id);
        $this->name = $room->name;
        $this->code = $room->code;
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate();
        $room = Room::findOrFail($this->editRoomId);
        $room->update([
            'name' => $this->name,
            'code' => $this->code,
        ]);
        $this->showEditModal = false;
        session()->flash('message', 'Room updated successfully.');
    }

    public function delete($id)
    {
        Room::findOrFail($id)->delete();
        session()->flash('message', 'Room deleted successfully.');
    }

    public function render()
    {
        $rooms = Room::where('name', 'like', '%' . $this->search . '%')
            ->orWhere('code', 'like', '%' . $this->search . '%')
            ->paginate(10);

        return view('livewire.rooms.room-index', [
            'rooms' => $rooms,
        ])->layout('layouts.app');
    }
}
