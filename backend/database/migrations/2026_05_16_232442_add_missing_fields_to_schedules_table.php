<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            if (!Schema::hasColumn('schedules', 'start_date')) {
                $table->date('start_date')->nullable();
            }
            if (!Schema::hasColumn('schedules', 'end_date')) {
                $table->date('end_date')->nullable();
            }
            if (!Schema::hasColumn('schedules', 'class_id')) {
                $table->foreignId('class_id')->nullable()->constrained('academic_classes')->onDelete('set null');
            }
            if (!Schema::hasColumn('schedules', 'teacher_id')) {
                $table->foreignId('teacher_id')->nullable()->constrained('teachers')->onDelete('set null');
            }
            if (!Schema::hasColumn('schedules', 'subject_id')) {
                $table->foreignId('subject_id')->nullable()->constrained('subjects')->onDelete('set null');
            }
        });
    }

    public function down(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            $table->dropForeign(['class_id']);
            $table->dropForeign(['teacher_id']);
            $table->dropForeign(['subject_id']);
            $table->dropColumn(['start_date', 'end_date', 'class_id', 'teacher_id', 'subject_id']);
        });
    }
};
