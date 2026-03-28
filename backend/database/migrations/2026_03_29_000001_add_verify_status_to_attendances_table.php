<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * verify_status lifecycle:
     *   pending  – student scanned QR, waiting for teacher approval
     *   approved – teacher confirmed the student was physically present
     *   rejected – teacher rejected the check-in (suspected cheating / proxy)
     */
    public function up(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->enum('verify_status', ['pending', 'approved', 'rejected'])
                  ->default('pending')
                  ->after('status');

            $table->text('reject_reason')->nullable()->after('verify_status');
            $table->timestamp('verified_at')->nullable()->after('reject_reason');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn(['verify_status', 'reject_reason', 'verified_at']);
        });
    }
};
