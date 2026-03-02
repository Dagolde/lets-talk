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
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->decimal('balance', 15, 2)->default(0);
            $table->string('currency', 3)->default('USD');
            $table->boolean('is_active')->default(true);
            $table->boolean('is_frozen')->default(false);
            $table->timestamp('frozen_at')->nullable();
            $table->text('frozen_reason')->nullable();
            $table->decimal('daily_limit', 15, 2)->nullable();
            $table->decimal('monthly_limit', 15, 2)->nullable();
            $table->integer('total_transactions')->default(0);
            $table->decimal('total_volume', 15, 2)->default(0);
            $table->timestamp('last_transaction_at')->nullable();
            $table->json('settings')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};
