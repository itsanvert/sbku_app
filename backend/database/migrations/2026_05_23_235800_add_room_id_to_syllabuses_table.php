<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('syllabuses', function (Blueprint $table) {
            if (!Schema::hasColumn('syllabuses', 'room_id')) {
                $table->foreignId('room_id')->nullable()->constrained('rooms')->onDelete('set null');
            }
        });
    }

    public function down(): void
    {
        Schema::table('syllabuses', function (Blueprint $table) {
            $table->dropForeign(['room_id']);
            $table->dropColumn('room_id');
        });
    }
};
