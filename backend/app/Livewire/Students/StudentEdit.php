<?php

namespace App\Livewire\Students;

use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use App\Models\Faculty;
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
    public $year = '';
    public $faculty_id = '';
    public $dob = '';
    public $shift = '';
    public $generation = '';

    public function mount($studentId)
    {
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
        $this->year       = $student->year;
        $this->shift      = $student->shift;
        $this->generation = $student->generation;
        $this->existingPhoto = $student->profile_image_path;
    }

    public function save()
    {
        $this->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users,email,'.$this->userId,
            'photo' => 'nullable|image|max:1024',
        ]);

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
            'year'       => $this->year,
            'shift'      => $this->shift,
            'generation' => $this->generation,
        ];

        if ($this->photo) {
            $studentData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
        }

        $student->update($studentData);

        $this->dispatch('studentUpdated');
    }

    public function render()
    {
        return view('livewire.students.student-edit', [
            'majors'    => Major::orderBy('name')->get(),
            'faculties' => Faculty::orderBy('name')->get(),
        ]);
    }
}
