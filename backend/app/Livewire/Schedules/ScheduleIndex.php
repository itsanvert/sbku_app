<?php

namespace App\Livewire\Schedules;

use App\Models\Schedule;
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
        $isProd = config('app.env') === 'production';
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

        if (config('app.env') === 'production') {
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
        if (config('app.env') === 'production') {
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

        if (config('app.env') === 'production') {
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
        if (config('app.env') === 'production') {
            $this->firestore->delete('schedules', (string)$id);
        } else {
            Schedule::findOrFail($id)->delete();
        }
        session()->flash('message', 'Schedule deleted successfully.');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $schedules = $this->firestore->list('schedules');
            $collection = collect($schedules);
            if ($this->search) {
                $collection = $collection->filter(fn($s) => 
                    str_contains(strtolower($s['name'] ?? ''), strtolower($this->search)) ||
                    str_contains(strtolower($s['day_of_the_week'] ?? ''), strtolower($this->search))
                );
            }
            $items = $collection->forPage($this->getPage(), 10)->map(function($data) {
                $s = new Schedule();
                $s->forceFill($cleanData);
                $s->exists = true;
                return $s;
            });
            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $items, $collection->count(), 10, $this->getPage(), ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );

            return view('livewire.schedules.schedule-index', [
                'schedules' => $paginated,
                'teachers' => collect($this->firestore->list('teachers')),
                'subjects' => collect($this->firestore->list('subjects')),
                'academicClasses' => collect($this->firestore->list('academic_classes')),
                'rooms' => collect($this->firestore->list('rooms')),
                'syllabuses' => collect($this->firestore->list('syllabuses')),
            ])->layout('layouts.app');
        }

        return view('livewire.schedules.schedule-index', [
            'schedules' => Schedule::with(['teacher.user', 'subject', 'academicClass', 'room'])
                ->where('name', 'like', '%' . $this->search . '%')
                ->orWhere('day_of_the_week', 'like', '%' . $this->search . '%')
                ->paginate(10),
            'teachers' => \App\Models\Teacher::with('user')->get(),
            'subjects' => \App\Models\Subject::orderBy('name')->get(),
            'academicClasses' => \App\Models\AcademicClass::orderBy('name')->get(),
            'rooms' => \App\Models\Room::orderBy('name')->get(),
            'syllabuses' => \App\Models\Syllabus::with(['subject', 'teacher.user'])->get(),
        ])->layout('layouts.app');
    }
}
