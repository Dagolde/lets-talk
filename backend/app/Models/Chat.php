<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Chat extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'type',
        'avatar',
        'description',
        'created_by',
        'last_message_at',
        'is_active',
        'settings',
        'metadata',
    ];

    protected $casts = [
        'last_message_at' => 'datetime',
        'is_active' => 'boolean',
        'settings' => 'array',
        'metadata' => 'array',
    ];

    /**
     * Get the participants in this chat.
     */
    public function participants()
    {
        return $this->hasMany(ChatParticipant::class);
    }

    /**
     * Get the users in this chat.
     */
    public function users()
    {
        return $this->belongsToMany(User::class, 'chat_participants')
                    ->withPivot(['role', 'is_muted', 'is_blocked', 'joined_at', 'left_at'])
                    ->withTimestamps();
    }

    /**
     * Get the messages in this chat.
     */
    public function messages()
    {
        return $this->hasMany(Message::class);
    }

    /**
     * Get the creator of this chat.
     */
    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Get the last message in this chat.
     */
    public function lastMessage()
    {
        return $this->hasOne(Message::class)->latest();
    }

    /**
     * Check if this is a direct chat.
     */
    public function isDirect(): bool
    {
        return $this->type === 'direct';
    }

    /**
     * Check if this is a group chat.
     */
    public function isGroup(): bool
    {
        return $this->type === 'group';
    }

    /**
     * Get the avatar URL.
     */
    public function getAvatarUrlAttribute(): string
    {
        if ($this->avatar) {
            return asset('storage/' . $this->avatar);
        }
        return 'https://ui-avatars.com/api/?name=' . urlencode($this->name ?? 'Chat') . '&color=7C3AED&background=EBF4FF';
    }

    /**
     * Get the display name for this chat.
     */
    public function getDisplayNameAttribute(): string
    {
        if ($this->isDirect()) {
            $otherUser = $this->users()->where('users.id', '!=', auth()->id())->first();
            return $otherUser ? $otherUser->name : 'Unknown User';
        }
        return $this->name ?? 'Group Chat';
    }

    /**
     * Get the unread count for a specific user.
     */
    public function getUnreadCountAttribute(): int
    {
        $userId = auth()->id();
        return $this->messages()
                    ->where('sender_id', '!=', $userId)
                    ->whereNull('read_at')
                    ->count();
    }

    /**
     * Scope for direct chats.
     */
    public function scopeDirect($query)
    {
        return $query->where('type', 'direct');
    }

    /**
     * Scope for group chats.
     */
    public function scopeGroup($query)
    {
        return $query->where('type', 'group');
    }

    /**
     * Scope for active chats.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope for chats a user is part of.
     */
    public function scopeForUser($query, $userId)
    {
        return $query->whereHas('participants', function ($q) use ($userId) {
            $q->where('user_id', $userId);
        });
    }
}
