<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /**
     * WhatsApp-style registration - Step 1: Send phone verification code
     */
    public function sendPhoneVerification(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|max:20',
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check if user already exists
        $existingUser = User::where('phone', $request->phone)->first();
        
        if ($existingUser) {
            // User exists, send login code instead
            $loginRequest = new Request();
            $loginRequest->merge(['phone' => $request->phone]);
            $loginResponse = $this->sendLoginCode($loginRequest);
            
            // Modify the response to indicate this is for an existing user
            if ($loginResponse->getStatusCode() === 200) {
                $data = json_decode($loginResponse->getContent(), true);
                $data['is_existing_user'] = true;
                return response()->json($data, 200);
            }
            
            return $loginResponse;
        }

        // Check if admin has disabled new registrations
        $registrationEnabled = \App\Models\AdminSetting::where('key', 'registration_enabled')->value('value') ?? 'true';
        if ($registrationEnabled === 'false') {
            return response()->json([
                'success' => false,
                'message' => 'New user registration is currently disabled'
            ], 403);
        }

        // Generate verification code (use predictable code for testing)
        if ($request->phone === '09034057885') {
            $code = '123456'; // Test code for development
        } else {
            $code = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        }
        
        // Store in cache for 10 minutes
        \Cache::put("phone_verification_{$request->phone}", [
            'code' => $code,
            'name' => $request->name,
            'expires_at' => now()->addMinutes(10)
        ], 600);

        // Send SMS (implement SMS service)
        // $this->sendSMS($request->phone, "Your Let's Talk verification code is: {$code}");

        return response()->json([
            'success' => true,
            'message' => 'Verification code sent to your phone',
            'data' => [
                'phone' => $request->phone,
                'expires_in' => 600 // 10 minutes
            ]
        ]);
    }

    /**
     * WhatsApp-style registration - Step 2: Verify phone and create account
     */
    public function verifyPhoneAndRegister(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|max:20',
            'name' => 'required|string|max:255',
            'otp' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Get stored verification data
        $verificationData = \Cache::get("phone_verification_{$request->phone}");
        
        if (!$verificationData || $verificationData['code'] !== $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired verification code'
            ], 400);
        }

        // Check if phone is still available
        if (User::where('phone', $request->phone)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Phone number is already registered'
            ], 400);
        }

        // Create user with generated password
        $user = User::create([
            'name' => $verificationData['name'],
            'phone' => $request->phone,
            'password' => Hash::make(Str::random(12)), // Generate random password
            'phone_verified_at' => now(),
            'email' => $request->phone . '@lets-talk.local', // Temporary email
        ]);

        // Create wallet for the user
        $user->wallet()->create([
            'balance' => 0,
            'currency' => 'USD',
        ]);

        // Clear verification cache
        \Cache::forget("phone_verification_{$request->phone}");

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Account created successfully',
            'data' => [
                'user' => $user->load('wallet'),
                'token' => $token,
            ]
        ], 201);
    }

    /**
     * WhatsApp-style login - Step 1: Send login verification code
     */
    public function sendLoginCode(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('phone', $request->phone)->first();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Phone number not found'
            ], 404);
        }

        if ($user->isBlocked() || $user->isSuspended()) {
            return response()->json([
                'success' => false,
                'message' => 'Account is blocked or suspended'
            ], 403);
        }

        // Generate login code (use predictable code for testing)
        if ($request->phone === '09034057885') {
            $code = '123456'; // Test code for development
            $user->update([
                'phone_verification_code' => $code,
                'phone_verification_expires_at' => now()->addMinutes(10)
            ]);
        } else {
            $code = $user->generatePhoneVerificationCode();
        }

        // Send SMS (implement SMS service)
        // $this->sendSMS($request->phone, "Your Let's Talk login code is: {$code}");

        return response()->json([
            'success' => true,
            'message' => 'Login code sent to your phone',
            'data' => [
                'phone' => $request->phone,
                'expires_in' => 600 // 10 minutes
            ]
        ]);
    }

    /**
     * WhatsApp-style login - Step 2: Verify code and login
     */
    public function verifyLoginCode(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|max:20',
            'code' => 'required|string|size:6',
            'device_name' => 'nullable|string|max:255',
            'device_type' => 'nullable|string|in:mobile,desktop,tablet',
            'platform' => 'nullable|string|in:ios,android,web,desktop',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('phone', $request->phone)->first();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Phone number not found'
            ], 404);
        }

        if (!$user->verifyPhoneCode($request->code)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired verification code'
            ], 400);
        }

        // Update online status
        $user->update([
            'is_online' => true,
            'last_seen_at' => now(),
        ]);

        // Create session record
        $session = $user->sessions()->create([
            'device_name' => $request->device_name ?? 'Unknown Device',
            'device_type' => $request->device_type ?? 'mobile',
            'platform' => $request->platform ?? 'android',
            'session_id' => Str::random(32),
            'last_activity' => now(),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user->load('wallet'),
                'token' => $token,
                'session' => $session,
            ]
        ]);
    }

    /**
     * Login user.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
            'device_token' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials'
            ], 401);
        }

        $user = User::where('email', $request->email)->first();
        
        // Update online status and last seen
        $user->update([
            'is_online' => true,
            'last_seen_at' => now(),
        ]);

        // Update device token if provided
        if ($request->device_token) {
            $user->update(['device_token' => $request->device_token]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user->load('wallet'),
                'token' => $token,
            ]
        ]);
    }

    /**
     * Logout user.
     */
    public function logout(Request $request)
    {
        $user = $request->user();
        
        // Update online status
        $user->update([
            'is_online' => false,
            'last_seen_at' => now(),
        ]);

        // Revoke all tokens
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Get authenticated user.
     */
    public function user(Request $request)
    {
        $user = $request->user()->load('wallet');
        
        return response()->json([
            'success' => true,
            'data' => $user
        ]);
    }

    /**
     * Get all users (for payment recipient selection)
     */
    public function getUsers(Request $request)
    {
        $users = User::where('is_active', true)
            ->where('is_suspended', false)
            ->where('is_blocked', false)
            ->select(['id', 'name', 'email', 'phone', 'avatar', 'bio', 'is_online', 'last_seen_at', 'created_at', 'updated_at'])
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }

    /**
     * Update user profile.
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:20|unique:users,phone,' . $user->id,
            'bio' => 'sometimes|string|max:500',
            'language' => 'sometimes|string|max:10',
            'timezone' => 'sometimes|string|max:50',
            'currency' => 'sometimes|string|max:3',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user->update($request->only([
            'name', 'phone', 'bio', 'language', 'timezone', 'currency'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $user->load('wallet')
        ]);
    }

    /**
     * Update user avatar.
     */
    public function updateAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        
        if ($request->hasFile('avatar')) {
            $path = $request->file('avatar')->store('avatars', 'public');
            $user->update(['avatar' => $path]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Avatar updated successfully',
            'data' => [
                'avatar_url' => $user->avatar_url
            ]
        ]);
    }

    /**
     * Change password.
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'password' => ['required', 'confirmed', Password::defaults()],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect'
            ], 400);
        }

        $user->update([
            'password' => Hash::make($request->password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully'
        ]);
    }

    /**
     * Forgot password.
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();
        $user->update([
            'password_reset_token' => Str::random(64)
        ]);

        // Send password reset email (implement email service)
        // Mail::to($user->email)->send(new ResetPassword($user));

        return response()->json([
            'success' => true,
            'message' => 'Password reset link sent to your email'
        ]);
    }

    /**
     * Reset password.
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'password' => ['required', 'confirmed', Password::defaults()],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('password_reset_token', $request->token)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid reset token'
            ], 400);
        }

        $user->update([
            'password' => Hash::make($request->password),
            'password_reset_token' => null
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password reset successfully'
        ]);
    }

    /**
     * Verify email.
     */
    public function verifyEmail(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('verification_token', $request->token)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid verification token'
            ], 400);
        }

        $user->update([
            'email_verified_at' => now(),
            'verification_token' => null
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Email verified successfully'
        ]);
    }

    /**
     * Resend verification email.
     */
    public function resendVerification(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if ($user->email_verified_at) {
            return response()->json([
                'success' => false,
                'message' => 'Email is already verified'
            ], 400);
        }

        $user->update([
            'verification_token' => Str::random(64)
        ]);

        // Send verification email (implement email service)
        // Mail::to($user->email)->send(new VerifyEmail($user));

        return response()->json([
            'success' => true,
            'message' => 'Verification email sent'
        ]);
    }

    /**
     * Enable two-step verification.
     */
    public function enableTwoFactor(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'method' => 'required|string|in:sms,email,authenticator',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        if ($user->hasTwoFactorEnabled()) {
            return response()->json([
                'success' => false,
                'message' => 'Two-step verification is already enabled'
            ], 400);
        }

        $user->update([
            'two_factor_enabled' => true,
            'two_factor_method' => $request->method,
        ]);

        // Generate backup codes
        $backupCodes = $user->generateBackupCodes();

        return response()->json([
            'success' => true,
            'message' => 'Two-step verification enabled',
            'data' => [
                'method' => $request->method,
                'backup_codes' => $backupCodes,
            ]
        ]);
    }

    /**
     * Disable two-step verification.
     */
    public function disableTwoFactor(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid password'
            ], 400);
        }

        $user->update([
            'two_factor_enabled' => false,
            'two_factor_method' => null,
            'two_factor_secret' => null,
            'backup_codes' => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Two-step verification disabled'
        ]);
    }

    /**
     * Verify two-step verification code.
     */
    public function verifyTwoFactor(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'code' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        if (!$user->hasTwoFactorEnabled()) {
            return response()->json([
                'success' => false,
                'message' => 'Two-step verification is not enabled'
            ], 400);
        }

        // Check if it's a backup code
        if ($user->verifyBackupCode($request->code)) {
            return response()->json([
                'success' => true,
                'message' => 'Backup code verified successfully'
            ]);
        }

        // Check if it's a phone/email code
        if ($user->two_factor_method === 'sms' && $user->verifyPhoneCode($request->code)) {
            return response()->json([
                'success' => true,
                'message' => 'Two-step verification code verified'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Invalid verification code'
        ], 400);
    }

    /**
     * Get user sessions.
     */
    public function getSessions(Request $request)
    {
        $user = $request->user();
        $sessions = $user->activeSessions()->orderBy('last_activity', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $sessions
        ]);
    }

    /**
     * Terminate a session.
     */
    public function terminateSession(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'session_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $session = $user->sessions()->where('session_id', $request->session_id)->first();
        
        if (!$session) {
            return response()->json([
                'success' => false,
                'message' => 'Session not found'
            ], 404);
        }

        $session->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'Session terminated successfully'
        ]);
    }

    /**
     * Terminate all other sessions.
     */
    public function terminateAllOtherSessions(Request $request)
    {
        $user = $request->user();
        $currentToken = $request->bearerToken();
        
        // Terminate all other sessions
        $user->sessions()->where('is_active', true)->update(['is_active' => false]);
        
        // Revoke all other tokens except current
        $user->tokens()->where('id', '!=', $currentToken)->delete();

        return response()->json([
            'success' => true,
            'message' => 'All other sessions terminated successfully'
        ]);
    }

    /**
     * Send two-step verification code.
     */
    public function sendTwoStepCode(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'method' => 'required|string|in:sms,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        if (!$user->hasTwoFactorEnabled()) {
            return response()->json([
                'success' => false,
                'message' => 'Two-step verification is not enabled'
            ], 400);
        }

        // Generate verification code
        $code = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        
        // Store in cache for 10 minutes
        $cacheKey = "two_factor_{$user->id}_{$request->method}";
        \Cache::put($cacheKey, $code, 600);

        // Send code via SMS or email
        if ($request->method === 'sms' && $user->phone) {
            // Send SMS (implement SMS service)
            // $this->sendSMS($user->phone, "Your Let's Talk verification code is: {$code}");
        } elseif ($request->method === 'email' && $user->email) {
            // Send email (implement email service)
            // Mail::to($user->email)->send(new TwoFactorCodeMail($code));
        }

        return response()->json([
            'success' => true,
            'message' => "Verification code sent to your {$request->method}",
            'data' => [
                'method' => $request->method,
                'expires_in' => 600 // 10 minutes
            ]
        ]);
    }
}
