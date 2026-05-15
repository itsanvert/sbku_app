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

class TeacherEdit extends Component
{
    use WithFileUploads;

    public $name = '';
    public $email = '';
    public $password = '';
    public $role = 'teacher';
    public $teacherId;
    public $userId;
    public $photo;
    public $existingPhoto;

    /* ---------------------------------
        Teacher Fields
    --------------------------------- */
    public $gender = '';
    public $major_id = '';
    public $year = '';
    public $schedule_id = '';
    public $shift_id = '';
    public $phone = '';
    public $faculty_id = '';

    public function mount($teacherId)
    {
        if (config('app.env') === 'production') {
            $firestore = app(\App\Services\FirestoreService::class);
            $teacher = $firestore->getDocument('teachers', (string)$teacherId);
            if (!$teacher) abort(404);

            $this->teacherId  = $teacher['id'];
            $this->userId     = $teacher['user_id'];
            $this->name       = $teacher['user_name'] ?? '—';
            $this->email      = $teacher['user_email'] ?? '—';
            $this->role       = 'teacher';
            $this->gender     = $teacher['gender'] ?? '';
            $this->major_id   = $teacher['major_id'] ?? '';
            $this->year       = $teacher['year'] ?? '';
            $this->schedule_id = $teacher['schedule_id'] ?? '';
            $this->shift_id     = $teacher['shift_id'] ?? '';
            $this->phone      = $teacher['phone'] ?? '';
            $this->faculty_id = $teacher['faculty_id'] ?? '';
            $this->existingPhoto = $teacher['profile_image_path'] ?? null;
        } else {
            $teacher = Teacher::with('user')->findOrFail($teacherId);

            $this->teacherId  = $teacher->id;
            $this->userId     = $teacher->user->id;
            $this->name       = $teacher->user->name;
            $this->email      = $teacher->user->email;
            $this->role       = $teacher->user->role;
            $this->gender     = $teacher->gender;
            $this->major_id   = $teacher->major_id;
            $this->year       = $teacher->year;
            $this->schedule_id = $teacher->schedule_id;
            $this->shift_id     = $teacher->shift_id;
            $this->phone      = $teacher->phone;
            $this->faculty_id = $teacher->faculty_id;
            $this->existingPhoto = $teacher->profile_image_path;
        }
    }

    public function updatedFacultyId()
    {
        $this->major_id = '';
    }

    public function save()
    {
        $isProd = config('app.env') === 'production';
        $this->validate([
            'name' => 'required',
            'email' => 'required|email' . ($isProd ? '' : '|unique:users,email,'.$this->userId),
            'photo' => 'nullable|image|max:1024',
        ]);

        if ($isProd) {
            $firestore = app(\App\Services\FirestoreService::class);
            $userData = ['name' => $this->name, 'email' => $this->email, 'updated_at' => now()->format('Y-m-d H:i:s')];
            if ($this->password) {
                $userData['password'] = Hash::make($this->password);
            }
            $firestore->update('users', (string)$this->userId, $userData);

            $teacherData = [
                'user_name'  => $this->name,
                'user_email' => $this->email,
                'gender'     => $this->gender,
                'major_id'   => (string)$this->major_id,
                'year'       => $this->year,
                'schedule_id' => (string)$this->schedule_id,
                'shift_id'   => (string)$this->shift_id,
                'phone'      => $this->phone,
                'faculty_id' => (string)$this->faculty_id,
                'updated_at' => now()->format('Y-m-d H:i:s'),
            ];

            if ($this->photo) {
                $teacherData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
            }

            $firestore->update('teachers', (string)$this->teacherId, $teacherData);
        } else {
            $teacher = Teacher::with('user')->findOrFail($this->teacherId);

            $userData = ['name' => $this->name, 'email' => $this->email, 'role' => $this->role];
            if ($this->password) {
                $userData['password'] = Hash::make($this->password);
            }
            $studentUser = $teacher->user;
            if($studentUser) {
                 $studentUser->update($userData);
            }

            $teacherData = [
                'gender'     => $this->gender,
                'major_id'   => $this->major_id,
                'year'       => $this->year,
                'schedule_id'   => $this->schedule_id,
                'shift_id'   => $this->shift_id,
                'phone'      => $this->phone,
                'faculty_id' => $this->faculty_id,
            ];

            if ($this->photo) {
                $teacherData['profile_image_path'] = $this->photo->store('profile-photos', 'public');
            }

            $teacher->update($teacherData);
        }

        $this->dispatch('teacherUpdated');
    }

    public function render()
    {
        if (config('app.env') === 'production') {
            $firestore = app(\App\Services\FirestoreService::class);
            return view('livewire.teachers.teacher-edit', [
                'faculties' => collect($firestore->list('faculties'))->sortBy('name'),
                'majors' => $this->faculty_id 
                    ? collect($firestore->list('majors', ['faculty_id' => (string)$this->faculty_id]))->sortBy('name')
                    : collect(),
                'schedules' => collect($firestore->list('schedules')),
                'shifts'    => collect($firestore->list('shifts'))->sortBy('name'),
            ]);
        }

        return view('livewire.teachers.teacher-edit', [
            'faculties' => Faculty::orderBy('name')->get(),
            'majors' => $this->faculty_id 
                ? Major::where('faculty_id', $this->faculty_id)->orderBy('name')->get() 
                : collect(),
            'schedules' => Schedule::all()->sortBy(function($s) {
                return $s->full_display;
            }),
            'shifts'    => Shift::orderBy('name')->get(),
        ]);
    }
}
