<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->index('role', 'idx_users_role');
        });

        Schema::table('students', function (Blueprint $table) {
            $table->index('user_id', 'idx_students_user_id');
            $table->index('faculty_id', 'idx_students_faculty_id');
            $table->index('major_id', 'idx_students_major_id');
        });

        Schema::table('teachers', function (Blueprint $table) {
            $table->index('user_id', 'idx_teachers_user_id');
        });

        Schema::table('academic_classes', function (Blueprint $table) {
            $table->index('major_id', 'idx_academic_classes_major_id');
            $table->index(['name', 'code'], 'idx_academic_classes_name_code');
        });

        Schema::table('faculties', function (Blueprint $table) {
            $table->index('name', 'idx_faculties_name');
        });

        Schema::table('majors', function (Blueprint $table) {
            $table->index('name', 'idx_majors_name');
        });

        Schema::table('syllabuses', function (Blueprint $table) {
            $table->index('subject_id', 'idx_syllabuses_subject_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('idx_users_role');
        });

        Schema::table('students', function (Blueprint $table) {
            $table->dropIndex('idx_students_user_id');
            $table->dropIndex('idx_students_faculty_id');
            $table->dropIndex('idx_students_major_id');
        });

        Schema::table('teachers', function (Blueprint $table) {
            $table->dropIndex('idx_teachers_user_id');
        });

        Schema::table('academic_classes', function (Blueprint $table) {
            $table->dropIndex('idx_academic_classes_major_id');
            $table->dropIndex('idx_academic_classes_name_code');
        });

        Schema::table('faculties', function (Blueprint $table) {
            $table->dropIndex('idx_faculties_name');
        });

        Schema::table('majors', function (Blueprint $table) {
            $table->dropIndex('idx_majors_name');
        });

        Schema::table('syllabuses', function (Blueprint $table) {
            $table->dropIndex('idx_syllabuses_subject_id');
        });
    }
};
