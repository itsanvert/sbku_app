<?php

namespace App\Livewire\Students;

use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use App\Models\Faculty;
use App\Models\Shift;
use App\Models\Schedule;
use App\Models\AcademicClass;
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
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:users,email',
            'password' => 'required|min:8',
            'role' => 'required|in:admin,user,student,teacher',
            'gender' => 'required|in:male,female',
            'dob' => 'nullable|date',
            'faculty_id' => 'required|exists:faculties,id',
            'major_id' => 'required|exists:majors,id',
            'academic_class_id' => 'nullable|exists:academic_classes,id',
            'year' => 'required',
            'shift_id' => 'required|exists:shifts,id',
            'schedule_id' => 'required|exists:schedules,id',
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

        // 1. Create User in Firestore
        $userData = [
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'student',
        ];

        // We check if user already exists in Firestore by email
        $existing = $firestore->all('users', [['email', '=', $validated['email']]], [], 1);
        if (!$existing->isEmpty()) {
            $this->addError('email', 'The email has already been taken in Firestore.');
            return;
        }

        $user = $firestore->create('users', $userData);
        $userId = $user['id'];

        // 2. Prepare Student Data
        $studentData = [
            'user_id' => $userId,
            'gender' => $this->gender,
            'dob' => $this->dob,
            'faculty_id' => (int)$this->faculty_id,
            'major_id' => (int)$this->major_id,
            'academic_class_id' => $this->academic_class_id ? (int)$this->academic_class_id : null,
            'year' => $this->year,
            'shift_id' => (int)$this->shift_id,
            'schedule_id' => (int)$this->schedule_id,
            'generation' => $this->generation,
        ];

        if ($this->photo) {
            $studentData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
        }

        // 3. Create Student record in Firestore
        // Note: In Firestore we can use a separate collection or subcollection.
        // Here we'll use a 'students' collection for consistency.
        $firestore->create('students', $studentData);

        $this->reset();
        $this->dispatch('studentCreated');
        session()->flash('success', 'Student created successfully in Firestore!');
    }

    public function render()
    {
        $firestore = app(\App\Services\FirestoreService::class);

        return view('livewire.students.student-create', [
            'faculties' => $firestore->all('faculties', [], ['name' => 'asc']),
            'majors' => $this->faculty_id 
                ? $firestore->all('majors', [['faculty_id', '=', (int)$this->faculty_id]], ['name' => 'asc'])
                : collect(),
            'academic_classes' => $this->major_id 
                ? $firestore->all('academic_classes', [['major_id', '=', (int)$this->major_id]], ['name' => 'asc'])
                : collect(),
            'schedules' => $firestore->all('schedules')->sortBy('full_display'),
            'shifts' => $firestore->all('shifts', [], ['name' => 'asc']),
        ]);
    }
}
