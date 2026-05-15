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
                // Separate relations from attributes
                $teacherUserData = [
                    'id'   => $data['user_id'] ?? null,
                    'name' => $data['teacher_name'] ?? '—',
                ];
                $teacherData = [
                    'id'   => $data['teacher_id'] ?? null,
                    'name' => $data['teacher_name'] ?? '—',
                ];
                $facultyData = [
                    'id' => $data['faculty_id'] ?? null, 
                    'name' => $data['faculty_name'] ?? '—'
                ];
                $majorData = [
                    'id' => $data['major_id'] ?? null, 
                    'name' => $data['major_name'] ?? '—'
                ];
                $acData = [
                    'id' => $data['academic_class_id'] ?? null, 
                    'name' => $data['academic_class_name'] ?? '—'
                ];
                $shiftData = [
                    'id' => $data['shift_id'] ?? null,
                    'name' => $data['shift_name'] ?? '—',
                ];
                $scheduleData = [
                    'id' => $data['schedule_id'] ?? null,
                    'full_display' => $data['schedule_display'] ?? '—',
                ];
                $roomData = [
                    'id' => $data['room_id'] ?? null,
                    'name' => $data['room_name'] ?? '—',
                ];

                // Remove potentially conflicting keys
                $cleanData = array_diff_key($data, array_flip(['teacher', 'faculty', 'major', 'academicClass', 'shift', 'schedule', 'room']));

                $sess = new AttendanceSession();
                $sess->forceFill($cleanData);
                
                // Cast dates
                if (isset($data['started_at'])) {
                    $sess->started_at = \Carbon\Carbon::parse($data['started_at']);
                }
                if (isset($data['expires_at'])) {
                    $sess->expires_at = \Carbon\Carbon::parse($data['expires_at']);
                }
                
                $sess->exists = true;

                // 1. Mock Teacher relationship
                $t = (new \App\Models\Teacher())->forceFill($teacherData);
                $u = (new \App\Models\User())->forceFill($teacherUserData);
                $t->setRelation('user', $u);
                $sess->setRelation('teacher', $t);

                // 2. Mock Other relationships
                $sess->setRelation('faculty', (new \App\Models\Faculty())->forceFill($facultyData));
                $sess->setRelation('major', (new \App\Models\Major())->forceFill($majorData));
                $sess->setRelation('academicClass', (new \App\Models\AcademicClass())->forceFill($acData));
                $sess->setRelation('shift', (new \App\Models\Shift())->forceFill($shiftData));
                $sess->setRelation('schedule', (new \App\Models\Schedule())->forceFill($scheduleData));
                $sess->setRelation('room', (new \App\Models\Room())->forceFill($roomData));

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
