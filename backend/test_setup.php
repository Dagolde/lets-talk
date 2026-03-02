<?php

/**
 * Test script to verify Laravel backend setup
 * Run this script to check if everything is working correctly
 */

echo "=== Let's Talk Backend Setup Test ===\n\n";

// Check PHP version
echo "1. PHP Version: " . PHP_VERSION . "\n";
if (version_compare(PHP_VERSION, '8.2.0', '>=')) {
    echo "   ✓ PHP version is compatible\n";
} else {
    echo "   ✗ PHP version must be 8.2.0 or higher\n";
    exit(1);
}

// Check required extensions
$required_extensions = [
    'bcmath', 'ctype', 'fileinfo', 'json', 'mbstring', 
    'openssl', 'pdo', 'tokenizer', 'xml', 'curl', 'gd'
];

echo "\n2. Required PHP Extensions:\n";
foreach ($required_extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "   ✓ $ext\n";
    } else {
        echo "   ✗ $ext (missing)\n";
    }
}

// Check if we're in the right directory
echo "\n3. Directory Structure:\n";
$current_dir = __DIR__;
echo "   Current directory: $current_dir\n";

$required_files = [
    'artisan',
    'composer.json',
    'app/Models/User.php',
    'app/Http/Controllers/API/AuthController.php',
    'routes/api.php',
    'database/migrations/2024_01_01_000001_create_users_table.php'
];

foreach ($required_files as $file) {
    if (file_exists($file)) {
        echo "   ✓ $file\n";
    } else {
        echo "   ✗ $file (missing)\n";
    }
}

// Check if vendor directory exists
echo "\n4. Dependencies:\n";
if (file_exists('vendor')) {
    echo "   ✓ Vendor directory exists\n";
    
    // Check if autoload exists
    if (file_exists('vendor/autoload.php')) {
        echo "   ✓ Autoload file exists\n";
    } else {
        echo "   ✗ Autoload file missing\n";
    }
} else {
    echo "   ✗ Vendor directory missing - run 'composer install'\n";
}

// Check .env file
echo "\n5. Environment Configuration:\n";
if (file_exists('.env')) {
    echo "   ✓ .env file exists\n";
} else {
    echo "   ✗ .env file missing - copy from .env.example\n";
}

// Check storage permissions
echo "\n6. Storage Permissions:\n";
$storage_dirs = ['storage', 'storage/app', 'storage/framework', 'storage/logs'];
foreach ($storage_dirs as $dir) {
    if (is_dir($dir) && is_writable($dir)) {
        echo "   ✓ $dir (writable)\n";
    } else {
        echo "   ✗ $dir (not writable or missing)\n";
    }
}

// Check database configuration
echo "\n7. Database Configuration:\n";
if (file_exists('.env')) {
    $env_content = file_get_contents('.env');
    if (strpos($env_content, 'DB_DATABASE=lets_talk_db') !== false) {
        echo "   ✓ Database name configured\n";
    } else {
        echo "   ✗ Database name not configured\n";
    }
    
    if (strpos($env_content, 'DB_USERNAME=root') !== false) {
        echo "   ✓ Database username configured\n";
    } else {
        echo "   ✗ Database username not configured\n";
    }
} else {
    echo "   ✗ Cannot check database configuration (no .env file)\n";
}

echo "\n=== Setup Instructions ===\n";
echo "1. Make sure XAMPP is running (Apache and MySQL)\n";
echo "2. Create database 'lets_talk_db' in phpMyAdmin\n";
echo "3. Run: composer install\n";
echo "4. Run: php artisan key:generate\n";
echo "5. Run: php artisan migrate\n";
echo "6. Run: php artisan storage:link\n";
echo "7. Access the API at: http://localhost/lets-talk/backend/public/api\n";
echo "8. Access the admin panel at: http://localhost/lets-talk/backend/public/admin\n";

echo "\n=== WhatsApp-Style API Endpoints ===\n";
echo "POST /api/send-phone-verification - Send phone verification code for registration\n";
echo "POST /api/verify-phone-and-register - Verify phone and create account\n";
echo "POST /api/send-login-code - Send login verification code\n";
echo "POST /api/verify-login-code - Verify login code and authenticate\n";
echo "POST /api/user/enable-two-factor - Enable two-step verification\n";
echo "POST /api/user/disable-two-factor - Disable two-step verification\n";
echo "POST /api/user/verify-two-factor - Verify two-step verification code\n";
echo "GET /api/user/sessions - Get user sessions\n";
echo "POST /api/user/terminate-session - Terminate a session\n";
echo "POST /api/user/terminate-all-other-sessions - Terminate all other sessions\n";

echo "\n=== Admin Dashboard Endpoints ===\n";
echo "GET /api/admin/dashboard - Get admin dashboard statistics\n";
echo "GET /api/admin/users - Get all users with filters\n";
echo "GET /api/admin/users/{id} - Get user details\n";
echo "POST /api/admin/users/{id}/status - Update user status (block/unblock/suspend)\n";
echo "GET /api/admin/settings - Get admin settings\n";
echo "POST /api/admin/settings - Update admin settings\n";
echo "GET /api/admin/analytics - Get app analytics\n";
echo "GET /api/admin/system-health - Get system health status\n";
echo "POST /api/admin/initialize-settings - Initialize default settings\n";

echo "\n=== WhatsApp-Style Features ===\n";
echo "✓ Phone-based registration and login\n";
echo "✓ Two-step verification (SMS, Email, Authenticator)\n";
echo "✓ Session management across devices\n";
echo "✓ Admin control over app features\n";
echo "✓ User blocking and suspension\n";
echo "✓ Real-time statistics and analytics\n";

echo "\n=== Test Complete ===\n";
