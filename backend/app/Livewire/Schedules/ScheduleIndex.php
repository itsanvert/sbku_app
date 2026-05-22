<?php

namespace App\Livewire\Schedules;

use App\Models\Schedule;
use App\Support\FirestoreHydrator;
use Illuminate\Support\Facades\Cache;
use Livewire\Attributes\Computed;
use Livewire\Component;
use Livewire\WithPagination;

class ScheduleIndex extends Component
{
    use WithPagination;
    
    public function boot()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    private $firestore;

    public $search = '';
    public $showCreateModal = false;
    public $showEditModal = false;
    public $editScheduleId = null;
    
    // Form fields
    public $name;
    public $day_of_the_week;
    public $start_time;
    public $end_time;
    public $start_date;
    public $end_date;
    public $class_id;
    public $teacher_id;
    public $subject_id;
    public $room_id;
    public $syllabus_id;

    protected function rules()
    {
        $isProd = \App\Services\FirestoreService::isActive();
        return [
            'name' => 'required|min:2',
            'day_of_the_week' => 'nullable|string',
            'start_time' => 'nullable',
            'end_time' => 'nullable',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'class_id' => 'nullable' . ($isProd ? '' : '|exists:academic_classes,id'),
            'teacher_id' => 'nullable' . ($isProd ? '' : '|exists:teachers,id'),
            'subject_id' => 'nullable' . ($isProd ? '' : '|exists:subjects,id'),
            'room_id' => 'nullable' . ($isProd ? '' : '|exists:rooms,id'),
            'syllabus_id' => 'nullable' . ($isProd ? '' : '|exists:syllabuses,id'),
        ];
    }

    public function updatingSearch() { $this->resetPage(); }

    public function openCreateModal()
    {
        $this->reset(['name', 'day_of_the_week', 'start_time', 'end_time', 'start_date', 'end_date', 'class_id', 'teacher_id', 'subject_id', 'room_id', 'syllabus_id']);
        $this->showCreateModal = true;
    }

