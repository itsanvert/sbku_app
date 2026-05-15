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
    
    public function __construct()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    private $firestore;

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
            $studentId = is_array($user->student) ? $user->student['id'] : $user->student?->id;
            $query->where('student_id', $studentId);
        } elseif ($user->role === 'teacher') {
            $teacherId = is_array($user->teacher) ? $user->teacher['id'] : $user->teacher?->id;
            $query->whereHas('session', function($q) use ($teacherId) {
                $q->where('teacher_id', $teacherId);
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
        if (config('app.env') === 'production') {
            $user = auth()->user();
            $filters = [];
            
            if ($user->role === 'student') {
                $filters['student_id'] = is_array($user->student) ? $user->student['id'] : $user->student?->id;
            } elseif ($user->role === 'teacher') {
                $filters['teacher_id'] = is_array($user->teacher) ? $user->teacher['id'] : $user->teacher?->id;
            }

            if ($this->filterDate) $filters['attendance_date'] = $this->filterDate;
            
            $records = $this->firestore->list('attendances', $filters, 'attendance_date', 'desc');
            
            // In-memory filtering for month/year if needed (Firestore doesn't support partial date filters easily without dedicated fields)
            $collection = collect($records);
            
            if ($this->filterMonth) {
                $collection = $collection->filter(fn($r) => \Carbon\Carbon::parse($r['attendance_date'])->month == $this->filterMonth);
            }
            if ($this->filterYear) {
                $collection = $collection->filter(fn($r) => \Carbon\Carbon::parse($r['attendance_date'])->year == $this->filterYear);
            }

            $items = $collection->forPage($this->getPage(), 20);
            
            return new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                20,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );
        }

        return $this->getBaseQuery()->paginate(20);
    }

    public function exportPdf()
    {
        if (config('app.env') === 'production') {
            $user = auth()->user();
            $filters = [];
            if ($user->role === 'student') $filters['student_id'] = is_array($user->student) ? $user->student['id'] : $user->student?->id;
            elseif ($user->role === 'teacher') $filters['teacher_id'] = is_array($user->teacher) ? $user->teacher['id'] : $user->teacher?->id;
            if ($this->filterDate) $filters['attendance_date'] = $this->filterDate;

            $records = collect($this->firestore->list('attendances', $filters));
            if ($this->filterMonth) $records = $records->filter(fn($r) => \Carbon\Carbon::parse($r['attendance_date'])->month == $this->filterMonth);
            if ($this->filterYear) $records = $records->filter(fn($r) => \Carbon\Carbon::parse($r['attendance_date'])->year == $this->filterYear);
            
            // Map to Models for the PDF view
            $records = $records->map(function($data) {
                $a = new Attendance();
                $a->forceFill($data);
                $a->exists = true;
                return $a;
            });
        } else {
            $records = $this->getBaseQuery()->get();
        }
        
        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('exports.attendance-pdf', [
            'records'    => $records,
            'reportedBy' => auth()->user()?->name ?? 'System',
            'filterInfo' => collect([
                $this->filterDate  ? 'Date: ' . $this->filterDate   : null,
                $this->filterMonth ? 'Month: ' . $this->filterMonth  : null,
                $this->filterYear  ? 'Year: ' . $this->filterYear    : null,
                $this->search      ? 'Search: ' . $this->search      : null,
            ])->filter()->implode(' | ') ?: 'All records',
        ]);
        
        return response()->streamDownload(
            fn () => print($pdf->output()),
            'attendance-records.pdf'
        );
    }

    public function exportExcel()
    {
        if (config('app.env') === 'production') {
            $user = auth()->user();
            $filters = [];
            if ($user->role === 'student') $filters['student_id'] = is_array($user->student) ? $user->student['id'] : $user->student?->id;
            elseif ($user->role === 'teacher') $filters['teacher_id'] = is_array($user->teacher) ? $user->teacher['id'] : $user->teacher?->id;
            if ($this->filterDate) $filters['attendance_date'] = $this->filterDate;

            $records = collect($this->firestore->list('attendances', $filters));
            if ($this->filterMonth) $records = $records->filter(fn($r) => \Carbon\Carbon::parse($r['attendance_date'])->month == $this->filterMonth);
            if ($this->filterYear) $records = $records->filter(fn($r) => \Carbon\Carbon::parse($r['attendance_date'])->year == $this->filterYear);
            
            $ids = $records->pluck('id')->toArray();
        } else {
            $ids = $this->getBaseQuery()->pluck('id')->toArray();
        }
        
        session([
            'attendance_export_ids' => $ids,
            'attendance_export_filter' => collect([
                $this->filterDate ? 'Date: ' . $this->filterDate : null,
                $this->filterMonth ? 'Month: ' . $this->filterMonth : null,
                $this->filterYear ? 'Year: ' . $this->filterYear : null,
                $this->search ? 'Search: ' . $this->search : null,
            ])->filter()->implode(' | ') ?: 'All records'
        ]);
        
        return $this->redirect(route('attendance.export.excel'), navigate: false);
    }

    public function render()
    {
        return view('livewire.attendance.attendance-index', [
            'records' => $this->records
        ]);
    }
}
