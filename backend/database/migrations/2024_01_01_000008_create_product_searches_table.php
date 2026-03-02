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
        Schema::create('product_searches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('query')->nullable();
            $table->string('category')->nullable();
            $table->decimal('price_min', 10, 2)->nullable();
            $table->decimal('price_max', 10, 2)->nullable();
            $table->string('location')->nullable();
            $table->enum('type', ['text_search', 'image_search', 'voice_search'])->default('text_search');
            $table->integer('results_count')->nullable();
            $table->integer('search_duration')->nullable(); // in milliseconds
            $table->timestamps();
            
            $table->index(['user_id', 'created_at']);
            $table->index('query');
            $table->index('category');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('product_searches');
    }
};
