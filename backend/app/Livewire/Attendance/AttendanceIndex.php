<?php

namespace App\Livewire\Attendance;

use Livewire\Component;
use Livewire\WithPagination;
use App\Models\Attendance;
use Livewire\Attributes\Layout;

#[Layout('layouts.app')]
class AttendanceIndex extends Component
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
            $this->selected = $this->records->pluck('id')->map(fn($id) => (string) $id)->toArray();
        } else {
            $this->selected = [];
        }
    }

    public function updatedSelected()
    {
        $this->selectAll = count($this->selected) === $this->records->count();
    }

    public function getRecordsProperty()
    {
        return Attendance::with(['student.user', 'session.teacher.user'])
            ->when($this->search, function ($query) {
                // simple search
                $query->whereHas('student.user', function($q) {
                    $q->where('name', 'like', "%{$this->search}%");
                });
            })
            ->latest()
            ->paginate(20);
    }

    public function render()
    {
        return view('livewire.attendance.attendance-index', [
            'records' => $this->records
        ]);
    }
}
