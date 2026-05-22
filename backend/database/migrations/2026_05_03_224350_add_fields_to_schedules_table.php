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
        Schema::table('schedules', function (Blueprint $table) {
            if (!Schema::hasColumn('schedules', 'day_of_the_week')) {
                $table->string('day_of_the_week')->nullable();
            }
            if (!Schema::hasColumn('schedules', 'start_time')) {
                $table->time('start_time')->nullable();
            }
            if (!Schema::hasColumn('schedules', 'end_time')) {
                $table->time('end_time')->nullable();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            //
        });
    }
};
