<?php

namespace App\Livewire\Teachers;

use App\Models\User;
use App\Models\Teacher;
use App\Models\Major;
use App\Models\Schedule;
use App\Models\Faculty;
use Livewire\Component;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class TeacherCreate extends Component
{
    /* ---------------------------------
        User Fields
    --------------------------------- */
    public $name = '';
    public $email = '';
    public $password = '';
    public $role = 'teacher';

    /* ---------------------------------
        Teacher Fields
    --------------------------------- */
    public $gender = '';
    public $major_id = '';
    public $year = '';
    public $schedule_id = '';
    public $phone = '';
    public $faculty_id = '';

    /* ---------------------------------
        Validation Rules
    --------------------------------- */
    protected function rules()
    {
        return [
            'name'       => 'required|string|max:255',
            'email'      => 'required|email|max:255|unique:users,email',
            'password'   => 'required|min:8',
            'gender'     => 'required|in:male,female',
            'major_id'   => 'required|exists:majors,id',
            'year'       => 'required',
            'schedule_id'   => 'required|exists:schedules,id',
            'phone'      => 'required|string|max:20',
            'faculty_id' => 'required|exists:faculties,id',
        ];
    }

    /* ---------------------------------
        Real-Time Validation (Optional)
    --------------------------------- */
    public function updated($property)
    {
        $this->validateOnly($property);
    }

    /* ---------------------------------
        Save Teacher
    --------------------------------- */
    public function save()
    {
        $validated = $this->validate();

        DB::transaction(function () use ($validated) {

            $user = User::create([
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role'     => 'teacher',
            ]);

            Teacher::create([
                'user_id'    => $user->id,
                'name'       => $this->name,
                'gender'     => $this->gender,
                'major_id'   => $this->major_id,
                'year'       => $this->year,
                'schedule_id'   => $this->schedule_id,
                'phone'      => $this->phone,
                'faculty_id' => $this->faculty_id,
            ]);
        });

        $this->reset();

         // notify index

session()->flash('success', 'Teacher created successfully!');
    }

    /* ---------------------------------
        Reset Form Cleanly
    --------------------------------- */
    protected function resetForm()
    {
        $this->reset([
            'name',
            'email',
            'password',
            'gender',
            'major_id',
            'year',
            'schedule_id',
            'phone',
            'faculty_id',
        ]);

        $this->role = 'teacher';
    }

    /* ---------------------------------
        Render
    --------------------------------- */
    public function render()
    {
        return view('livewire.teachers.teacher-create', [
            'majors' => Major::orderBy('name')->get(),
            'faculties' => Faculty::orderBy('name')->get(),
            'schedules' => Schedule::orderBy('name')->get(),
        ]);
    }
}
