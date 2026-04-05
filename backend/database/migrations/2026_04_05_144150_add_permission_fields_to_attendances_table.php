<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->text('permission_reason')->nullable()->after('noted');
            $table->string('permission_image')->nullable()->after('permission_reason');
        });

        // Add 'P' to the status enum (using raw SQL for safety with enums)
        DB::statement("ALTER TABLE attendances MODIFY COLUMN status ENUM('Y', 'N', 'P') DEFAULT 'N'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn(['permission_reason', 'permission_image']);
        });

        DB::statement("ALTER TABLE attendances MODIFY COLUMN status ENUM('Y', 'N') DEFAULT 'N'");
    }
};
