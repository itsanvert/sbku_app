<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('attendance_sessions', function (Blueprint $table) {
            // Fix syllabus_id if it exists, or add it if it doesn't
            if (Schema::hasColumn('attendance_sessions', 'syllabus_id')) {
                $table->unsignedBigInteger('syllabus_id')->nullable()->change();
            } else {
                $table->unsignedBigInteger('syllabus_id')->nullable()->after('schedule_id');
            }
        });

        Schema::table('attendance_sessions', function (Blueprint $table) {
            // Add foreign key constraint if not already present
            // Note: Constrained expects the column to exist or creates it. 
            // Since we handled existence above, we just add the constraint here.
            $table->foreign('syllabus_id')->references('id')->on('syllabuses')->onDelete('set null');

            // Store subject info directly for historical accuracy
            if (!Schema::hasColumn('attendance_sessions', 'subject_id')) {
                $table->foreignId('subject_id')
                      ->nullable()
                      ->after('syllabus_id')
                      ->constrained('subjects')
                      ->onDelete('set null');
            }

            // Structured class info denormalized from syllabus
            if (!Schema::hasColumn('attendance_sessions', 'year_id')) {
                $table->string('year_id')->nullable()->after('subject_id');
            }
            if (!Schema::hasColumn('attendance_sessions', 'semester_id')) {
                $table->tinyInteger('semester_id')->nullable()->after('year_id');
            }
            if (!Schema::hasColumn('attendance_sessions', 'day_of_week')) {
                $table->string('day_of_week')->nullable()->after('semester_id');
            }
            if (!Schema::hasColumn('attendance_sessions', 'session_start_time')) {
                $table->time('session_start_time')->nullable()->after('day_of_week');
            }
            if (!Schema::hasColumn('attendance_sessions', 'session_end_time')) {
                $table->time('session_end_time')->nullable()->after('session_start_time');
            }
        });
    }

    public function down(): void
    {
        Schema::table('attendance_sessions', function (Blueprint $table) {
            try {
                $table->dropForeign(['syllabus_id']);
            } catch (\Exception $e) {}
            
            try {
                $table->dropForeign(['subject_id']);
            } catch (\Exception $e) {}

            $table->dropColumn([
                'syllabus_id', 'subject_id',
                'year_id', 'semester_id',
                'day_of_week', 'session_start_time', 'session_end_time',
            ]);
        });
    }
};
