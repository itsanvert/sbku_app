<?php

namespace App\Livewire\Syllabuses;

use App\Models\Syllabus;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Shift;
use App\Services\FirestoreService;
use App\Services\ScheduleConflictDetector;
use App\Support\FirestoreHydrator;
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

    public $day_of_week;
    public $start_time;
    public $end_time;

    public array $conflictErrors = [];

    protected function rules(): array
    {
        return [
            'faculty_id'           => 'required' . (FirestoreService::isActive() ? '' : '|exists:faculties,id'),
            'major_id'             => 'required' . (FirestoreService::isActive() ? '' : '|exists:majors,id'),
            'subject_id'           => 'required' . (FirestoreService::isActive() ? '' : '|exists:subjects,id'),
            'teacher_id'           => 'required' . (FirestoreService::isActive() ? '' : '|exists:teachers,id'),
            'shift_id'             => 'required' . (FirestoreService::isActive() ? '' : '|exists:shifts,id'),
            'year_id'              => 'required',
            'semester_id'          => 'required|integer|min:1|max:2',
            'schedule_description' => 'nullable|string|max:255',
            'day_of_week'          => 'required|in:monday,tuesday,wednesday,thursday,friday,saturday,sunday',
            'start_time'           => 'required|date_format:H:i',
            'end_time'             => 'required|date_format:H:i|after:start_time',
        ];
    }

    protected $messages = [
        'day_of_week.required' => 'Please select a day of the week.',
        'start_time.required'  => 'Please provide a start time.',
        'end_time.required'    => 'Please provide an end time.',
        'end_time.after'       => 'End time must be after start time.',
    ];

    public function mount($syllabusId)
    {
        if (FirestoreService::isActive()) {
            $syllabus = app(FirestoreService::class)->getDocument('syllabuses', (string) $syllabusId);
            if (! $syllabus) {
                abort(404);
            }
        } else {
            $syllabus = Syllabus::findOrFail($syllabusId)->toArray();
            $syllabus['id'] = $syllabusId;
        }

        $this->syllabusId           = $syllabus['id'] ?? $syllabusId;
        $this->faculty_id           = $syllabus['faculty_id'] ?? '';
        $this->major_id             = $syllabus['major_id'] ?? '';
        $this->subject_id           = $syllabus['subject_id'] ?? '';
        $this->teacher_id           = $syllabus['teacher_id'] ?? '';
        $this->shift_id             = $syllabus['shift_id'] ?? '';
        $this->year_id              = $syllabus['year_id'] ?? '';
        $this->semester_id          = $syllabus['semester_id'] ?? '';
        $this->schedule_description = $syllabus['schedule_description'] ?? '';
        $this->day_of_week          = $syllabus['day_of_week'] ?? '';
        $this->start_time           = ! empty($syllabus['start_time'])
            ? \Carbon\Carbon::parse($syllabus['start_time'])->format('H:i')
            : null;
        $this->end_time             = ! empty($syllabus['end_time'])
            ? \Carbon\Carbon::parse($syllabus['end_time'])->format('H:i')
            : null;
    }

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
            ], $this->syllabusId);

            $this->conflictErrors = $result['errors'];
        }
    }

    public function update()
    {
        $this->validate();

        $result = app(ScheduleConflictDetector::class)->validate([
            'teacher_id'  => (int) $this->teacher_id,
            'major_id'    => (int) $this->major_id,
            'year_id'     => $this->year_id,
            'semester_id' => (int) $this->semester_id,
            'day_of_week' => $this->day_of_week,
            'start_time'  => $this->start_time,
            'end_time'    => $this->end_time,
        ], $this->syllabusId);

        if (! $result['valid']) {
            $this->conflictErrors = $result['errors'];

            return;
        }

        $payload = [
            'faculty_id'           => (string) $this->faculty_id,
            'major_id'             => (string) $this->major_id,
            'subject_id'           => (string) $this->subject_id,
            'teacher_id'           => (string) $this->teacher_id,
            'shift_id'             => (string) $this->shift_id,
            'year_id'              => $this->year_id,
            'semester_id'          => (int) $this->semester_id,
            'schedule_description' => $this->schedule_description,
            'day_of_week'          => $this->day_of_week,
            'start_time'           => $this->start_time,
            'end_time'             => $this->end_time,
            'updated_at'           => now()->format('Y-m-d H:i:s'),
        ];

        if (FirestoreService::isActive()) {
            $firestore = app(FirestoreService::class);
            $payload = array_merge($payload, SyllabusCreate::denormalizedSyllabusLabels(
                $firestore,
                (string) $this->subject_id,
                (string) $this->teacher_id,
                (string) $this->faculty_id,
                (string) $this->major_id,
                (string) $this->shift_id,
            ));
            $firestore->update('syllabuses', (string) $this->syllabusId, $payload);
        } else {
            $syllabus = Syllabus::findOrFail($this->syllabusId);
            $syllabus->update([
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
        }

        $this->dispatch('syllabusUpdated');
    }

    public function closeModal()
    {
        $this->dispatch('closeModal');
    }

    public function render()
    {
        $years = [
            'Y1' => 'Year 1',
            'Y2' => 'Year 2',
            'Y3' => 'Year 3',
            'Y4' => 'Year 4',
            'Y5' => 'Year 5',
        ];
        $days = [
            'monday'    => 'Monday',
            'tuesday'   => 'Tuesday',
            'wednesday' => 'Wednesday',
            'thursday'  => 'Thursday',
            'friday'    => 'Friday',
            'saturday'  => 'Saturday',
            'sunday'    => 'Sunday',
        ];

        if (FirestoreService::isActive()) {
            $firestore = app(FirestoreService::class);

            return view('livewire.syllabuses.syllabus-edit', [
                'faculties' => FirestoreHydrator::selectOptions($firestore->list('faculties')),
                'majors'    => FirestoreHydrator::selectOptions($firestore->list('majors')),
                'shifts'    => FirestoreHydrator::selectOptions($firestore->list('shifts')),
                'subjects'  => FirestoreHydrator::selectOptions($firestore->list('subjects')),
                'teachers'  => FirestoreHydrator::teacherSelectOptions($firestore->list('teachers')),
                'years'     => $years,
                'days'      => $days,
            ]);
        }

        return view('livewire.syllabuses.syllabus-edit', [
            'faculties' => Faculty::orderBy('name')->get(),
            'majors'    => Major::orderBy('name')->get(),
            'shifts'    => Shift::orderBy('name')->get(),
            'subjects'  => Subject::orderBy('name')->get(),
            'teachers'  => Teacher::with('user')->get(),
            'years'     => $years,
            'days'      => $days,
        ]);
    }
}
