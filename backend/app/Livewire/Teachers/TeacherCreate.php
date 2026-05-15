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
        $isProd = config('app.env') === 'production';
        return [
            'name'       => 'required|string|max:255',
            'email'      => 'required|email|max:255' . ($isProd ? '' : '|unique:users,email'),
            'password'   => 'required|min:8',
            'role'       => 'required|in:admin,user,student,teacher',
            'gender'     => 'required|in:male,female',
            'faculty_id' => 'required' . ($isProd ? '' : '|exists:faculties,id'),
            'major_id'   => 'required' . ($isProd ? '' : '|exists:majors,id'),
            'year'       => 'required',
            'schedule_id'   => 'required' . ($isProd ? '' : '|exists:schedules,id'),
            'shift_id'   => 'required' . ($isProd ? '' : '|exists:shifts,id'),
            'phone'      => 'required|string|max:20',
            'photo'      => 'nullable|image|max:1024',
        ];
    }

    public function updatedFacultyId()
    {
        $this->major_id = '';
    }

    public function save()
    {
        $validated = $this->validate();
        $firestore = app(\App\Services\FirestoreService::class);

        if (config('app.env') === 'production') {
            $userData = [
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role'     => 'teacher',
                'created_at' => now()->format('Y-m-d H:i:s'),
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ];
            $userId = $firestore->create('users', $userData);

            $teacherData = [
                'user_id'    => (string)$userId,
                'user_name'  => $validated['name'],
                'user_email' => $validated['email'],
                'gender'     => $this->gender,
                'faculty_id' => (string)$this->faculty_id,
                'major_id'   => (string)$this->major_id,
                'year'       => $this->year,
                'schedule_id' => (string)$this->schedule_id,
                'shift_id'   => (string)$this->shift_id,
                'phone'      => $this->phone,
                'created_at' => now()->format('Y-m-d H:i:s'),
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ];

            if ($this->photo) {
                $teacherData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
            }

            $firestore->create('teachers', $teacherData);
        } else {
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

                $user->teacher()->update($teacherData);
            });
        }

        $this->reset();
        $this->dispatch('teacherCreated');
        session()->flash('success', 'Teacher created successfully!');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $firestore = app(\App\Services\FirestoreService::class);
            return view('livewire.teachers.teacher-create', [
                'faculties' => collect($firestore->list('faculties'))->sortBy('name'),
                'majors' => $this->faculty_id 
                    ? collect($firestore->list('majors', ['faculty_id' => (string)$this->faculty_id]))->sortBy('name')
                    : collect(),
                'schedules' => collect($firestore->list('schedules')),
                'shifts' => collect($firestore->list('shifts'))->sortBy('name'),
            ]);
        }

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
