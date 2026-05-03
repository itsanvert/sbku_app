<?php

namespace App\Livewire\Teachers;

use App\Models\User;
use App\Models\Teacher;
use App\Models\Major;
use App\Models\Schedule;
use App\Models\Shift;
use App\Models\Faculty;
use Livewire\Component;
use Livewire\WithFileUploads;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class TeacherCreate extends Component
{
    use WithFileUploads;

    /* ---------------------------------
        User Fields
    --------------------------------- */
    public $name = '';
    public $email = '';
    public $password = '';
    public $role = 'teacher';
    public $photo;

    /* ---------------------------------
        Teacher Fields
    --------------------------------- */
    public $gender = '';
    public $faculty_id = '';
    public $major_id = '';
    public $year = '';
    public $schedule_id = '';
    public $shift_id = '';
    public $phone = '';

    /* ---------------------------------
        Validation Rules
    --------------------------------- */
    protected function rules()
    {
        return [
            'name'       => 'required|string|max:255',
            'email'      => 'required|email|max:255|unique:users,email',
            'password'   => 'required|min:8',
            'role'       => 'required|in:admin,user,student,teacher',
            'gender'     => 'required|in:male,female',
            'faculty_id' => 'required|exists:faculties,id',
            'major_id'   => 'required|exists:majors,id',
            'year'       => 'required',
            'schedule_id'   => 'required|exists:schedules,id',
            'shift_id'   => 'required|exists:shifts,id',
            'phone'      => 'required|string|max:20',
            'photo'      => 'nullable|image|max:1024', // 1MB Max
        ];
    }

    public function updatedFacultyId()
    {
        $this->major_id = '';
    }

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

            $teacherData = [
                'gender'     => $this->gender,
                'faculty_id' => $this->faculty_id,
                'major_id'   => $this->major_id,
                'year'       => $this->year,
                'schedule_id'   => $this->schedule_id,
                'shift_id'   => $this->shift_id,
                'phone'      => $this->phone,
            ];

            if ($this->photo) {
                $teacherData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
            }

            // The User observer has already created a skeleton Teacher record.
            $user->teacher()->update($teacherData);
        });

        $this->reset();
        $this->dispatch('teacherCreated');
        session()->flash('success', 'Teacher created successfully!');
    }

    public function render()
    {
        return view('livewire.teachers.teacher-create', [
            'faculties' => Faculty::orderBy('name')->get(),
            'majors' => $this->faculty_id 
                ? Major::where('faculty_id', $this->faculty_id)->orderBy('name')->get() 
                : collect(),
            'schedules' => Schedule::all()->sortBy(function($s) {
                return $s->full_display;
            }),
            'shifts' => Shift::orderBy('name')->get(),
        ]);
    }
}