    public function store()
    {
        $this->validate();
        $data = [
            'name' => $this->name,
            'day_of_the_week' => $this->day_of_the_week,
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'start_date' => $this->start_date,
            'end_date' => $this->end_date,
            'class_id' => $this->class_id ?: null,
            'teacher_id' => $this->teacher_id ?: null,
            'subject_id' => $this->subject_id ?: null,
            'room_id' => $this->room_id ?: null,
            'syllabus_id' => $this->syllabus_id ?: null,
        ];

        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->create('schedules', $data);
        } else {
            Schedule::create($data);
        }
        $this->showCreateModal = false;
        session()->flash('message', 'Schedule created successfully.');
    }

    public function edit($id)
    {
        $this->editScheduleId = $id;
        if (\App\Services\FirestoreService::isActive()) {
            $schedule = $this->firestore->getDocument('schedules', (string)$id);
            $this->name = $schedule['name'] ?? '';
            $this->day_of_the_week = $schedule['day_of_the_week'] ?? '';
            $this->start_time = $schedule['start_time'] ?? null;
            $this->end_time = $schedule['end_time'] ?? null;
            $this->start_date = $schedule['start_date'] ?? null;
            $this->end_date = $schedule['end_date'] ?? null;
            $this->class_id = $schedule['class_id'] ?? null;
            $this->teacher_id = $schedule['teacher_id'] ?? null;
            $this->subject_id = $schedule['subject_id'] ?? null;
            $this->room_id = $schedule['room_id'] ?? null;
            $this->syllabus_id = $schedule['syllabus_id'] ?? null;
        } else {
            $schedule = Schedule::findOrFail($id);
            $this->name = $schedule->name;
            $this->day_of_the_week = $schedule->day_of_the_week;
            $this->start_time = $schedule->start_time ? $schedule->start_time->format('H:i') : null;
            $this->end_time = $schedule->end_time ? $schedule->end_time->format('H:i') : null;
            $this->start_date = $schedule->start_date ? $schedule->start_date->format('Y-m-d') : null;
            $this->end_date = $schedule->end_date ? $schedule->end_date->format('Y-m-d') : null;
            $this->class_id = $schedule->class_id;
            $this->teacher_id = $schedule->teacher_id;
            $this->subject_id = $schedule->subject_id;
            $this->room_id = $schedule->room_id;
            $this->syllabus_id = $schedule->syllabus_id;
        }
        $this->showEditModal = true;
    }

    public function update()
    {
        $this->validate();
        $data = [
            'name' => $this->name,
            'day_of_the_week' => $this->day_of_the_week,
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'start_date' => $this->start_date,
            'end_date' => $this->end_date,
            'class_id' => $this->class_id ?: null,
            'teacher_id' => $this->teacher_id ?: null,
            'subject_id' => $this->subject_id ?: null,
            'room_id' => $this->room_id ?: null,
            'syllabus_id' => $this->syllabus_id ?: null,
        ];

        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->update('schedules', (string)$this->editScheduleId, $data);
        } else {
            $schedule = Schedule::findOrFail($this->editScheduleId);
            $schedule->update($data);
        }

        $this->showEditModal = false;
        session()->flash('message', 'Schedule updated successfully.');
    }

    public function delete($id)
    {
        if (\App\Services\FirestoreService::isActive()) {
            $this->firestore->delete('schedules', (string)$id);
        } else {
            Schedule::findOrFail($id)->delete();
        }
        session()->flash('message', 'Schedule deleted successfully.');
    }

    #[Computed]
    public function schedules()
    {
        $cacheKey = 'schedules.index.' . md5(implode('|', [$this->search, $this->getPage()]));

        return Cache::remember($cacheKey, 60, function () {
            return Schedule::with(['teacher.user', 'subject', 'academicClass', 'room'])
                ->when($this->search, fn($q) => $q->where(function($q) {
                    $q->where('name', 'like', '%' . $this->search . '%')
                      ->orWhere('day_of_the_week', 'like', '%' . $this->search . '%');
                }))
                ->paginate(10);
        });
    }

    public function render()
    {
        if (\App\Services\FirestoreService::isActive()) {
            $schedules = $this->firestore->list('schedules');
            $collection = collect($schedules);
            if ($this->search) {
                $collection = $collection->filter(fn($s) => 
                    str_contains(strtolower($s['name'] ?? ''), strtolower($this->search)) ||
                    str_contains(strtolower($s['day_of_the_week'] ?? ''), strtolower($this->search))
                );
            }
            $items = $collection
                ->forPage($this->getPage(), 10)
                ->map(fn (array $data) => FirestoreHydrator::schedule($data));

            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );

            return view('livewire.schedules.schedule-index', [
                'schedules' => $paginated,
                'teachers' => FirestoreHydrator::teacherCollection($this->firestore->list('teachers')),
                'subjects' => FirestoreHydrator::selectOptions($this->firestore->list('subjects')),
                'academicClasses' => FirestoreHydrator::academicClassCollection($this->firestore->list('academic_classes')),
                'rooms' => FirestoreHydrator::selectOptions($this->firestore->list('rooms')),
                'syllabuses' => FirestoreHydrator::syllabusCollection($this->firestore->list('syllabuses')),
            ])->layout('layouts.app');
        }

        return view('livewire.schedules.schedule-index', [
            'schedules' => $this->schedules,
            'teachers' => Cache::remember('sch.teachers', 86400, fn() => \App\Models\Teacher::with('user')->select('id', 'user_id')->get()),
            'subjects' => Cache::remember('sch.subjects', 86400, fn() => \App\Models\Subject::select('id', 'name')->orderBy('name')->get()),
            'academicClasses' => Cache::remember('sch.classes', 86400, fn() => \App\Models\AcademicClass::select('id', 'name')->orderBy('name')->get()),
            'rooms' => Cache::remember('sch.rooms', 86400, fn() => \App\Models\Room::select('id', 'name', 'code')->orderBy('name')->get()),
            'syllabuses' => Cache::remember('sch.syllabuses', 86400, fn() => \App\Models\Syllabus::with(['subject:id,name', 'teacher.user:id,name'])->select('id', 'name', 'subject_id', 'teacher_id')->get()),
        ])->layout('layouts.app');
    }
}
