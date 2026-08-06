<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Backfill check_in_time for historical present records.
     *
     * check_in_time was never written by AttendanceSessionService::checkIn(),
     * so all existing rows are NULL. For "present" (status = 'Y') records the
     * creation timestamp is a faithful approximation of the actual check-in.
     */
    public function up(): void
    {
        DB::table('attendances')
            ->whereNull('check_in_time')
            ->where('status', 'Y')
            ->update(['check_in_time' => DB::raw('created_at')]);
    }

    public function down(): void
    {
        DB::table('attendances')
            ->where('status', 'Y')
            ->update(['check_in_time' => null]);
    }
};
