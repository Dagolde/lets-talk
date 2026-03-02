<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'device_name',
        'device_type',
        'platform',
        'browser',
        'ip_address',
        'location',
        'session_id',
        'last_activity',
        'is_active',
        'metadata',
    ];

    protected $casts = [
        'last_activity' => 'datetime',
        'is_active' => 'boolean',
        'metadata' => 'array',
    ];

    /**
     * Get the user this session belongs to.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if session is active.
     */
    public function isActive(): bool
    {
        return $this->is_active && $this->last_activity && $this->last_activity->diffInMinutes(now()) < 30;
    }

    /**
     * Update last activity.
     */
    public function updateActivity(): void
    {
        $this->update(['last_activity' => now()]);
    }

    /**
     * Get formatted device name.
     */
    public function getFormattedDeviceNameAttribute(): string
    {
        $parts = [];
        
        if ($this->device_name) {
            $parts[] = $this->device_name;
        }
        
        if ($this->platform) {
            $parts[] = ucfirst($this->platform);
        }
        
        if ($this->browser) {
            $parts[] = $this->browser;
        }
        
        return implode(' - ', $parts) ?: 'Unknown Device';
    }

    /**
     * Scope for active sessions.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope for sessions by platform.
     */
    public function scopeByPlatform($query, $platform)
    {
        return $query->where('platform', $platform);
    }

    /**
     * Scope for sessions by device type.
     */
    public function scopeByDeviceType($query, $deviceType)
    {
        return $query->where('device_type', $deviceType);
    }
}
