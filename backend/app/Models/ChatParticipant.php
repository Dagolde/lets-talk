<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatParticipant extends Model
{
    use HasFactory;

    protected $fillable = [
        'chat_id',
        'user_id',
        'role',
        'is_muted',
        'is_blocked',
        'joined_at',
        'left_at',
        'settings',
    ];

    protected $casts = [
        'joined_at' => 'datetime',
        'left_at' => 'datetime',
        'is_muted' => 'boolean',
        'is_blocked' => 'boolean',
        'settings' => 'array',
    ];

    /**
     * Get the chat this participant belongs to.
     */
    public function chat()
    {
        return $this->belongsTo(Chat::class);
    }

    /**
     * Get the user who is a participant.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if participant is an admin.
     */
    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    /**
     * Check if participant is a moderator.
     */
    public function isModerator(): bool
    {
        return $this->role === 'moderator';
    }

    /**
     * Check if participant is active (hasn't left).
     */
    public function isActive(): bool
    {
        return is_null($this->left_at);
    }
}
