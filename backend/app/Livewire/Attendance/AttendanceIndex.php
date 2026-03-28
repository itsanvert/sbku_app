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
    public $filterDate = '';
    public $filterMonth = '';
    public $filterYear = '';
    public $selectAll = false;
    public $selected = [];

    protected $queryString = [
        'search' => ['except' => ''],
        'filterDate' => ['except' => ''],
        'filterMonth' => ['except' => ''],
        'filterYear' => ['except' => ''],
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

    protected function getBaseQuery()
    {
        $query = Attendance::with([
            'student.user',
            'student.faculty',
            'student.major',
            'session.teacher.user',
            'session.faculty',
            'session.major',
        ]);

        $user = auth()->user();

        // Role-based filtering
        if ($user->role === 'student') {
            $query->where('student_id', $user->student->id);
        } elseif ($user->role === 'teacher') {
            $query->whereHas('session', function($q) use ($user) {
                $q->where('teacher_id', $user->teacher->id);
            });
        }

        return $query->when($this->search, function ($query) {
                $query->whereHas('student.user', function($q) {
                    $q->where('name', 'like', "%{$this->search}%");
                });
            })
            ->when($this->filterDate, fn($q) => $q->whereDate('attendance_date', $this->filterDate))
            ->when($this->filterMonth, fn($q) => $q->whereMonth('attendance_date', $this->filterMonth))
            ->when($this->filterYear, fn($q) => $q->whereYear('attendance_date', $this->filterYear))
            ->latest();
    }

    public function getRecordsProperty()
    {
        return $this->getBaseQuery()->paginate(20);
    }

    public function exportPdf()
    {
        // Get ALL filtered records (not just current page)
        $records = $this->getBaseQuery()->get();
        
        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('exports.attendance-pdf', ['records' => $records]);
        
        return response()->streamDownload(
            fn () => print($pdf->output()),
            'attendance-records.pdf'
        );
    }

    public function exportExcel()
    {
        // Get ALL filtered IDs
        $ids = $this->getBaseQuery()->pluck('id')->toArray();
        
        session(['attendance_export_ids' => $ids]);
        
        return $this->redirect(route('attendance.export.excel'), navigate: false);
    }

    public function render()
    {
        return view('livewire.attendance.attendance-index', [
            'records' => $this->records
        ]);
    }
}
