<?php

namespace App\Livewire\Students;

use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use App\Models\Faculty;
use App\Models\Schedule;
use App\Models\Shift;
use App\Models\AcademicClass;
use App\Support\FirestoreHydrator;
use Livewire\Component;
use Livewire\WithFileUploads;
use Illuminate\Support\Facades\Hash;

class StudentEdit extends Component
{
    use WithFileUploads;

    public $name = '';
    public $email = '';
    public $password = '';
    public $role = 'student';
    public $studentId;
    public $userId;
    public $photo;
    public $existingPhoto;

    /* ---------------------------------
        Student Fields
    --------------------------------- */
    public $gender = '';
    public $major_id = '';
    public $academic_class_id = '';
    public $year = '';
    public $faculty_id = '';
    public $dob = '';
    public $shift_id = '';
    public $schedule_id = '';
    public $generation = '';

    public function mount($studentId)
    {
        if (\App\Services\FirestoreService::isActive()) {
            $firestore = app(\App\Services\FirestoreService::class);
            $student = $firestore->getDocument('students', (string)$studentId);
            if (!$student) abort(404);

            $this->studentId  = $student['id'];
            $this->userId     = $student['user_id'];
            $this->name       = $student['user_name'] ?? '—';
            $this->email      = $student['user_email'] ?? '—';
            $this->role       = 'student';
            $this->gender     = $student['gender'] ?? '';
            $this->dob        = $student['dob'] ?? '';
            $this->faculty_id = $student['faculty_id'] ?? '';
            $this->major_id   = $student['major_id'] ?? '';
            $this->academic_class_id = $student['academic_class_id'] ?? '';
            $this->year       = $student['year'] ?? '';
            $this->shift_id   = $student['shift_id'] ?? '';
            $this->schedule_id = $student['schedule_id'] ?? '';
            $this->generation = $student['generation'] ?? '';
            $this->existingPhoto = $student['profile_image_path'] ?? null;
        } else {
            $student = Student::with('user')->findOrFail($studentId);

            $this->studentId  = $student->id;
            $this->userId     = $student->user->id;
            $this->name       = $student->user->name;
            $this->email      = $student->user->email;
            $this->role       = $student->user->role;
            $this->gender     = $student->gender;
            $this->dob        = $student->dob;
            $this->faculty_id = $student->faculty_id;
            $this->major_id   = $student->major_id;
            $this->academic_class_id = $student->academic_class_id;
            $this->year       = $student->year;
            $this->shift_id   = $student->shift_id;
            $this->schedule_id = $student->schedule_id;
            $this->generation = $student->generation;
            $this->existingPhoto = $student->profile_image_path;
        }
    }

    public function updatedFacultyId()
    {
        $this->major_id = '';
        $this->academic_class_id = '';
    }

    public function updatedMajorId()
    {
        $this->academic_class_id = '';
    }

    public function save()
    {
        $isProd = \App\Services\FirestoreService::isActive();
        $this->validate([
            'name' => 'required',
            'email' => 'required|email' . ($isProd ? '' : '|unique:users,email,'.$this->userId),
            'photo' => 'nullable|image|max:1024',
        ]);

        if (\App\Services\FirestoreService::isActive()) {
            $firestore = app(\App\Services\FirestoreService::class);
            $userData = ['name' => $this->name, 'email' => $this->email, 'updated_at' => now()->format('Y-m-d H:i:s')];
            if ($this->password) {
                $userData['password'] = Hash::make($this->password);
            }
            $firestore->update('users', (string)$this->userId, $userData);

            $studentData = [
                'user_name'  => $this->name,
                'user_email' => $this->email,
                'gender'     => $this->gender,
                'dob'        => $this->dob,
                'faculty_id' => (string)$this->faculty_id,
                'major_id'   => (string)$this->major_id,
                'academic_class_id' => $this->academic_class_id ? (string)$this->academic_class_id : null,
                'year'       => $this->year,
                'shift_id'   => (string)$this->shift_id,
                'schedule_id' => (string)$this->schedule_id,
                'generation' => $this->generation,
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ];

            if ($this->photo) {
                $studentData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
            }

            $firestore->update('students', (string)$this->studentId, $studentData);
        } else {
            $student = Student::with('user')->findOrFail($this->studentId);

            $userData = ['name' => $this->name, 'email' => $this->email, 'role' => $this->role];
            if ($this->password) {
                $userData['password'] = Hash::make($this->password);
            }
            $student->user->update($userData);

            $studentData = [
                'gender'     => $this->gender,
                'dob'        => $this->dob,
                'faculty_id' => $this->faculty_id,
                'major_id'   => $this->major_id,
                'academic_class_id' => $this->academic_class_id ?: null,
                'year'       => $this->year,
                'shift_id'   => $this->shift_id,
                'schedule_id' => $this->schedule_id,
                'generation' => $this->generation,
            ];

            if ($this->photo) {
                $studentData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
            }

            $student->update($studentData);
        }

        $this->dispatch('studentUpdated');
    }

    public function render()
    {
        if (\App\Services\FirestoreService::isActive()) {
            $firestore = app(\App\Services\FirestoreService::class);
            return view('livewire.students.student-edit', [
                'faculties' => FirestoreHydrator::selectOptions($firestore->list('faculties')),
                'majors' => $this->faculty_id
                    ? FirestoreHydrator::selectOptions($firestore->list('majors', ['faculty_id' => (string) $this->faculty_id]))
                    : collect(),
                'academic_classes' => $this->major_id
                    ? FirestoreHydrator::academicClassCollection($firestore->list('academic_classes', ['major_id' => (string) $this->major_id]))
                    : collect(),
                'schedules' => FirestoreHydrator::scheduleCollection($firestore->list('schedules')),
                'shifts' => FirestoreHydrator::selectOptions($firestore->list('shifts')),
            ]);
        }

        return view('livewire.students.student-edit', [
            'faculties' => Faculty::orderBy('name')->get(),
            'majors' => $this->faculty_id 
                ? Major::where('faculty_id', $this->faculty_id)->orderBy('name')->get() 
                : collect(),
            'academic_classes' => $this->major_id 
                ? AcademicClass::where('major_id', $this->major_id)->orderBy('name')->get() 
                : collect(),
            'schedules' => Schedule::all()->sortBy(function($s) {
                return $s->full_display;
            }),
            'shifts'    => Shift::orderBy('name')->get(),
        ]);
    }
}
