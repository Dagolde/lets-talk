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
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('chat_id')->constrained()->onDelete('cascade');
            $table->foreignId('sender_id')->constrained('users')->onDelete('cascade');
            $table->text('content')->nullable();
            $table->enum('type', ['text', 'image', 'video', 'audio', 'file', 'location', 'contact', 'payment'])->default('text');
            $table->string('file_path')->nullable();
            $table->string('file_name')->nullable();
            $table->bigInteger('file_size')->nullable();
            $table->string('file_type')->nullable();
            $table->string('thumbnail_path')->nullable();
            $table->integer('duration')->nullable(); // for audio/video
            $table->decimal('latitude', 10, 8)->nullable(); // for location
            $table->decimal('longitude', 11, 8)->nullable(); // for location
            $table->string('location_name')->nullable();
            $table->json('contact_data')->nullable(); // for contact sharing
            $table->json('payment_data')->nullable(); // for payment messages
            $table->foreignId('reply_to_id')->nullable()->constrained('messages')->onDelete('cascade');
            $table->boolean('is_edited')->default(false);
            $table->timestamp('edited_at')->nullable();
            $table->boolean('is_deleted')->default(false);
            $table->timestamp('deleted_at')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
