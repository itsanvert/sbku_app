<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Faculty;
use App\Models\Major;
use App\Models\Shift;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\Syllabus;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create Faculty
        $itFaculty = Faculty::firstOrCreate(['name' => 'មហាវិទ្យាល័យបច្ចេកវិទ្យា (Technology)']);
        $bizFaculty = Faculty::firstOrCreate(['name' => 'មហាវិទ្យាល័យគ្រប់គ្រង (Management)']);

        // 2. Create Major
        $csMajor = Major::firstOrCreate(
            ['name' => 'Computer Science'],
            ['faculty_id' => $itFaculty->id]
        );
        $baMajor = Major::firstOrCreate(
            ['name' => 'Business Administration'],
            ['faculty_id' => $bizFaculty->id]
        );

        // 3. Create Shift
        $morningShift = Shift::firstOrCreate(['name' => 'ព្រឹក (Morning)']);
        $afternoonShift = Shift::firstOrCreate(['name' => 'រសៀល (Afternoon)']);

        // 4. Create Subjects
        $subjects = [
            ['name' => 'Introduction to IT', 'code' => 'IT101', 'credit_hours' => 3],
            ['name' => 'Programming Fundamentals', 'code' => 'IT102', 'credit_hours' => 4],
            ['name' => 'Data Structures', 'code' => 'IT201', 'credit_hours' => 3],
            ['name' => 'Database Systems', 'code' => 'IT202', 'credit_hours' => 3],
            ['name' => 'Software Engineering', 'code' => 'IT301', 'credit_hours' => 3],
            ['name' => 'Network Security', 'code' => 'IT302', 'credit_hours' => 3],
            ['name' => 'Artificial Intelligence', 'code' => 'IT401', 'credit_hours' => 3],
            ['name' => 'Cloud Computing', 'code' => 'IT402', 'credit_hours' => 3],
            ['name' => 'Final Thesis Project', 'code' => 'IT501', 'credit_hours' => 6],
        ];

        foreach ($subjects as $s) {
            Subject::firstOrCreate(['code' => $s['code']], $s);
        }

        // 5. Create Admin Users
        User::firstOrCreate(
            ['email' => 'superadmin@gmail.com'],
            [
                'name' => 'Super Admin',
                'password' => Hash::make('12345678'),
                'role' => 'super_admin',
            ]
        );

        User::firstOrCreate(
            ['email' => 'admin@gmail.com'],
            [
                'name' => 'Admin',
                'password' => Hash::make('12345678'),
                'role' => 'admin',
            ]
        );

        // 6. Create Teacher User
        $teacherUser = User::firstOrCreate(
            ['email' => 'teacher@sbku.edu.kh'],
            [
                'name' => 'Mr. Sophal Dara',
                'password' => Hash::make('password'),
                'role' => 'teacher',
            ]
        );

        $teacher = Teacher::updateOrCreate(
            ['user_id' => $teacherUser->id],
            [
                'gender' => 'Male',
                'faculty_id' => $itFaculty->id,
                'major_id' => $csMajor->id,
                'shift_id' => $morningShift->id,
                'phone' => '012-345-678',
                'year' => '2026',
            ]
        );

        // 6. Create Syllabus (Year 1 to 5)
        // Clean existing to avoid duplicates if re-seeding
        Syllabus::truncate();

        $syllabusData = [
            // Year 1
            [
                'year_id' => 'Y1', 'semester_id' => 1, 'subject_code' => 'IT101', 
                'shift_id' => $morningShift->id, 'schedule' => 'Mon 07:30 - 10:30'
            ],
            [
                'year_id' => 'Y1', 'semester_id' => 2, 'subject_code' => 'IT102', 
                'shift_id' => $morningShift->id, 'schedule' => 'Tue 08:00 - 11:30'
            ],
            // Year 2
            [
                'year_id' => 'Y2', 'semester_id' => 1, 'subject_code' => 'IT201', 
                'shift_id' => $morningShift->id, 'schedule' => 'Wed 13:00 - 16:00'
            ],
            // Year 3
            [
                'year_id' => 'Y3', 'semester_id' => 1, 'subject_code' => 'IT301', 
                'shift_id' => $afternoonShift->id, 'schedule' => 'Fri 07:30 - 10:30'
            ],
            // Year 4
            [
                'year_id' => 'Y4', 'semester_id' => 1, 'subject_code' => 'IT401', 
                'shift_id' => $morningShift->id, 'schedule' => 'Mon 13:00 - 16:00'
            ],
            // Year 5
            [
                'year_id' => 'Y5', 'semester_id' => 2, 'subject_code' => 'IT501', 
                'shift_id' => $morningShift->id, 'schedule' => 'Thesis Project'
            ],
        ];

        foreach ($syllabusData as $data) {
            $subject = Subject::where('code', $data['subject_code'])->first();
            Syllabus::create([
                'faculty_id' => $itFaculty->id,
                'major_id' => $csMajor->id,
                'subject_id' => $subject->id,
                'teacher_id' => $teacher->id,
                'shift_id' => $data['shift_id'],
                'year_id' => $data['year_id'],
                'semester_id' => $data['semester_id'],
                'schedule_description' => $data['schedule'],
            ]);
        }
    }
}
