<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\ChatController;
use App\Http\Controllers\API\MessageController;
use App\Http\Controllers\API\PaymentController;
use App\Http\Controllers\API\WalletController;
use App\Http\Controllers\API\QRCodeController;
use App\Http\Controllers\API\ContactController;
use App\Http\Controllers\API\ProductSearchController;
use App\Http\Controllers\API\NotificationController;
use App\Http\Controllers\API\FileController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::post('/send-phone-verification', [AuthController::class, 'sendPhoneVerification']);
Route::post('/verify-phone-and-register', [AuthController::class, 'verifyPhoneAndRegister']);
Route::post('/send-login-code', [AuthController::class, 'sendLoginCode']);
Route::post('/verify-login-code', [AuthController::class, 'verifyLoginCode']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
Route::post('/verify-email', [AuthController::class, 'verifyEmail']);
Route::post('/resend-verification', [AuthController::class, 'resendVerification']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // User management
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user', [AuthController::class, 'updateProfile']);
    Route::post('/user/avatar', [AuthController::class, 'updateAvatar']);
    Route::post('/user/change-password', [AuthController::class, 'changePassword']);
    Route::get('/users', [AuthController::class, 'getUsers']);
    
    // Two-step verification
    Route::post('/user/enable-two-factor', [AuthController::class, 'enableTwoFactor']);
    Route::post('/user/disable-two-factor', [AuthController::class, 'disableTwoFactor']);
    Route::post('/user/send-two-step-code', [AuthController::class, 'sendTwoStepCode']);
    Route::post('/user/verify-two-factor', [AuthController::class, 'verifyTwoFactor']);
    
    // Sessions management
    Route::get('/user/sessions', [AuthController::class, 'getSessions']);
    Route::post('/user/terminate-session', [AuthController::class, 'terminateSession']);
    Route::post('/user/terminate-all-other-sessions', [AuthController::class, 'terminateAllOtherSessions']);
    
    // Chat routes
    Route::get('/chats', [ChatController::class, 'index']);
    Route::post('/chats', [ChatController::class, 'store']);
    Route::get('/chats/{chat}', [ChatController::class, 'show']);
    Route::put('/chats/{chat}', [ChatController::class, 'update']);
    Route::delete('/chats/{chat}', [ChatController::class, 'destroy']);
    Route::post('/chats/{chat}/participants', [ChatController::class, 'addParticipant']);
    Route::delete('/chats/{chat}/participants/{user}', [ChatController::class, 'removeParticipant']);
    Route::post('/chats/{chat}/leave', [ChatController::class, 'leave']);
    
    // Message routes
    Route::get('/chats/{chat}/messages', [MessageController::class, 'index']);
    Route::post('/chats/{chat}/messages', [MessageController::class, 'store']);
    Route::get('/messages/{message}', [MessageController::class, 'show']);
    Route::put('/messages/{message}', [MessageController::class, 'update']);
    Route::delete('/messages/{message}', [MessageController::class, 'destroy']);
    Route::post('/messages/{message}/read', [MessageController::class, 'markAsRead']);
    Route::post('/messages/{message}/deliver', [MessageController::class, 'markAsDelivered']);
    
    // Payment routes
    Route::get('/payments', [PaymentController::class, 'index']);
    Route::post('/payments', [PaymentController::class, 'store']);
    Route::get('/payments/{payment}', [PaymentController::class, 'show']);
    Route::post('/payments/{payment}/confirm', [PaymentController::class, 'confirm']);
    Route::post('/payments/{payment}/cancel', [PaymentController::class, 'cancel']);
    Route::post('/payments/{payment}/refund', [PaymentController::class, 'refund']);
    
    // Payment gateway initialization
    Route::post('/payments/stripe/initialize', [PaymentController::class, 'initializeStripe']);
    Route::post('/payments/paystack/initialize', [PaymentController::class, 'initializePaystack']);
    Route::post('/payments/flutterwave/initialize', [PaymentController::class, 'initializeFlutterwave']);
    
    // Wallet routes
    Route::get('/wallet', [WalletController::class, 'show']);
    Route::post('/wallet/add-money', [WalletController::class, 'addMoney']);
    Route::post('/wallet/withdraw', [WalletController::class, 'withdraw']);
    Route::get('/wallet/transactions', [WalletController::class, 'transactions']);
    
    // QR Code routes
    Route::get('/qr-codes', [QRCodeController::class, 'index']);
    Route::post('/qr-codes', [QRCodeController::class, 'store']);
    Route::get('/qr-codes/{qrCode}', [QRCodeController::class, 'show']);
    Route::put('/qr-codes/{qrCode}', [QRCodeController::class, 'update']);
    Route::delete('/qr-codes/{qrCode}', [QRCodeController::class, 'destroy']);
    Route::post('/qr-codes/scan', [QRCodeController::class, 'scan']);
    Route::post('/qr-codes/{qrCode}/activate', [QRCodeController::class, 'activate']);
    Route::post('/qr-codes/{qrCode}/deactivate', [QRCodeController::class, 'deactivate']);
    
    // Contact routes
    Route::get('/contacts', [ContactController::class, 'index']);
    Route::post('/contacts', [ContactController::class, 'store']);
    Route::get('/contacts/{contact}', [ContactController::class, 'show']);
    Route::put('/contacts/{contact}', [ContactController::class, 'update']);
    Route::delete('/contacts/{contact}', [ContactController::class, 'destroy']);
    Route::post('/contacts/{contact}/favorite', [ContactController::class, 'toggleFavorite']);
    Route::post('/contacts/sync', [ContactController::class, 'syncContacts']);
    Route::post('/contacts/find-users', [ContactController::class, 'findLetsTalkUsers']);
    
    // Product search routes
    Route::get('/product-search', [ProductSearchController::class, 'search']);
    Route::post('/product-search/upload', [ProductSearchController::class, 'uploadImage']);
    Route::get('/product-search/history', [ProductSearchController::class, 'history']);
    Route::get('/product-search/suggestions', [ProductSearchController::class, 'suggestions']);
    
    // Notification routes
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/{notification}', [NotificationController::class, 'show']);
    Route::post('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::delete('/notifications/{notification}', [NotificationController::class, 'destroy']);
    
    // File upload routes
    Route::post('/files/upload', [FileController::class, 'upload']);
    Route::get('/files/{file}', [FileController::class, 'show']);
    Route::delete('/files/{file}', [FileController::class, 'destroy']);
});

// Webhook routes (no authentication required)
Route::post('/webhooks/stripe', [PaymentController::class, 'stripeWebhook']);
Route::post('/webhooks/paystack', [PaymentController::class, 'paystackWebhook']);
Route::post('/webhooks/flutterwave', [PaymentController::class, 'flutterwaveWebhook']);

// Public QR code access
Route::get('/qr-codes/{qrCode}/public', [QRCodeController::class, 'publicShow']);

// Admin authentication routes (public)
Route::prefix('admin')->group(function () {
    Route::post('/login', [App\Http\Controllers\Admin\AdminAuthController::class, 'login']);
    Route::post('/forgot-password', [App\Http\Controllers\Admin\AdminAuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [App\Http\Controllers\Admin\AdminAuthController::class, 'resetPassword']);
});

// Admin routes (protected by admin middleware)
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [App\Http\Controllers\Admin\AdminController::class, 'dashboard']);
    Route::get('/users', [App\Http\Controllers\Admin\AdminController::class, 'getUsers']);
    Route::post('/users', [App\Http\Controllers\Admin\AdminController::class, 'createUser']);
    Route::get('/users/{id}', [App\Http\Controllers\Admin\AdminController::class, 'getUser']);
    Route::post('/users/{id}/status', [App\Http\Controllers\Admin\AdminController::class, 'updateUserStatus']);
    Route::delete('/users/{id}', [App\Http\Controllers\Admin\AdminController::class, 'deleteUser']);
    Route::get('/settings', [App\Http\Controllers\Admin\AdminController::class, 'getSettings']);
    Route::post('/settings', [App\Http\Controllers\Admin\AdminController::class, 'updateSettings']);
    Route::get('/analytics', [App\Http\Controllers\Admin\AdminController::class, 'getAnalytics']);
    Route::get('/system-health', [App\Http\Controllers\Admin\AdminController::class, 'getSystemHealth']);
    Route::post('/initialize-settings', [App\Http\Controllers\Admin\AdminController::class, 'initializeSettings']);
    Route::post('/logout', [App\Http\Controllers\Admin\AdminAuthController::class, 'logout']);
    
    // Conversation management routes
    Route::get('/conversations/stats', [App\Http\Controllers\Admin\ConversationController::class, 'getStats']);
    Route::get('/conversations', [App\Http\Controllers\Admin\ConversationController::class, 'getConversations']);
    Route::get('/conversations/{id}', [App\Http\Controllers\Admin\ConversationController::class, 'getConversation']);
    Route::delete('/conversations/{id}', [App\Http\Controllers\Admin\ConversationController::class, 'deleteConversation']);
    Route::get('/contacts', [App\Http\Controllers\Admin\ConversationController::class, 'getContacts']);
    Route::get('/contacts/user/{userId}', [App\Http\Controllers\Admin\ConversationController::class, 'getUserContacts']);
    Route::get('/conversations/analytics', [App\Http\Controllers\Admin\ConversationController::class, 'getAnalytics']);
    Route::get('/conversations/dashboard-stats', [App\Http\Controllers\Admin\ConversationController::class, 'getDashboardStats']);
});
