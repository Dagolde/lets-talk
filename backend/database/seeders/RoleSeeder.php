<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create permissions
        $permissions = [
            // User management
            'view users',
            'create users',
            'edit users',
            'delete users',
            'block users',
            'suspend users',
            
            // Chat management
            'view chats',
            'create chats',
            'edit chats',
            'delete chats',
            'moderate chats',
            
            // Payment management
            'view payments',
            'process payments',
            'refund payments',
            'view payment reports',
            
            // System management
            'view analytics',
            'view system health',
            'manage settings',
            'view logs',
            
            // Admin management
            'manage admins',
            'view admin dashboard',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles
        $adminRole = Role::firstOrCreate(['name' => 'admin']);
        $userRole = Role::firstOrCreate(['name' => 'user']);
        $moderatorRole = Role::firstOrCreate(['name' => 'moderator']);

        // Assign permissions to admin role
        $adminRole->givePermissionTo(Permission::all());

        // Assign permissions to moderator role
        $moderatorRole->givePermissionTo([
            'view users',
            'view chats',
            'moderate chats',
            'view payments',
            'view analytics',
        ]);

        // Assign basic permissions to user role
        $userRole->givePermissionTo([
            'view chats',
            'create chats',
        ]);
    }
}
