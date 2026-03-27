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
        $query = Attendance::with(['student.user', 'session.teacher.user', 'session.faculty', 'session.major']);

        $user = auth()->user();

        // Role-based filtering
        if ($user->role === 'student') {
            $query->where('student_id', $user->student->id);
        } elseif ($user->role === 'teacher') {
            $query->whereHas('session', function($q) use ($user) {
                $q->where('teacher_id', $user->teacher->id);
            });
        }
        // Super Admin and Admin can see all records.

        return $query->when($this->search, function ($query) {
                $query->whereHas('student.user', function($q) {
                    $q->where('name', 'like', "%{$this->search}%");
                });
            })
            ->latest()
            ->paginate(20);
    }

    public function exportPdf()
    {
        $records = $this->records;
        // Logic to generate PDF using Barryvdh\DomPDF
        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('exports.attendance-pdf', ['records' => $records]);
        return response()->streamDownload(fn () => print($pdf->output()), 'attendance-records.pdf');
    }

    public function exportExcel()
    {
        // Logic to generate Excel using Maatwebsite\Excel
        return \Maatwebsite\Excel\Facades\Excel::download(new \App\Exports\AttendanceExport($this->records), 'attendance-records.xlsx');
    }

    public function render()
    {
        return view('livewire.attendance.attendance-index', [
            'records' => $this->records
        ]);
    }
}
