<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes, HasRoles;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'bio',
        'avatar',
        'email_verified_at',
        'phone_verified_at',
        'is_online',
        'last_seen_at',
        'preferences',
        'settings',
        'language',
        'timezone',
        'currency',
        'two_factor_enabled',
        'two_factor_method',
        'two_factor_secret',
        'backup_codes',
        'is_blocked',
        'is_suspended',
        'suspended_until',
        'suspension_reason',
        'verification_token',
        'password_reset_token',
        'phone_verification_code',
        'phone_verification_expires_at',
        'status',
        'read_receipts',
        'typing_indicators',
        'profile_photo_visible',
        'last_seen_visible',
        'about_visible',
        'groups_visible',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'verification_token',
        'password_reset_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'phone_verified_at' => 'datetime',
        'last_seen_at' => 'datetime',
        'suspended_until' => 'datetime',
        'phone_verification_expires_at' => 'datetime',
        'preferences' => 'array',
        'settings' => 'array',
        'backup_codes' => 'array',
        'is_online' => 'boolean',
        'two_factor_enabled' => 'boolean',
        'is_blocked' => 'boolean',
        'is_suspended' => 'boolean',
        'read_receipts' => 'boolean',
        'typing_indicators' => 'boolean',
        'profile_photo_visible' => 'boolean',
        'last_seen_visible' => 'boolean',
        'about_visible' => 'boolean',
        'groups_visible' => 'boolean',
    ];

    /**
     * Get the user's wallet.
     */
    public function wallet()
    {
        return $this->hasOne(Wallet::class);
    }

    /**
     * Get payments sent by the user.
     */
    public function sentPayments()
    {
        return $this->hasMany(Payment::class, 'sender_id');
    }

    /**
     * Get payments received by the user.
     */
    public function receivedPayments()
    {
        return $this->hasMany(Payment::class, 'recipient_id');
    }

    /**
     * Get QR codes created by the user.
     */
    public function qrCodes()
    {
        return $this->hasMany(QRCode::class);
    }

    /**
     * Get QR code scans by the user.
     */
    public function qrScans()
    {
        return $this->hasMany(QRCodeScan::class);
    }

    /**
     * Get contacts of the user.
     */
    public function contacts()
    {
        return $this->hasMany(Contact::class);
    }

    /**
     * Get notifications for the user.
     */
    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * Get product searches by the user.
     */
    public function productSearches()
    {
        return $this->hasMany(ProductSearch::class);
    }

    /**
     * Get messages sent by the user.
     */
    public function sentMessages()
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    /**
     * Get chat participants for the user.
     */
    public function chatParticipants()
    {
        return $this->hasMany(ChatParticipant::class);
    }

    /**
     * Get chats the user is part of.
     */
    public function chats()
    {
        return $this->belongsToMany(Chat::class, 'chat_participants')
                    ->withPivot(['role', 'is_muted', 'is_blocked', 'joined_at', 'left_at'])
                    ->withTimestamps();
    }

    /**
     * Get groups created by the user.
     */
    public function groups()
    {
        return $this->hasMany(Chat::class, 'created_by')->where('type', 'group');
    }

    /**
     * Get users blocked by this user.
     */
    public function blockedUsers()
    {
        return $this->belongsToMany(User::class, 'user_blocks', 'blocker_id', 'blocked_id')
                    ->withTimestamps();
    }

    /**
     * Get users who blocked this user.
     */
    public function blockedBy()
    {
        return $this->belongsToMany(User::class, 'user_blocks', 'blocked_id', 'blocker_id')
                    ->withTimestamps();
    }

    /**
     * Get favorite contacts of the user.
     */
    public function favoriteContacts()
    {
        return $this->belongsToMany(User::class, 'favorite_contacts', 'user_id', 'contact_id')
                    ->withTimestamps();
    }

    /**
     * Get files uploaded by the user.
     */
    public function files()
    {
        return $this->hasMany(File::class);
    }

    /**
     * Get user sessions.
     */
    public function sessions()
    {
        return $this->hasMany(UserSession::class);
    }

    /**
     * Get active sessions.
     */
    public function activeSessions()
    {
        return $this->sessions()->where('is_active', true);
    }

    /**
     * Check if user is online.
     */
    public function isOnline(): bool
    {
        return $this->is_online && $this->last_seen_at && $this->last_seen_at->diffInMinutes(now()) < 5;
    }

    /**
     * Check if user is verified.
     */
    public function isVerified(): bool
    {
        return !is_null($this->email_verified_at);
    }

    /**
     * Check if user is blocked.
     */
    public function isBlocked(): bool
    {
        return $this->is_blocked;
    }

    /**
     * Check if user is suspended.
     */
    public function isSuspended(): bool
    {
        return $this->is_suspended && ($this->suspended_until === null || $this->suspended_until->isFuture());
    }

    /**
     * Check if phone is verified.
     */
    public function isPhoneVerified(): bool
    {
        return !is_null($this->phone_verified_at);
    }

    /**
     * Check if two-factor authentication is enabled.
     */
    public function hasTwoFactorEnabled(): bool
    {
        return $this->two_factor_enabled;
    }

    /**
     * Generate backup codes for two-factor authentication.
     */
    public function generateBackupCodes(): array
    {
        $codes = [];
        for ($i = 0; $i < 8; $i++) {
            $codes[] = strtoupper(substr(md5(uniqid()), 0, 8));
        }
        
        $this->update(['backup_codes' => $codes]);
        return $codes;
    }

    /**
     * Verify backup code.
     */
    public function verifyBackupCode(string $code): bool
    {
        $backupCodes = $this->backup_codes ?? [];
        $index = array_search($code, $backupCodes);
        
        if ($index !== false) {
            unset($backupCodes[$index]);
            $this->update(['backup_codes' => array_values($backupCodes)]);
            return true;
        }
        
        return false;
    }

    /**
     * Generate phone verification code.
     */
    public function generatePhoneVerificationCode(): string
    {
        $code = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $this->update([
            'phone_verification_code' => $code,
            'phone_verification_expires_at' => now()->addMinutes(10)
        ]);
        return $code;
    }

    /**
     * Verify phone code.
     */
    public function verifyPhoneCode(string $code): bool
    {
        if ($this->phone_verification_code === $code && 
            $this->phone_verification_expires_at && 
            $this->phone_verification_expires_at->isFuture()) {
            
            $this->update([
                'phone_verified_at' => now(),
                'phone_verification_code' => null,
                'phone_verification_expires_at' => null
            ]);
            return true;
        }
        
        return false;
    }

    /**
     * Get user's full name.
     */
    public function getFullNameAttribute(): string
    {
        return $this->name;
    }

    /**
     * Get user's avatar URL.
     */
    public function getAvatarUrlAttribute(): string
    {
        if ($this->avatar) {
            return asset('storage/' . $this->avatar);
        }
        return 'https://ui-avatars.com/api/?name=' . urlencode($this->name) . '&color=7C3AED&background=EBF4FF';
    }

    /**
     * Get user's status text.
     */
    public function getStatusTextAttribute(): string
    {
        if ($this->isOnline()) {
            return 'Online';
        }
        if ($this->last_seen_at) {
            return 'Last seen ' . $this->last_seen_at->diffForHumans();
        }
        return 'Offline';
    }

    /**
     * Scope for online users.
     */
    public function scopeOnline($query)
    {
        return $query->where('is_online', true)
                     ->where('last_seen_at', '>=', now()->subMinutes(5));
    }

    /**
     * Scope for verified users.
     */
    public function scopeVerified($query)
    {
        return $query->whereNotNull('email_verified_at');
    }

    /**
     * Scope for blocked users.
     */
    public function scopeBlocked($query)
    {
        return $query->where('is_blocked', true);
    }

    /**
     * Scope for active users.
     */
    public function scopeActive($query)
    {
        return $query->where('is_blocked', false);
    }
}
