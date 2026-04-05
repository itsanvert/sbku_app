<?php

namespace App\Livewire\Syllabuses;

use App\Models\Syllabus;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Shift;
use Livewire\Component;

class SyllabusEdit extends Component
{
    public $syllabusId;
    public $faculty_id;
    public $major_id;
    public $subject_id;
    public $teacher_id;
    public $shift_id;
    public $year_id;
    public $semester_id;
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

    public function mount($syllabusId)
    {
        $syllabus = Syllabus::findOrFail($syllabusId);
        $this->syllabusId = $syllabus->id;
        $this->faculty_id = $syllabus->faculty_id;
        $this->major_id = $syllabus->major_id;
        $this->subject_id = $syllabus->subject_id;
        $this->teacher_id = $syllabus->teacher_id;
        $this->shift_id = $syllabus->shift_id;
        $this->year_id = $syllabus->year_id;
        $this->semester_id = $syllabus->semester_id;
        $this->schedule_description = $syllabus->schedule_description;
    }

    public function update()
    {
        $this->validate();

        $syllabus = Syllabus::findOrFail($this->syllabusId);
        $syllabus->update([
            'faculty_id' => $this->faculty_id,
            'major_id' => $this->major_id,
            'subject_id' => $this->subject_id,
            'teacher_id' => $this->teacher_id,
            'shift_id' => $this->shift_id,
            'year_id' => $this->year_id,
            'semester_id' => $this->semester_id,
            'schedule_description' => $this->schedule_description,
        ]);

        $this->dispatch('syllabusUpdated');
    }

    public function closeModal()
    {
        $this->dispatch('closeModal');
    }

    public function render()
    {
        return view('livewire.syllabuses.syllabus-edit', [
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
