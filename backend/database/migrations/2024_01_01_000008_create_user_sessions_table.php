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
        Schema::create('user_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('device_name')->nullable();
            $table->string('device_type')->nullable(); // mobile, desktop, tablet
            $table->string('platform')->nullable(); // ios, android, web, desktop
            $table->string('browser')->nullable();
            $table->string('ip_address')->nullable();
            $table->string('location')->nullable();
            $table->string('session_id')->unique();
            $table->timestamp('last_activity')->nullable();
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_sessions');
    }
};
