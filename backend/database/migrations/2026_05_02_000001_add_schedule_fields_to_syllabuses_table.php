<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('syllabuses', function (Blueprint $table) {
            // Structured scheduling fields
            $table->enum('day_of_week', [
                'monday', 'tuesday', 'wednesday', 'thursday',
                'friday', 'saturday', 'sunday',
            ])->nullable()->after('schedule_description');

            $table->time('start_time')->nullable()->after('day_of_week');
            $table->time('end_time')->nullable()->after('start_time');

            // Fast conflict-detection index: teacher + day + time range
            $table->index(
                ['teacher_id', 'day_of_week', 'start_time', 'end_time'],
                'idx_syl_teacher_day_time'
            );

            // Prevent the exact same slot being booked twice for a teacher
            $table->unique(
                ['teacher_id', 'subject_id', 'day_of_week', 'start_time'],
                'uq_syl_teacher_subject_slot'
            );
        });
    }

    public function down(): void
    {
        Schema::table('syllabuses', function (Blueprint $table) {
            $table->dropUnique('uq_syl_teacher_subject_slot');
            $table->dropIndex('idx_syl_teacher_day_time');
            $table->dropColumn(['day_of_week', 'start_time', 'end_time']);
        });
    }
};
