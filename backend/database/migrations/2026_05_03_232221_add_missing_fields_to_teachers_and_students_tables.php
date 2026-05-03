<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Fix Teachers table
        Schema::table('teachers', function (Blueprint $table) {
            if (!Schema::hasColumn('teachers', 'profile_image_path')) {
                $table->string('profile_image_path')->nullable();
            }
            if (!Schema::hasColumn('teachers', 'shift_id')) {
                $table->foreignId('shift_id')->nullable()->constrained('shifts')->nullOnDelete();
            }
        });

        // Fix Students table
        Schema::table('students', function (Blueprint $table) {
            if (!Schema::hasColumn('students', 'profile_image_path')) {
                $table->string('profile_image_path')->nullable();
            }
            
            // Drop old string 'shift' column if it exists and replace with shift_id
            if (Schema::hasColumn('students', 'shift')) {
                $table->dropColumn('shift');
            }
            
            if (!Schema::hasColumn('students', 'shift_id')) {
                $table->foreignId('shift_id')->nullable()->constrained('shifts')->nullOnDelete();
            }

            if (!Schema::hasColumn('students', 'schedule_id')) {
                $table->foreignId('schedule_id')->nullable()->constrained('schedules')->nullOnDelete();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('teachers', function (Blueprint $table) {
            $table->dropColumn(['profile_image_path', 'shift_id']);
        });

        Schema::table('students', function (Blueprint $table) {
            $table->dropColumn(['profile_image_path', 'shift_id', 'schedule_id']);
            $table->string('shift')->nullable();
        });
    }
};
