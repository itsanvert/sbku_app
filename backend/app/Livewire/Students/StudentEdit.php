<?php

namespace App\Livewire\Students;

use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use App\Models\Faculty;
use Livewire\Component;
use Illuminate\Support\Facades\Hash;

class StudentEdit extends Component
{
    public $name = '';
    public $email = '';
    public $password = '';
    public $role = 'student';
    public $id;
    public $userId;

    /* ---------------------------------
        Student Fields
    --------------------------------- */
    public $gender = '';
    public $major_id = '';
    public $year = '';
    public $schedule_id = '';
    public $phone = '';
    public $faculty_id = '';
    public $dob = '';
    public $shift = '';
    public $generation = '';

    public function mount($teacherId)
    {
    $student = Student::with('user')->findOrFail($this->id);

    $this->userId     = $student->user->id;
    $this->name       = $student->user->name;
    $this->gender     = $student->gender;  
    $this->dob        = $student->dob; 
    $this->faculty_id = $student->faculty_id;
    $this->major_id   = $student->major_id;
    $this->year       = $student->year;
    $this->shift      = $student->shift;
    $this->generation = $student->generation;
    $this->email      = $student->user->email;
    
    }
    public function save()
    {
        // no change needed here (already validating role)

        $student = Student::with('user')->findOrFail($this->studentId);

    $userData = ['name' => $this->name, 'email' => $this->email, 'role' => $this->role];
    if ($this->password) $userData['password'] = Hash::make($this->password);
    $student->user->update($userData);

    $student->update([
            'name'       => $this->name,
            'gender'     => $this->gender,
            'major_id'   => $this->major_id,
            'year'       => $this->year,
            'role'       => $this->role,
            'schedule_id'   => $this->schedule_id,
            'phone'      => $this->phone,
            'faculty_id' => $this->faculty_id,
        ]);
    $this->dispatch('teacherUpdated');
}


   public function render()
{
    return view('livewire.teachers.teacher-edit', [
        'majors'    => Major::orderBy('name')->get(),
        'faculties' => Faculty::orderBy('name')->get(),
        
    ]);
}
}
