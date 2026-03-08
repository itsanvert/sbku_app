<?php

namespace App\Livewire\Teachers;

use App\Models\User;
use App\Models\Teacher;
use App\Models\Major;
use App\Models\Schedule;
use App\Models\Faculty;
use Livewire\Component;
use Illuminate\Support\Facades\Hash;

class TeacherEdit extends Component
{
    public $name = '';
    public $email = '';
    public $password = '';
    public $role = 'teacher';
    public $teacherId;
    public $userId;

    /* ---------------------------------
        Teacher Fields
    --------------------------------- */
    public $gender = '';
    public $major_id = '';
    public $year = '';
    public $schedule_id = '';
    public $phone = '';
    public $faculty_id = '';

    public function mount($teacherId)
    {
    $teacher = Teacher::with('user')->findOrFail($teacherId);

    $this->teacherId  = $teacher->id;
    $this->userId     = $teacher->user->id;
    $this->name       = $teacher->user->name;
    $this->email      = $teacher->user->email;
    $this->role       = $teacher->user->role;
    $this->gender     = $teacher->gender;
    $this->major_id   = $teacher->major_id;
    $this->year       = $teacher->year;
    $this->schedule_id     = $teacher->schedule_id;
    $this->phone      = $teacher->phone;
    $this->faculty_id = $teacher->faculty_id;
    }
    public function save()
    {
        // no change needed here (already validating role)

        $teacher = Teacher::with('user')->findOrFail($this->teacherId);

    $userData = ['name' => $this->name, 'email' => $this->email, 'role' => $this->role];
    if ($this->password) $userData['password'] = Hash::make($this->password);
    $teacher->user->update($userData);

    $teacher->update([
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
        'schedules' => Schedule::orderBy('name')->get(),
    ]);
}
}
