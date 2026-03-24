<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('faculties', function (Blueprint $table) {
            $table->id();
            $table->string('name');
<<<<<<<< HEAD:backend/database/migrations/2026_03_01_104427_faculties.php
            $table->string('code')->unique();
========
>>>>>>>> c5cc328259959343239e08ca02d705f63e91810e:backend/database/migrations/2026_03_08_100000_create_faculties_table.php
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('faculties');
    }
};
