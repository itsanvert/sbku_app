<?php

namespace App\Livewire\Attendance;

use Livewire\Component;
use Livewire\WithPagination;
use App\Models\AttendanceSession;
use Livewire\Attributes\Layout;

#[Layout('layouts.app')]
class AttendanceSessionIndex extends Component
{
    use WithPagination;

    public $search = '';
    public $selectAll = false;
    public $selected = [];

    protected $queryString = [
        'search' => ['except' => ''],
    ];

    public function updatedSelectAll($value)
    {
        if ($value) {
            $this->selected = $this->sessions->pluck('id')->map(fn($id) => (string) $id)->toArray();
        } else {
            $this->selected = [];
        }
    }

    public function updatedSelected()
    {
        $this->selectAll = count($this->selected) === $this->sessions->count();
    }

    public function getSessionsProperty()
    {
        return AttendanceSession::with(['teacher.user', 'faculty', 'major', 'schedule'])
            ->withCount('attendances')
            ->when($this->search, function ($query) {
                // simple search
                $query->whereHas('teacher.user', function($q) {
                    $q->where('name', 'like', "%{$this->search}%");
                });
            })
            ->latest('started_at')
            ->paginate(10);
    }

    public function deleteSelected()
    {
        AttendanceSession::whereIn('id', $this->selected)->delete();
        $this->selected = [];
        $this->selectAll = false;
        session()->flash('message', 'Sessions deleted successfully.');
    }

    public function render()
    {
        return view('livewire.attendance.attendance-session-index', [
            'sessions' => $this->sessions
        ]);
    }
}
