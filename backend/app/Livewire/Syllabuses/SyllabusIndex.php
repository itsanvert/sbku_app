<?php

namespace App\Livewire\Syllabuses;

use App\Models\Syllabus;
use App\Models\Faculty;
use App\Support\FirestoreHydrator;
use Illuminate\Support\Facades\Cache;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Computed;

class SyllabusIndex extends Component
{
    use WithPagination;

    public function boot()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    private $firestore;

    public $search = '';
    public $faculty_id = '';
    public $major_id = '';
    public $shift_id = '';
    public $year_id = '';

    public $sortBy = 'id';
    public $sortDirection = 'asc';

    public $showCreateModal = false;
    public $showEditModal = false;
    public $editSyllabusId = null;
    public $deleteSyllabusId = null;

    protected $listeners = [
        'syllabusCreated' => 'handleSyllabusCreated',
        'syllabusUpdated' => 'handleSyllabusUpdated',
        'closeModal' => 'closeModals',
    ];

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function updatingFacultyId()
    {
        $this->resetPage();
    }
    public function updatingMajorId()
    {
        $this->resetPage();
    }
    public function updatingShiftId()
    {
        $this->resetPage();
    }
    public function updatingYearId()
    {
        $this->resetPage();
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
    public function syllabuses()
    {
        if (\App\Services\FirestoreService::isActive()) {
            $syllabuses = $this->firestore->list('syllabuses');
            $collection = collect($syllabuses);

            if ($this->search) {
                $collection = $collection->filter(fn($s) => str_contains(strtolower($s['subject_name'] ?? ''), strtolower($this->search)));
            }
            if ($this->faculty_id)
                $collection = $collection->filter(fn($s) => ($s['faculty_id'] ?? '') == $this->faculty_id);
            if ($this->major_id)
                $collection = $collection->filter(fn($s) => ($s['major_id'] ?? '') == $this->major_id);
            if ($this->shift_id) {
                $collection = $collection->filter(fn ($s) => ($s['shift_id'] ?? '') == $this->shift_id);
            }
            if ($this->year_id) {
                $collection = $collection->filter(fn ($s) => ($s['year_id'] ?? '') == $this->year_id);
            }

            $items = $collection
                ->forPage($this->getPage(), 10)
                ->map(fn (array $data) => FirestoreHydrator::syllabus($data));

            return new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );
        }

        $cacheKey = 'syllabuses.index.' . md5(implode('|', [$this->search, $this->faculty_id, $this->major_id, $this->shift_id, $this->year_id, $this->sortBy, $this->sortDirection, $this->getPage()]));

        return Cache::remember($cacheKey, 60, function () {
            $query = Syllabus::query()
                ->with(['faculty', 'major', 'subject', 'teacher.user', 'shift'])
                ->join('subjects', 'syllabuses.subject_id', '=', 'subjects.id')
                ->select('syllabuses.*', 'subjects.name as subject_name');

            if ($this->search) {
                $query->where('subjects.name', 'like', '%' . $this->search . '%');
            }

            if ($this->faculty_id) {
                $query->where('faculty_id', $this->faculty_id);
            }

            if ($this->major_id) {
                $query->where('major_id', $this->major_id);
            }

            if ($this->shift_id) {
                $query->where('shift_id', $this->shift_id);
            }

            if ($this->year_id) {
                $query->where('year_id', $this->year_id);
            }

            return $query->orderBy($this->sortBy == 'subject_name' ? 'subjects.name' : 'syllabuses.' . $this->sortBy, $this->sortDirection)
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
        $this->editSyllabusId = $id;
        $this->showCreateModal = false;
        $this->showEditModal = true;
    }

    public function confirmDelete($id)
    {
        $this->deleteSyllabusId = $id;
        $this->dispatch('modal-show', name: 'confirm-delete-syllabus');
    }

    public function deleteSyllabus()
    {
        if ($this->deleteSyllabusId) {
            if (\App\Services\FirestoreService::isActive()) {
                $this->firestore->delete('syllabuses', (string) $this->deleteSyllabusId);
            } else {
                Syllabus::findOrFail($this->deleteSyllabusId)->delete();
            }
            $this->deleteSyllabusId = null;
            session()->flash('message', 'Syllabus entry deleted successfully.');
            $this->dispatch('modal-close', name: 'confirm-delete-syllabus');
        }
    }

    public function closeModals()
    {
        $this->showCreateModal = false;
        $this->showEditModal = false;
        $this->editSyllabusId = null;
    }

    public function handleSyllabusCreated()
    {
        $this->closeModals();
        session()->flash('message', 'Syllabus entry created successfully.');
    }

    public function handleSyllabusUpdated()
    {
        $this->closeModals();
        session()->flash('message', 'Syllabus entry updated successfully.');
    }

    public function render()
    {
        return view('livewire.syllabuses.syllabus-index', [
            'faculties' => Cache::remember('faculties.all', 86400, fn() => Faculty::orderBy('name')->get(['id', 'name'])),
        ])->layout('layouts.app');
    }
}
