<?php

require_once 'vendor/autoload.php';

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "Testing database connection...\n";

try {
    // Test connection
    DB::connection()->getPdo();
    echo "✅ Database connection successful\n";
    
    // Check if tables exist
    $tables = ['users', 'qr_codes', 'payments', 'chats', 'messages', 'notifications', 'contacts'];
    
    foreach ($tables as $table) {
        if (Schema::hasTable($table)) {
            echo "✅ Table '$table' exists\n";
        } else {
            echo "❌ Table '$table' missing\n";
        }
    }
    
} catch (Exception $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
}
