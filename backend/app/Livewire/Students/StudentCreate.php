<?php

namespace App\Livewire\Students;

use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use App\Models\Faculty;
use App\Models\Shift;
use App\Models\Schedule;
use App\Models\AcademicClass;
use App\Support\FirestoreHydrator;
use Livewire\Component;
use Livewire\WithFileUploads;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class StudentCreate extends Component
{
    use WithFileUploads;

    /* ---------------------------------
        User Fields
    --------------------------------- */
    public $name = '';
    public $email = '';
    public $password = '';
    public $role = 'student';
    public $photo;

    /* ---------------------------------
        Student Fields
    --------------------------------- */
    public $gender = '';
    public $dob = '';
    public $faculty_id = '';
    public $major_id = '';
    public $academic_class_id = '';
    public $year = '';
    public $shift_id = '';
    public $schedule_id = '';
    public $generation = '';

    /* ---------------------------------
        Validation Rules
    --------------------------------- */
    protected function rules()
    {
        $isProd = \App\Services\FirestoreService::isActive();
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255' . ($isProd ? '' : '|unique:users,email'),
            'password' => 'required|min:8',
            'role' => 'required|in:admin,user,student,teacher',
            'gender' => 'required|in:male,female',
            'dob' => 'nullable|date',
            'faculty_id' => 'required' . ($isProd ? '' : '|exists:faculties,id'),
            'major_id' => 'required' . ($isProd ? '' : '|exists:majors,id'),
            'academic_class_id' => 'nullable' . ($isProd ? '' : '|exists:academic_classes,id'),
            'year' => 'required',
            'shift_id' => 'required' . ($isProd ? '' : '|exists:shifts,id'),
            'schedule_id' => 'required' . ($isProd ? '' : '|exists:schedules,id'),
            'generation' => 'required',
            'photo' => 'nullable|image|max:1024',
        ];
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
        $validated = $this->validate();
        $firestore = app(\App\Services\FirestoreService::class);

        if (\App\Services\FirestoreService::isActive()) {
            $userData = [
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role' => 'student',
                'created_at' => now()->format('Y-m-d H:i:s'),
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ];
            $userId = $firestore->create('users', $userData);

            $studentData = [
                'user_id' => (string)$userId,
                'user_name' => $validated['name'],
                'user_email' => $validated['email'],
                'gender' => $this->gender,
                'dob' => $this->dob,
                'faculty_id' => (string)$this->faculty_id,
                'major_id' => (string)$this->major_id,
                'academic_class_id' => $this->academic_class_id ? (string)$this->academic_class_id : null,
                'year' => $this->year,
                'shift_id' => (string)$this->shift_id,
                'schedule_id' => (string)$this->schedule_id,
                'generation' => $this->generation,
                'created_at' => now()->format('Y-m-d H:i:s'),
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ];

            if ($this->photo) {
                $studentData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
            }

            $firestore->create('students', $studentData);
        } else {
            DB::transaction(function () use ($validated) {
                $user = User::create([
                    'name' => $validated['name'],
                    'email' => $validated['email'],
                    'password' => Hash::make($validated['password']),
                    'role' => 'student',
                ]);

                $studentData = [
                    'gender' => $this->gender,
                    'dob' => $this->dob,
                    'faculty_id' => $this->faculty_id,
                    'major_id' => $this->major_id,
                    'academic_class_id' => $this->academic_class_id ?: null,
                    'year' => $this->year,
                    'shift_id' => $this->shift_id,
                    'schedule_id' => $this->schedule_id,
                    'generation' => $this->generation,
                ];

                if ($this->photo) {
                    $studentData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
                }

                $user->student()->update($studentData);
            });
        }

        $this->reset();
        $this->dispatch('studentCreated');
        session()->flash('success', 'Student created successfully!');
    }

    public function render()
    {
        if (\App\Services\FirestoreService::isActive()) {
            $firestore = app(\App\Services\FirestoreService::class);

            return view('livewire.students.student-create', [
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

        return view('livewire.students.student-create', [
            'faculties' => Faculty::orderBy('name')->get(),
            'majors' => $this->faculty_id
                ? Major::where('faculty_id', $this->faculty_id)->orderBy('name')->get()
                : collect(),
            'academic_classes' => $this->major_id
                ? AcademicClass::where('major_id', $this->major_id)->orderBy('name')->get()
                : collect(),
            'schedules' => Schedule::all()->sortBy(function ($s) {
                return $s->full_display;
            }),
            'shifts' => Shift::orderBy('name')->get(),
        ]);
    }
}
