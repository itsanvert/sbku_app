<?php

namespace App\Livewire\Attendance;

use App\Models\AttendanceSession;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Schedule;
use App\Models\Teacher;
use Illuminate\Support\Str;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class AttendanceCreate extends Component
{
    public $teacher_id = '';
    public $faculty_id = '';
    public $major_id = '';
    public $schedule_id = '';
    public $latitude = '11.5564'; // Default to somewhere config
    public $longitude = '104.9282';

    protected $rules = [
        'teacher_id' => 'required',
        'faculty_id' => 'required',
        'major_id' => 'required',
        'schedule_id' => 'required',
        'latitude' => 'required|numeric',
        'longitude' => 'required|numeric',
    ];

    public function createSession()
    {
        $this->validate();

        AttendanceSession::create([
            'teacher_id' => $this->teacher_id,
            'faculty_id' => $this->faculty_id,
            'major_id' => $this->major_id,
            'schedule_id' => $this->schedule_id,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'started_at' => now(),
            'is_active' => true,
            'qr_token' => Str::random(32),
        ]);

        session()->flash('message', 'Attendance Session created successfully.');

        return $this->redirectRoute('attendance.sessions.index', navigate: true);
    }

    public function render()
    {
        return view('livewire.attendance.attendance-create', [
            'teachers' => Teacher::with('user')->get(),
            'faculties' => Faculty::all(),
            'majors' => Major::all(),
            'schedules' => Schedule::all(),
        ]);
    }
}
