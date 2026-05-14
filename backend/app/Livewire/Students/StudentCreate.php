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

            // The User observer has already created a skeleton Student record.
            $user->student()->update($studentData);
        });

        $this->reset();
        $this->dispatch('studentCreated');
        session()->flash('success', 'Student created successfully!');
    }

    public function render()
    {
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
