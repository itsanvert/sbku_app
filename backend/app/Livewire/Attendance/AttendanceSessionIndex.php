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
    
    public function __construct()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    private $firestore;

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
        if (\App\Services\FirestoreService::isActive()) {
            $filters = [];
            if ($this->search) {
                // Firestore search is limited, but we can try to filter by teacher name if we stored it
                // For now, let's just fetch all and filter in memory if small, or just fetch all.
            }
            
            $sessions = $this->firestore->list('attendance_sessions', $filters, 'started_at', 'desc');
            
            // Convert to a collection for pagination
            $collection = collect($sessions);
            
            $items = $collection->forPage($this->getPage(), 10)->map(function ($data) {
                $sess = new AttendanceSession();
                $sess->forceFill($data);
                $sess->exists = true;

                // 1. Mock Teacher relationship
                $t = new \App\Models\Teacher();
                $t->forceFill([
                    'id'   => $data['teacher_id'] ?? null,
                    'name' => $data['teacher_name'] ?? '—',
                ]);
                
                $u = new \App\Models\User();
                $u->forceFill([
                    'id'   => $data['user_id'] ?? null,
                    'name' => $data['teacher_name'] ?? '—',
                ]);
                $t->setRelation('user', $u);
                $sess->setRelation('teacher', $t);

                // 2. Mock Other relationships
                $fac = new \App\Models\Faculty();
                $fac->forceFill(['id' => $data['faculty_id'] ?? null, 'name' => $data['faculty_name'] ?? '—']);
                $sess->setRelation('faculty', $fac);

                $maj = new \App\Models\Major();
                $maj->forceFill(['id' => $data['major_id'] ?? null, 'name' => $data['major_name'] ?? '—']);
                $sess->setRelation('major', $maj);

                $ac = new \App\Models\AcademicClass();
                $ac->forceFill(['id' => $data['academic_class_id'] ?? null, 'name' => $data['academic_class_name'] ?? '—']);
                $sess->setRelation('academicClass', $ac);

                return $sess;
            });
            
            return new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );
        }

        return AttendanceSession::with(['teacher.user', 'faculty', 'major', 'academicClass', 'schedule', 'shift'])
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
        if (!empty($this->selected)) {
            if (\App\Services\FirestoreService::isActive()) {
                foreach ($this->selected as $id) {
                    $this->firestore->delete('attendance_sessions', (string)$id);
                }
            } else {
                AttendanceSession::whereIn('id', $this->selected)->delete();
            }
            $this->selected = [];
            $this->selectAll = false;
            session()->flash('message', 'Sessions deleted successfully.');
        }
    }

    public function render()
    {
        return view('livewire.attendance.attendance-session-index', [
            'sessions' => $this->sessions
        ]);
    }
}
