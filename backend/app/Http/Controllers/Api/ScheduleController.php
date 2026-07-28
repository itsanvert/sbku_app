<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Schedule;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    /**
     * List schedules for a teacher, optionally filtered by day_of_the_week.
     *
     * GET /api/schedules?teacher_id=1&day=Monday
     */
    public function index(Request $request)
    {
        $request->validate([
            'teacher_id' => 'required|exists:teachers,id',
            'day'        => 'nullable|string',
        ]);

        $query = Schedule::forTeacher((int) $request->teacher_id)
            ->with(['subject:id,name', 'academicClass:id,name', 'room:id,name']);

        if ($request->day) {
            $query->forDay($request->day);
        }

        $schedules = $query->orderBy('start_time')->get();

        return response()->json($schedules);
    }
}
