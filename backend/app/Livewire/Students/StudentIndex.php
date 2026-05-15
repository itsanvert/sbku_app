<?php

namespace App\Livewire\Students;

use App\Models\Student;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Shift;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Computed;

class StudentIndex extends Component
{
    use WithPagination;
    
    public function __construct()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    private $firestore;

    public $search = '';
    public $role = '';
    public $sortBy = 'id';
    public $sortDirection = 'asc';

    public $selected = [];
    public $selectAll = false;

    public $showCreateModal = false;
    public $showEditModal = false;
    public $editStudentId = null;
    public $deleteStudentId = null;

    protected $listeners = [
        'studentCreated' => 'handleStudentCreated',
        'studentUpdated' => 'handleStudentUpdated',
        'closeModal' => 'closeModals',
    ];

    public function updatingSearch() { $this->resetPage(); }
    public function updatingRole() { $this->resetPage(); }

    public function updatedSelectAll($value)
    {
        if ($value) {
            $this->selected = $this->students->pluck('id')->map(fn($id) => (string) $id)->toArray();
        } else {
            $this->selected = [];
        }
    }

    public function sort($column)
    {
        if ($this->sortBy === $column) {
            $this->sortDirection = $this->sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            $this->sortBy = $column;
            $this->sortDirection = 'asc';
        }

        $this->resetPage();
    }

    #[Computed]
    public function students()
    {
        if (config('app.env') === 'production') {
            $students = $this->firestore->list('students');
            $collection = collect($students);

            if ($this->search) {
                $collection = $collection->filter(fn($s) => 
                    str_contains(strtolower($s['user_name'] ?? ''), strtolower($this->search)) ||
                    str_contains(strtolower($s['user_email'] ?? ''), strtolower($this->search)) ||
                    str_contains(strtolower($s['phone'] ?? ''), strtolower($this->search))
                );
            }

            // Map to Model objects for Blade compatibility
            $items = $collection->forPage($this->getPage(), 10)->map(function ($data) {
                $s = new Student();
                $s->forceFill($data);
                $s->exists = true;

                // 1. Mock User relationship
                $u = new \App\Models\User();
                $u->forceFill([
                    'id'    => $data['user_id'] ?? null,
                    'name'  => $data['user_name'] ?? '—',
                    'email' => $data['user_email'] ?? '—',
                ]);
                $s->setRelation('user', $u);

                // 2. Mock Major relationship
                $maj = new \App\Models\Major();
                $maj->forceFill([
                    'id'   => $data['major_id'] ?? null,
                    'name' => $data['major_name'] ?? '—',
                ]);
                $s->setRelation('major', $maj);

                // 3. Mock Faculty relationship
                $fac = new \App\Models\Faculty();
                $fac->forceFill([
                    'id'   => $data['faculty_id'] ?? null,
                    'name' => $data['faculty_name'] ?? '—',
                ]);
                $s->setRelation('faculty', $fac);

                // 4. Mock Shift relationship
                $shift = new \App\Models\Shift();
                $shift->forceFill([
                    'id'   => $data['shift_id'] ?? null,
                    'name' => $data['shift_name'] ?? '—',
                ]);
                $s->setRelation('shift', $shift);

                return $s;
            });

            return new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );
        }

        $query = Student::query()
            ->with(['user', 'major', 'faculty', 'schedule', 'shift'])
            ->join('users', 'students.user_id', '=', 'users.id')
            ->leftJoin('faculties', 'students.faculty_id', '=', 'faculties.id')
            ->leftJoin('majors', 'students.major_id', '=', 'majors.id')
            ->select('students.*', 'users.name as user_name', 'users.email as user_email', 'faculties.name as faculty_name', 'majors.name as major_name');

        // Search
        if ($this->search) {
            $query->where(function($q) {
                $q->where('users.name', 'like', '%' . $this->search . '%')
                  ->orWhere('users.email', 'like', '%' . $this->search . '%')
                  ->orWhere('students.phone', 'like', '%' . $this->search . '%');
            });
        }

        // Role Filter
        if ($this->role) {
            $query->where('users.role', $this->role);
        }

        // Sorting
        $sortField = match($this->sortBy) {
            'name' => 'users.name',
            'email' => 'users.email',
            'faculty_id' => 'faculties.name',
            'major_id' => 'majors.name',
            default => 'students.' . $this->sortBy,
        };

        return $query->orderBy($sortField, $this->sortDirection)
            ->paginate(10);
    }

    public function openCreateModal()
    {
        $this->showEditModal = false;
        $this->showCreateModal = true;
    }

    public function openEditModal($id)
    {
        $this->editStudentId = $id;
        $this->showCreateModal = false;
        $this->showEditModal = true;
    }

    public function confirmDelete($id)
    {
        $this->deleteStudentId = $id;
        $this->dispatch('modal-show', name: 'confirm-delete');
    }

    public function deleteStudent()
    {
        if ($this->deleteStudentId) {
            if (config('app.env') === 'production') {
                $this->firestore->delete('students', (string)$this->deleteStudentId);
            } else {
                Student::findOrFail($this->deleteStudentId)->delete();
            }
            $this->deleteStudentId = null;
            session()->flash('message', 'Student deleted successfully.');
            $this->dispatch('modal-close', name: 'confirm-delete');
        }
    }

    public function confirmBulkDelete()
    {
        if (empty($this->selected)) {
            return;
        }

        $this->dispatch('modal-show', name: 'confirm-bulk-delete');
    }

    public function deleteSelected()
    {
        if (!empty($this->selected)) {
            if (config('app.env') === 'production') {
                foreach ($this->selected as $id) {
                    $this->firestore->delete('students', (string)$id);
                }
            } else {
                Student::whereIn('id', $this->selected)->delete();
            }
            $count = count($this->selected);
            $this->selected = [];
            $this->selectAll = false;
            session()->flash('message', $count . ' students deleted successfully.');
            $this->dispatch('modal-close', name: 'confirm-bulk-delete');
        }
    }

    public function closeModals()
    {
        $this->showCreateModal = false;
        $this->showEditModal = false;
        $this->editStudentId = null;
    }

    public function handleStudentCreated()
    {
        $this->closeModals();
        session()->flash('message', 'Student created successfully.');
    }

    public function handleStudentUpdated()
    {
        $this->closeModals();
        session()->flash('message', 'Student updated successfully.');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $hydrate = function($collection, $modelClass) {
                return collect($this->firestore->list($collection))->map(function($data) use ($modelClass) {
                    $m = new $modelClass();
                    $m->forceFill($data);
                    $m->exists = true;
                    return $m;
                })->sortBy('name');
            };

            return view('livewire.students.student-index', [
                'faculties' => $hydrate('faculties', Faculty::class),
                'majors' => $hydrate('majors', Major::class),
                'shifts' => $hydrate('shifts', Shift::class),
            ])->layout('layouts.app');
        }

        return view('livewire.students.student-index', [
            'faculties' => Faculty::orderBy('name')->get(),
            'majors' => Major::orderBy('name')->get(),
            'shifts' => Shift::orderBy('name')->get(),
        ])->layout('layouts.app');
    }
}
