<?php

namespace App\Livewire\Syllabuses;

use App\Models\Syllabus;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Shift;
use Livewire\Component;

class SyllabusCreate extends Component
{
    public $faculty_id;
    public $major_id;
    public $subject_id;
    public $teacher_id;
    public $shift_id;
    public $year_id;
    public $semester_id = 1;
    public $schedule_description;

    protected $rules = [
        'faculty_id' => 'required|exists:faculties,id',
        'major_id' => 'required|exists:majors,id',
        'subject_id' => 'required|exists:subjects,id',
        'teacher_id' => 'required|exists:teachers,id',
        'shift_id' => 'required|exists:shifts,id',
        'year_id' => 'required',
        'semester_id' => 'required|integer|min:1|max:2',
        'schedule_description' => 'required',
    ];

    public function store()
    {
        $this->validate();

        Syllabus::create([
            'faculty_id' => $this->faculty_id,
            'major_id' => $this->major_id,
            'subject_id' => $this->subject_id,
            'teacher_id' => $this->teacher_id,
            'shift_id' => $this->shift_id,
            'year_id' => $this->year_id,
            'semester_id' => $this->semester_id,
            'schedule_description' => $this->schedule_description,
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
            'majors' => Major::orderBy('name')->get(),
            'shifts' => Shift::orderBy('name')->get(),
            'subjects' => Subject::orderBy('name')->get(),
            'teachers' => Teacher::with('user')->get(),
            'years' => [
                'Y1' => 'Year 1',
                'Y2' => 'Year 2',
                'Y3' => 'Year 3',
                'Y4' => 'Year 4',
                'Y5' => 'Year 5',
            ],
        ]);
    }
}
