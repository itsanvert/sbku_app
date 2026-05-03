<?php

namespace App\Livewire\Attendance;

use App\Models\AttendanceSession;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Student;
use App\Models\Syllabus;
use App\Models\Teacher;
use Illuminate\Support\Str;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class AttendanceCreate extends Component
{
    // Step 1: teacher selection
    public string|int $teacher_id = '';

    // Step 2: syllabus selection (filtered by teacher)
    public string|int $syllabus_id = '';

    // Auto-filled from syllabus
    public string|int $faculty_id  = '';
    public string|int $major_id    = '';
    public string      $year_id     = '';
    public int|string  $semester_id = '';
    public string|int  $academic_class_id = '';
    public string|int  $shift_id = '';
    public string      $day_of_week = '';
    public string      $start_time  = '';
    public string      $end_time    = '';
    public string|int  $subject_id  = '';

    // Location
    public string $latitude  = '11.5564';
    public string $longitude = '104.9282';

    // Derived preview
    public ?Syllabus $selectedSyllabus   = null;
    public int       $enrolledStudents   = 0;

    protected $rules = [
        'teacher_id'  => 'required|exists:teachers,id',
        'syllabus_id' => 'required|exists:syllabuses,id',
        'faculty_id'  => 'required',
        'major_id'    => 'required',
        'latitude'    => 'required|numeric',
        'longitude'   => 'required|numeric',
    ];

    protected $messages = [
        'syllabus_id.required' => 'Please select a syllabus / class schedule.',
    ];

    // ── Watchers ──────────────────────────────────────────────────────────────

    /**
     * When teacher changes, clear syllabus selection and refresh the dropdown.
     */
    public function updatedTeacherId(): void
    {
        $this->reset([
            'syllabus_id', 'faculty_id', 'major_id',
            'year_id', 'semester_id', 'academic_class_id', 'shift_id', 'day_of_week',
            'start_time', 'end_time', 'subject_id',
            'selectedSyllabus', 'enrolledStudents',
        ]);
    }

    /**
     * When syllabus changes, auto-fill all class and schedule details.
     */
    public function updatedSyllabusId(string|int $value): void
    {
        if (!$value) {
            $this->reset([
                'faculty_id', 'major_id', 'year_id', 'semester_id', 'academic_class_id', 'shift_id',
                'day_of_week', 'start_time', 'end_time', 'subject_id',
                'selectedSyllabus', 'enrolledStudents',
            ]);
            return;
        }

        $syllabus = Syllabus::with(['faculty', 'major', 'subject', 'teacher.user', 'shift'])
            ->find($value);

        if (!$syllabus) {
            return;
        }

        $this->selectedSyllabus = $syllabus;
        $this->faculty_id       = $syllabus->faculty_id       ?? '';
        $this->major_id         = $syllabus->major_id         ?? '';
        $this->year_id          = $syllabus->year_id          ?? '';
        $this->semester_id      = $syllabus->semester_id      ?? '';
        $this->academic_class_id = $syllabus->academic_class_id ?? '';
        $this->shift_id         = $syllabus->shift_id         ?? '';
        $this->subject_id       = $syllabus->subject_id       ?? '';
        $this->day_of_week      = $syllabus->day_of_week      ?? '';
        $this->start_time       = $syllabus->start_time  ? \Carbon\Carbon::parse($syllabus->start_time)->format('H:i') : '';
        $this->end_time         = $syllabus->end_time    ? \Carbon\Carbon::parse($syllabus->end_time)->format('H:i')   : '';

        // Count students enrolled in the same class (or major/year if class not set)
        $this->enrolledStudents = Student::when($this->academic_class_id, function($q) {
                $q->where('academic_class_id', $this->academic_class_id);
            })
            ->when(!$this->academic_class_id, function($q) use ($syllabus) {
                $q->where('major_id', $syllabus->major_id)
                  ->where('year', $syllabus->year_id);
            })
            ->count();
    }

    // ── Action ────────────────────────────────────────────────────────────────

    public function createSession(): void
    {
        $this->validate();

        AttendanceSession::create([
            'teacher_id'         => $this->teacher_id,
            'faculty_id'         => $this->faculty_id   ?: null,
            'major_id'           => $this->major_id      ?: null,
            'syllabus_id'        => $this->syllabus_id,
            'subject_id'         => $this->subject_id    ?: null,
            'year_id'            => $this->year_id       ?: null,
            'semester_id'        => $this->semester_id   ?: null,
            'academic_class_id'  => $this->academic_class_id ?: null,
            'shift_id'           => $this->shift_id      ?: null,
            'day_of_week'        => $this->day_of_week   ?: null,
            'session_start_time' => $this->start_time    ?: null,
            'session_end_time'   => $this->end_time      ?: null,
            'latitude'           => $this->latitude,
            'longitude'          => $this->longitude,
            'started_at'         => \Carbon\Carbon::today()->setTimeFromTimeString($this->start_time),
            'is_active'          => true,
        ]);

        session()->flash('message', 'Attendance session started successfully.');

        $this->redirectRoute('attendance.sessions.index', navigate: true);
    }

    // ── Render ────────────────────────────────────────────────────────────────

    public function render()
    {
        // Syllabuses for selected teacher — show only ones with structured time
        $syllabuses = $this->teacher_id
            ? Syllabus::where('teacher_id', $this->teacher_id)
                ->whereNotNull('day_of_week')
                ->whereNotNull('start_time')
                ->with(['subject', 'major', 'shift'])
                ->orderByRaw("CASE 
                    WHEN day_of_week = 'monday' THEN 1 
                    WHEN day_of_week = 'tuesday' THEN 2 
                    WHEN day_of_week = 'wednesday' THEN 3 
                    WHEN day_of_week = 'thursday' THEN 4 
                    WHEN day_of_week = 'friday' THEN 5 
                    WHEN day_of_week = 'saturday' THEN 6 
                    WHEN day_of_week = 'sunday' THEN 7 
                    ELSE 8 
                END")
                ->orderBy('start_time')
                ->get()
            : collect();

        return view('livewire.attendance.attendance-create', [
            'teachers'   => Teacher::with(['user', 'faculty', 'major'])->get(),
            'syllabuses' => $syllabuses,
            'faculties'  => Faculty::orderBy('name')->get(),
            'majors'     => Major::orderBy('name')->get(),
        ]);
    }
}
