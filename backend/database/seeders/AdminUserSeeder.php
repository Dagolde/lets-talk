<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user
        $admin = User::firstOrCreate(
            ['email' => 'admin@letstalk.com'],
            [
                'name' => 'Admin User',
                'phone' => '+1234567890',
                'password' => Hash::make('admin123'),
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'is_online' => false,
            ]
        );

        // Assign admin role
        $admin->assignRole('admin');

        // Create wallet for admin
        Wallet::firstOrCreate(
            ['user_id' => $admin->id],
            [
                'balance' => 0,
                'currency' => 'USD',
                'is_active' => true,
            ]
        );

        // Create a regular user for testing
        $user = User::firstOrCreate(
            ['email' => 'user@letstalk.com'],
            [
                'name' => 'Test User',
                'phone' => '+1234567891',
                'password' => Hash::make('user123'),
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'is_online' => false,
            ]
        );

        // Assign user role
        $user->assignRole('user');

        // Create wallet for user
        Wallet::firstOrCreate(
            ['user_id' => $user->id],
            [
                'balance' => 100, // Give some initial balance for testing
                'currency' => 'USD',
                'is_active' => true,
            ]
        );

        $this->command->info('Admin user created successfully!');
        $this->command->info('Admin Email: admin@letstalk.com');
        $this->command->info('Admin Password: admin123');
        $this->command->info('Test User Email: user@letstalk.com');
        $this->command->info('Test User Password: user123');
    }
}
