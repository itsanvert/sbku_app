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
        // Add sync columns to all tables that use SyncsToFirestore trait
        $tables = ['users', 'teachers', 'students', 'subjects', 'shifts', 'schedules', 'messages', 'majors', 'faculties'];

        foreach ($tables as $table) {
            if (Schema::hasTable($table)) {
                Schema::table($table, function (Blueprint $t) use ($table) {
                    if (!Schema::hasColumn($table, '_synced_at')) {
                        $t->timestamp('_synced_at')->nullable()->after('updated_at');
                    }
                    if (!Schema::hasColumn($table, '_sync_event')) {
                        $t->string('_sync_event')->nullable()->after('_synced_at');
                    }
                    if (!Schema::hasColumn($table, '_synced_at_index')) {
                        try {
                            $t->index('_synced_at');
                        } catch (\Exception $e) {
                            // Index might already exist
                        }
                    }
                });
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $tables = ['users', 'teachers', 'students', 'subjects', 'shifts', 'schedules', 'messages', 'majors', 'faculties'];

        foreach ($tables as $table) {
            if (Schema::hasTable($table)) {
                Schema::table($table, function (Blueprint $table) {
                    $table->dropColumn(['_synced_at', '_sync_event']);
                });
            }
        }
    }
};
