<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AdminAuthController extends Controller
{
    /**
     * Admin login
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
            'remember' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $credentials = $request->only('email', 'password');
        $remember = $request->boolean('remember', false);

        // Check if user exists and is an admin
        $user = User::where('email', $credentials['email'])->first();

        if (!$user) {
            return response()->json([
                'message' => 'Invalid credentials'
            ], 401);
        }

        // Check if user has admin role
        if (!$user->hasRole('admin')) {
            return response()->json([
                'message' => 'Access denied. Admin privileges required.'
            ], 403);
        }

        // Check if user is suspended
        if ($user->is_suspended) {
            return response()->json([
                'message' => 'Account is suspended. Please contact support.'
            ], 403);
        }

        // Attempt authentication
        if (Auth::attempt($credentials, $remember)) {
            $user = Auth::user();
            
            // Create token
            $token = $user->createToken('admin-token', ['admin'])->plainTextToken;

            // Update last login
            $user->update([
                'last_seen_at' => now(),
                'is_online' => true
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'avatar' => $user->avatar,
                    'roles' => $user->roles->pluck('name')
                ],
                'expires_in' => config('sanctum.expiration') * 60 // Convert to seconds
            ]);
        }

        return response()->json([
            'message' => 'Invalid credentials'
        ], 401);
    }

    /**
     * Admin logout
     */
    public function logout(Request $request)
    {
        $user = $request->user();
        
        if ($user) {
            // Update user status
            $user->update([
                'is_online' => false,
                'last_seen_at' => now()
            ]);

            // Revoke current token
            $request->user()->currentAccessToken()->delete();
        }

        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Send password reset link
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'If a user with that email address exists, we will send a password reset link.'
            ]);
        }

        // Check if user has admin role
        if (!$user->hasRole('admin')) {
            return response()->json([
                'message' => 'Access denied. Admin privileges required.'
            ], 403);
        }

        // Send password reset link
        $status = Password::sendResetLink($request->only('email'));

        if ($status === Password::RESET_LINK_SENT) {
            return response()->json([
                'message' => 'Password reset link sent to your email address.'
            ]);
        }

        return response()->json([
            'message' => 'Unable to send password reset link.'
        ], 400);
    }

    /**
     * Reset password
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'email' => 'required|email',
            'password' => 'required|string|min:8|confirmed'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Invalid email address.'
            ], 400);
        }

        // Check if user has admin role
        if (!$user->hasRole('admin')) {
            return response()->json([
                'message' => 'Access denied. Admin privileges required.'
            ], 403);
        }

        // Reset password
        $status = Password::reset($request->only('email', 'password', 'password_confirmation', 'token'), function ($user, $password) {
            $user->update([
                'password' => Hash::make($password)
            ]);
        });

        if ($status === Password::PASSWORD_RESET) {
            return response()->json([
                'message' => 'Password reset successfully.'
            ]);
        }

        return response()->json([
            'message' => 'Unable to reset password.'
        ], 400);
    }

    /**
     * Get current admin user
     */
    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'avatar' => $user->avatar,
                'roles' => $user->roles->pluck('name'),
                'permissions' => $user->getAllPermissions()->pluck('name')
            ]
        ]);
    }

    /**
     * Refresh token
     */
    public function refresh(Request $request)
    {
        $user = $request->user();
        
        // Revoke current token
        $request->user()->currentAccessToken()->delete();
        
        // Create new token
        $token = $user->createToken('admin-token', ['admin'])->plainTextToken;

        return response()->json([
            'token' => $token,
            'expires_in' => config('sanctum.expiration') * 60
        ]);
    }
}
