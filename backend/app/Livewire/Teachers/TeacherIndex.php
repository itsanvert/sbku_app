<?php

namespace App\Livewire\Teachers;

use App\Models\Teacher;
use Illuminate\Support\Facades\Cache;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Computed;

class TeacherIndex extends Component
{
    use WithPagination;

    private $firestore;

    public function __construct()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    public $search = '';
    public $role = '';
    public $sortBy = 'id';
    public $sortDirection = 'asc';

    public $selected = [];
    public $selectAll = false;

    public $showCreateModal = false;
    public $showEditModal = false;
    public $editTeacherId = null;
    public $deleteTeacherId = null;

    protected $listeners = [
        'teacherCreated' => 'handleTeacherCreated',
        'teacherUpdated' => 'handleTeacherUpdated',
        'closeModal' => 'closeModals',
    ];

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function updatingRole()
    {
        $this->resetPage();
    }

    public function updatedSelectAll($value)
    {
        if ($value) {
            $this->selected = $this->teachers->pluck('id')->map(fn($id) => (string) $id)->toArray();
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
    public function teachers()
    {
        // Use Firestore if the service is active
        if ($this->firestore && \App\Services\FirestoreService::isActive()) {
            $teachers = $this->firestore->list('teachers');
            $collection = collect($teachers);
            
            // Batch fetch schedules to avoid N+1 Firestore fetch overhead
            $schedules = collect($this->firestore->list('schedules'))->keyBy('id');

            if ($this->search) {
                $collection = $collection->filter(fn($t) =>
                    str_contains(strtolower($t['user_name'] ?? ''), strtolower($this->search)) ||
                    str_contains(strtolower($t['user_email'] ?? ''), strtolower($this->search))
                );
            }

            // Map to Model objects for Blade compatibility
            $items = $collection->forPage($this->getPage(), 10)->map(function ($data) use ($schedules) {
                $t = new Teacher();

                // Separate relations from attributes
                $userData = [
                    'id'    => $data['user_id'] ?? null,
                    'name'  => $data['user_name'] ?? ($data['name'] ?? '—'),
                    'email' => $data['user_email'] ?? ($data['email'] ?? '—'),
                ];
                $majorData = [
                    'id'   => $data['major_id'] ?? null,
                    'name' => $data['major_name'] ?? '—',
                ];
                $facultyData = [
                    'id'   => $data['faculty_id'] ?? null,
                    'name' => $data['faculty_name'] ?? '—',
                ];
                $shiftData = [
                    'id'   => $data['shift_id'] ?? null,
                    'name' => $data['shift_name'] ?? '—',
                ];

                // Hydrate Schedule relationship dynamically and fast
                if (isset($data['schedule_id']) && $schedules->has((string) $data['schedule_id'])) {
                    $schedule = \App\Support\FirestoreHydrator::schedule($schedules->get((string) $data['schedule_id']));
                } else {
                    $schedule = new \App\Models\Schedule();
                    $schedule->forceFill([
                        'id' => $data['schedule_id'] ?? null,
                        'name' => $data['schedule_display'] ?? '—',
                    ]);
                }

                // Remove potentially conflicting keys from the main data array
                $cleanData = array_diff_key($data, array_flip(['user', 'major', 'faculty', 'shift', 'schedule']));

                $t->forceFill($cleanData);
                $t->exists = true;

                // Set properly hydrated relationships (no longer "mocked" logic, but real data hydration)
                $t->setRelation('user', (new \App\Models\User())->forceFill($userData));
                $t->setRelation('major', (new \App\Models\Major())->forceFill($majorData));
                $t->setRelation('faculty', (new \App\Models\Faculty())->forceFill($facultyData));
                $t->setRelation('shift', (new \App\Models\Shift())->forceFill($shiftData));
                $t->setRelation('schedule', $schedule);

                return $t;
            });

            return new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );
        }

        // Fallback to Eloquent (Local SQL)
        $cacheKey = 'teachers.index.' . md5(implode('|', [$this->search, $this->role, $this->sortBy, $this->sortDirection, $this->getPage()]));

        return Cache::remember($cacheKey, 60, function () {
            return Teacher::query()
                ->with(['user', 'major', 'faculty', 'schedule', 'shift'])
                ->when($this->search, function ($q) {
                    $q->whereHas('user', function ($query) {
                        $query->where('name', 'like', '%' . $this->search . '%')
                            ->orWhere('email', 'like', '%' . $this->search . '%');
                    });
                })
                ->when($this->role, function ($q) {
                    $q->whereHas('user', function ($query) {
                        $query->where('role', $this->role);
                    });
                })
                ->orderBy($this->sortBy, $this->sortDirection)
                ->paginate(10);
        });
    }

    public function openCreateModal()
    {
        $this->showEditModal = false;
        $this->showCreateModal = true;
    }

    public function openEditModal($id)
    {
        $this->editTeacherId = $id;
        $this->showCreateModal = false;
        $this->showEditModal = true;
    }

    public function confirmDelete($id)
    {
        $this->deleteTeacherId = $id;
        $this->dispatch('modal-show', name: 'confirm-delete');
    }

    public function deleteTeacher()
    {
        if ($this->deleteTeacherId) {
            if (\App\Services\FirestoreService::isActive()) {
                $this->firestore->delete('teachers', (string) $this->deleteTeacherId);
            } else {
                Teacher::findOrFail($this->deleteTeacherId)->delete();
            }
            $this->deleteTeacherId = null;
            session()->flash('message', 'Teacher deleted successfully.');
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
            if (\App\Services\FirestoreService::isActive()) {
                foreach ($this->selected as $id) {
                    $this->firestore->delete('teachers', (string) $id);
                }
            } else {
                Teacher::whereIn('id', $this->selected)->delete();
            }
            $count = count($this->selected);
            $this->selected = [];
            $this->selectAll = false;
            session()->flash('message', $count . ' teachers deleted successfully.');
            $this->dispatch('modal-close', name: 'confirm-bulk-delete');
        }
    }

    public function closeModals()
    {
        $this->showCreateModal = false;
        $this->showEditModal = false;
        $this->editTeacherId = null;
    }

    public function handleTeacherCreated()
    {
        $this->closeModals();
        session()->flash('message', 'Teacher created successfully.');
    }

    public function handleTeacherUpdated()
    {
        $this->closeModals();
        session()->flash('message', 'Teacher updated successfully.');
    }

    public function render()
    {
        return view('livewire.teachers.teacher-index')->layout('layouts.app');
    }

}
