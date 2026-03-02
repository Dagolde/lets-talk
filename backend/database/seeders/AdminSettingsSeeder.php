<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AdminSetting;

class AdminSettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
            // General settings
            ['key' => 'app_name', 'value' => "Let's Talk", 'type' => 'string', 'group' => 'general', 'description' => 'Application name'],
            ['key' => 'app_description', 'value' => 'A modern chat application', 'type' => 'string', 'group' => 'general', 'description' => 'Application description'],
            ['key' => 'maintenance_mode', 'value' => 'false', 'type' => 'boolean', 'group' => 'general', 'description' => 'Enable maintenance mode'],
            
            // Registration and authentication
            ['key' => 'registration_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'security', 'description' => 'Allow new user registrations'],
            ['key' => 'phone_verification_required', 'value' => 'true', 'type' => 'boolean', 'group' => 'security', 'description' => 'Require phone verification'],
            ['key' => 'two_factor_required', 'value' => 'false', 'type' => 'boolean', 'group' => 'security', 'description' => 'Require two-factor authentication'],
            ['key' => 'max_login_attempts', 'value' => '5', 'type' => 'integer', 'group' => 'security', 'description' => 'Maximum login attempts before lockout'],
            
            // Features
            ['key' => 'chat_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'features', 'description' => 'Enable chat functionality'],
            ['key' => 'group_chat_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'features', 'description' => 'Enable group chats'],
            ['key' => 'media_sharing_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'features', 'description' => 'Enable media sharing'],
            ['key' => 'qr_codes_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'features', 'description' => 'Enable QR code functionality'],
            ['key' => 'product_search_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'features', 'description' => 'Enable AI product search'],
            
            // Payments
            ['key' => 'payments_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'payments', 'description' => 'Enable payment functionality'],
            ['key' => 'stripe_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'payments', 'description' => 'Enable Stripe payments'],
            ['key' => 'paystack_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'payments', 'description' => 'Enable Paystack payments'],
            ['key' => 'flutterwave_enabled', 'value' => 'true', 'type' => 'boolean', 'group' => 'payments', 'description' => 'Enable Flutterwave payments'],
            ['key' => 'max_payment_amount', 'value' => '10000', 'type' => 'integer', 'group' => 'payments', 'description' => 'Maximum payment amount'],
            
            // Limits
            ['key' => 'max_group_members', 'value' => '256', 'type' => 'integer', 'group' => 'limits', 'description' => 'Maximum group members'],
            ['key' => 'max_message_length', 'value' => '4096', 'type' => 'integer', 'group' => 'limits', 'description' => 'Maximum message length'],
            ['key' => 'max_file_size', 'value' => '100', 'type' => 'integer', 'group' => 'limits', 'description' => 'Maximum file size in MB'],
        ];

        foreach ($settings as $setting) {
            AdminSetting::firstOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }
    }
}
