<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Attendances: speed up student history, date reports, and duplicate check-in detection
        Schema::table('attendances', function (Blueprint $table) {
            $table->index(['student_id', 'attendance_date'], 'idx_attendance_student_date');
            $table->index(['session_id', 'student_id'], 'idx_attendance_session_student');
            $table->index('attendance_date', 'idx_attendance_date');
        });

        // Attendance sessions: speed up active session lookups and time-based queries
        Schema::table('attendance_sessions', function (Blueprint $table) {
            $table->index(['is_active', 'teacher_id'], 'idx_session_active_teacher');
            $table->index('started_at', 'idx_session_started_at');
        });

        // Schedules: speed up overlap detection and teacher schedule queries
        Schema::table('schedules', function (Blueprint $table) {
            $table->index(['day_of_the_week', 'start_time', 'end_time'], 'idx_schedule_day_time');
            $table->index('teacher_id', 'idx_schedule_teacher');
        });

        // Students: speed up absent logic filtering in endSession
        Schema::table('students', function (Blueprint $table) {
            $table->index(['faculty_id', 'major_id', 'year'], 'idx_student_faculty_major_year');
        });

        // Messages: speed up latest-message queries
        Schema::table('messages', function (Blueprint $table) {
            $table->index('created_at', 'idx_message_created_at');
        });
    }

    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropIndex('idx_attendance_student_date');
            $table->dropIndex('idx_attendance_session_student');
            $table->dropIndex('idx_attendance_date');
        });

        Schema::table('attendance_sessions', function (Blueprint $table) {
            $table->dropIndex('idx_session_active_teacher');
            $table->dropIndex('idx_session_started_at');
        });

        Schema::table('schedules', function (Blueprint $table) {
            $table->dropIndex('idx_schedule_day_time');
            $table->dropIndex('idx_schedule_teacher');
        });

        Schema::table('students', function (Blueprint $table) {
            $table->dropIndex('idx_student_faculty_major_year');
        });

        Schema::table('messages', function (Blueprint $table) {
            $table->dropIndex('idx_message_created_at');
        });
    }
};
