<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // PostgreSQL trigram extension for fast ILIKE / LIKE %wildcard% searches
        try {
            DB::statement('CREATE EXTENSION IF NOT EXISTS pg_trgm');
        } catch (\Exception $e) {
            // pg_trgm may not be available on Neon or other managed Postgres
        }

        Schema::table('users', function (Blueprint $table) {
            $table->index('name', 'idx_users_name');
            $table->index('email', 'idx_users_email');
        });

        // Trigram indexes accelerate queries using: WHERE name ILIKE '%search%'
        try {
            DB::statement('CREATE INDEX IF NOT EXISTS idx_users_name_trgm ON users USING gin (name gin_trgm_ops)');
            DB::statement('CREATE INDEX IF NOT EXISTS idx_users_email_trgm ON users USING gin (email gin_trgm_ops)');
        } catch (\Exception $e) {
            // Fallback: B-tree indexes already created above
        }

        // Personal access tokens: speed up Sanctum token lookups
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->index('token', 'idx_personal_access_tokens_token');
            $table->index('tokenable_id', 'idx_personal_access_tokens_tokenable_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('idx_users_name');
            $table->dropIndex('idx_users_email');
        });

        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->dropIndex('idx_personal_access_tokens_token');
            $table->dropIndex('idx_personal_access_tokens_tokenable_id');
        });

        try {
            DB::statement('DROP INDEX IF EXISTS idx_users_name_trgm');
            DB::statement('DROP INDEX IF EXISTS idx_users_email_trgm');
        } catch (\Exception $e) {
            //
        }
    }
};
