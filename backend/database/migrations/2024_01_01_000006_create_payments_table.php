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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sender_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('recipient_id')->constrained('users')->onDelete('cascade');
            $table->decimal('amount', 15, 2);
            $table->string('currency', 3)->default('USD');
            $table->text('description')->nullable();
            $table->enum('type', ['transfer', 'request', 'payment', 'refund'])->default('transfer');
            $table->enum('status', ['pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded'])->default('pending');
            $table->enum('gateway', ['stripe', 'paystack', 'flutterwave', 'internal'])->default('internal');
            $table->string('gateway_transaction_id')->nullable();
            $table->string('gateway_payment_intent_id')->nullable();
            $table->string('gateway_refund_id')->nullable();
            $table->decimal('gateway_fee', 10, 2)->default(0);
            $table->decimal('processing_fee', 10, 2)->default(0);
            $table->decimal('total_amount', 15, 2);
            $table->string('total_currency', 3)->default('USD');
            $table->decimal('exchange_rate', 10, 6)->default(1);
            $table->string('reference')->unique();
            $table->json('metadata')->nullable();
            $table->text('failure_reason')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamp('refunded_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
