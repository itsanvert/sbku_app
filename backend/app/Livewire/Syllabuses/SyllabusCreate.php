<?php

namespace App\Livewire\Syllabuses;

use App\Models\Syllabus;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Shift;
use App\Services\ScheduleConflictDetector;
use Livewire\Component;

class SyllabusCreate extends Component
{
    public $faculty_id;
    public $major_id;
    public $subject_id;
    public $teacher_id;
    public $shift_id;
    public $year_id;
    public $semester_id   = 1;
    public $schedule_description;

    // Structured scheduling
    public $day_of_week;
    public $start_time;
    public $end_time;

    // Conflict feedback shown in the form
    public array $conflictErrors = [];

    protected $rules = [
        'faculty_id'           => 'required|exists:faculties,id',
        'major_id'             => 'required|exists:majors,id',
        'subject_id'           => 'required|exists:subjects,id',
        'teacher_id'           => 'required|exists:teachers,id',
        'shift_id'             => 'required|exists:shifts,id',
        'year_id'              => 'required',
        'semester_id'          => 'required|integer|min:1|max:2',
        'schedule_description' => 'nullable|string|max:255',
        'day_of_week'          => 'required|in:monday,tuesday,wednesday,thursday,friday,saturday,sunday',
        'start_time'           => 'required|date_format:H:i',
        'end_time'             => 'required|date_format:H:i|after:start_time',
    ];

    protected $messages = [
        'day_of_week.required' => 'Please select a day of the week.',
        'start_time.required'  => 'Please provide a start time.',
        'end_time.required'    => 'Please provide an end time.',
        'end_time.after'       => 'End time must be after start time.',
    ];

    /**
     * Real-time conflict check when relevant fields change.
     */
    public function updated($field): void
    {
        if (in_array($field, ['teacher_id', 'day_of_week', 'start_time', 'end_time'])) {
            $this->checkConflictsLive();
        }
    }

    private function checkConflictsLive(): void
    {
        $this->conflictErrors = [];

        if ($this->teacher_id && $this->day_of_week && $this->start_time && $this->end_time) {
            $result = app(ScheduleConflictDetector::class)->validate([
                'teacher_id'  => (int) $this->teacher_id,
                'major_id'    => $this->major_id ? (int) $this->major_id : null,
                'year_id'     => $this->year_id,
                'semester_id' => (int) $this->semester_id,
                'day_of_week' => $this->day_of_week,
                'start_time'  => $this->start_time,
                'end_time'    => $this->end_time,
            ]);

            $this->conflictErrors = $result['errors'];
        }
    }

    public function store()
    {
        $this->validate();

        // Final conflict check before saving
        $result = app(ScheduleConflictDetector::class)->validate([
            'teacher_id'  => (int) $this->teacher_id,
            'major_id'    => (int) $this->major_id,
            'year_id'     => $this->year_id,
            'semester_id' => (int) $this->semester_id,
            'day_of_week' => $this->day_of_week,
            'start_time'  => $this->start_time,
            'end_time'    => $this->end_time,
        ]);

        if (!$result['valid']) {
            $this->conflictErrors = $result['errors'];
            return; // Stop — do not save
        }

        Syllabus::create([
            'faculty_id'           => $this->faculty_id,
            'major_id'             => $this->major_id,
            'subject_id'           => $this->subject_id,
            'teacher_id'           => $this->teacher_id,
            'shift_id'             => $this->shift_id,
            'year_id'              => $this->year_id,
            'semester_id'          => $this->semester_id,
            'schedule_description' => $this->schedule_description,
            'day_of_week'          => $this->day_of_week,
            'start_time'           => $this->start_time,
            'end_time'             => $this->end_time,
        ]);

        $this->dispatch('syllabusCreated');
    }

    public function closeModal()
    {
        $this->dispatch('closeModal');
    }

    public function render()
    {
        return view('livewire.syllabuses.syllabus-create', [
            'faculties' => Faculty::orderBy('name')->get(),
            'majors'    => Major::orderBy('name')->get(),
            'shifts'    => Shift::orderBy('name')->get(),
            'subjects'  => Subject::orderBy('name')->get(),
            'teachers'  => Teacher::with('user')->get(),
            'years'     => [
                'Y1' => 'Year 1',
                'Y2' => 'Year 2',
                'Y3' => 'Year 3',
                'Y4' => 'Year 4',
                'Y5' => 'Year 5',
            ],
            'days' => [
                'monday'    => 'Monday',
                'tuesday'   => 'Tuesday',
                'wednesday' => 'Wednesday',
                'thursday'  => 'Thursday',
                'friday'    => 'Friday',
                'saturday'  => 'Saturday',
                'sunday'    => 'Sunday',
            ],
        ]);
    }
}
