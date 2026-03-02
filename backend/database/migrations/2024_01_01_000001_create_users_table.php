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
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone')->unique(); // WhatsApp-style: phone is required and unique
            $table->text('bio')->nullable();
            $table->string('avatar')->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('phone_verified_at')->nullable(); // WhatsApp-style: phone verification
            $table->boolean('is_online')->default(false);
            $table->timestamp('last_seen_at')->nullable();
            $table->json('preferences')->nullable();
            $table->json('settings')->nullable();
            $table->string('language')->default('en');
            $table->string('timezone')->default('UTC');
            $table->string('currency')->default('USD');
            
            // Two-step verification fields (WhatsApp-style)
            $table->boolean('two_factor_enabled')->default(false);
            $table->string('two_factor_method')->default('sms'); // sms, email, authenticator
            $table->string('two_factor_secret')->nullable(); // For authenticator apps
            $table->string('backup_codes')->nullable(); // JSON array of backup codes
            
            // Account status
            $table->boolean('is_blocked')->default(false);
            $table->boolean('is_suspended')->default(false);
            $table->timestamp('suspended_until')->nullable();
            $table->text('suspension_reason')->nullable();
            
            // Verification tokens
            $table->string('verification_token')->nullable();
            $table->string('password_reset_token')->nullable();
            $table->string('phone_verification_code')->nullable();
            $table->timestamp('phone_verification_expires_at')->nullable();
            
            // WhatsApp-style fields
            $table->string('status')->default('Hey there! I am using Let\'s Talk.'); // WhatsApp status
            $table->boolean('read_receipts')->default(true);
            $table->boolean('typing_indicators')->default(true);
            $table->boolean('profile_photo_visible')->default(true);
            $table->boolean('last_seen_visible')->default(true);
            $table->boolean('about_visible')->default(true);
            $table->boolean('groups_visible')->default(true);
            
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
