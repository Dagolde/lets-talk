<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\AdminSetting;
use App\Models\Chat;
use App\Models\Payment;
use App\Models\Message;
use App\Models\UserSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    /**
     * Get admin dashboard statistics.
     */
    public function dashboard()
    {
        $stats = [
            'total_users' => User::count(),
            'active_users' => User::where('is_online', true)->count(),
            'new_users_today' => User::whereDate('created_at', today())->count(),
            'new_users_this_week' => User::whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()])->count(),
            'new_users_this_month' => User::whereMonth('created_at', now()->month)->count(),
            
            'total_chats' => Chat::count(),
            'active_chats' => Chat::where('is_active', true)->count(),
            'group_chats' => Chat::where('type', 'group')->count(),
            'direct_chats' => Chat::where('type', 'direct')->count(),
            
            'total_messages' => Message::count(),
            'messages_today' => Message::whereDate('created_at', today())->count(),
            'media_messages' => Message::whereIn('type', ['image', 'video', 'audio', 'file'])->count(),
            
            'total_payments' => Payment::count(),
            'completed_payments' => Payment::where('status', 'completed')->count(),
            'pending_payments' => Payment::where('status', 'pending')->count(),
            'total_payment_volume' => Payment::where('status', 'completed')->sum('amount'),
            
            'active_sessions' => UserSession::where('is_active', true)->count(),
            'blocked_users' => User::where('is_blocked', true)->count(),
            'suspended_users' => User::where('is_suspended', true)->count(),
        ];

        // Recent activities
        $recentUsers = User::latest()->take(5)->get();
        $recentPayments = Payment::with(['sender', 'recipient'])->latest()->take(5)->get();
        $recentMessages = Message::with(['sender', 'chat'])->latest()->take(5)->get();

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => $stats,
                'recent_users' => $recentUsers,
                'recent_payments' => $recentPayments,
                'recent_messages' => $recentMessages,
            ]
        ]);
    }

    /**
     * Get all users with pagination and filters.
     */
    public function getUsers(Request $request)
    {
        $query = User::with(['wallet']);

        // Apply filters
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        if ($request->has('status')) {
            switch ($request->status) {
                case 'online':
                    $query->where('is_online', true);
                    break;
                case 'offline':
                    $query->where('is_online', false);
                    break;
                case 'blocked':
                    $query->where('is_blocked', true);
                    break;
                case 'suspended':
                    $query->where('is_suspended', true);
                    break;
                case 'verified':
                    $query->whereNotNull('phone_verified_at');
                    break;
                case 'unverified':
                    $query->whereNull('phone_verified_at');
                    break;
            }
        }

        $users = $query->orderBy('created_at', 'desc')->paginate(20);

        // Add status field to each user
        $users->getCollection()->transform(function ($user) {
            $user->status = $this->getUserStatus($user);
            return $user;
        });

        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }

    /**
     * Get user status based on blocked/suspended state.
     */
    private function getUserStatus($user)
    {
        if ($user->is_blocked) {
            return 'blocked';
        } elseif ($user->is_suspended) {
            return 'suspended';
        } else {
            return 'active';
        }
    }

    /**
     * Get user details.
     */
    public function getUser($id)
    {
        $user = User::with(['wallet', 'sessions', 'chats', 'sentPayments', 'receivedPayments'])
                   ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $user
        ]);
    }

    /**
     * Update user status (block/unblock/suspend).
     */
    public function updateUserStatus(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'action' => 'required|string|in:block,unblock,suspend,unsuspend',
            'reason' => 'nullable|string|max:500',
            'duration' => 'nullable|integer|min:1', // days for suspension
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::findOrFail($id);

        switch ($request->action) {
            case 'block':
                $user->update([
                    'is_blocked' => true,
                    'is_suspended' => false,
                    'suspended_until' => null,
                    'suspension_reason' => $request->reason,
                ]);
                break;
                
            case 'unblock':
                $user->update([
                    'is_blocked' => false,
                    'suspension_reason' => null,
                ]);
                break;
                
            case 'suspend':
                $user->update([
                    'is_suspended' => true,
                    'suspended_until' => $request->duration ? now()->addDays($request->duration) : null,
                    'suspension_reason' => $request->reason,
                ]);
                break;
                
            case 'unsuspend':
                $user->update([
                    'is_suspended' => false,
                    'suspended_until' => null,
                    'suspension_reason' => null,
                ]);
                break;
        }

        return response()->json([
            'success' => true,
            'message' => "User {$request->action}ed successfully"
        ]);
    }

    /**
     * Get admin settings.
     */
    public function getSettings(Request $request)
    {
        $query = AdminSetting::query();

        if ($request->has('group')) {
            $query->where('group', $request->group);
        }

        $settings = $query->orderBy('group')->orderBy('key')->get();

        // Convert to key-value pairs for frontend
        $settingsArray = [];
        foreach ($settings as $setting) {
            $settingsArray[$setting->key] = $setting->typed_value;
        }

        return response()->json([
            'success' => true,
            'settings' => $settingsArray
        ]);
    }

    /**
     * Update admin settings.
     */
    public function updateSettings(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'app_name' => 'nullable|string|max:255',
            'registration_enabled' => 'nullable|boolean',
            'phone_verification_required' => 'nullable|boolean',
            'stripe_enabled' => 'nullable|boolean',
            'paystack_enabled' => 'nullable|boolean',
            'flutterwave_enabled' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $updatedSettings = [];

        foreach ($request->all() as $key => $value) {
            $adminSetting = AdminSetting::where('key', $key)->first();
            if ($adminSetting) {
                $adminSetting->setTypedValue($value);
                $adminSetting->save();
                $updatedSettings[] = $adminSetting;
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Settings updated successfully',
            'data' => $updatedSettings
        ]);
    }

    /**
     * Get app statistics and analytics.
     */
    public function getAnalytics(Request $request)
    {
        $period = $request->get('period', '30'); // days

        $userStats = DB::table('users')
            ->selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->whereBetween('created_at', [now()->subDays($period), now()])
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $messageStats = DB::table('messages')
            ->selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->whereBetween('created_at', [now()->subDays($period), now()])
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $paymentStats = DB::table('payments')
            ->selectRaw('DATE(created_at) as date, COUNT(*) as count, SUM(amount) as volume')
            ->whereBetween('created_at', [now()->subDays($period), now()])
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Platform distribution
        $platformStats = UserSession::selectRaw('platform, COUNT(*) as count')
            ->where('is_active', true)
            ->groupBy('platform')
            ->get();

        // Device type distribution
        $deviceStats = UserSession::selectRaw('device_type, COUNT(*) as count')
            ->where('is_active', true)
            ->groupBy('device_type')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'user_stats' => $userStats,
                'message_stats' => $messageStats,
                'payment_stats' => $paymentStats,
                'platform_stats' => $platformStats,
                'device_stats' => $deviceStats,
            ]
        ]);
    }

    /**
     * Get system health and status.
     */
    public function getSystemHealth()
    {
        $health = [
            'database' => [
                'status' => 'healthy',
                'connections' => DB::connection()->getPdo() ? 'connected' : 'disconnected',
            ],
            'cache' => [
                'status' => 'healthy',
                'driver' => config('cache.default'),
            ],
            'storage' => [
                'status' => is_writable(storage_path()) ? 'healthy' : 'error',
                'writable' => is_writable(storage_path()),
            ],
            'queue' => [
                'status' => 'healthy',
                'driver' => config('queue.default'),
            ],
            'app_settings' => [
                'debug_mode' => config('app.debug'),
                'environment' => config('app.env'),
                'timezone' => config('app.timezone'),
            ],
        ];

        return response()->json([
            'success' => true,
            'data' => $health
        ]);
    }



    /**
     * Create a new user.
     */
    public function createUser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'phone' => 'required|string|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => bcrypt($request->password),
            'phone_verified_at' => now(), // Auto-verify admin-created users
        ]);

        // Create wallet for the user
        $user->wallet()->create([
            'balance' => 0,
            'currency' => 'USD',
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User created successfully',
            'user' => $user->load('wallet')
        ]);
    }

    /**
     * Delete a user.
     */
    public function deleteUser($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        // Prevent deletion of admin users
        if ($user->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete admin users'
            ], 403);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User deleted successfully'
        ]);
    }

    /**
     * Initialize default admin settings.
     */
    public function initializeSettings()
    {
        $defaultSettings = [
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

        foreach ($defaultSettings as $setting) {
            AdminSetting::firstOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Default settings initialized successfully'
        ]);
    }
}
