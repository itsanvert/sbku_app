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

        // Cross-platform way to update the column (works for both MySQL and PostgreSQL)
        Schema::table('attendances', function (Blueprint $table) {
            $table->string('status')->default('N')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn(['permission_reason', 'permission_image']);
            $table->string('status')->default('N')->change();
        });
    }
};
