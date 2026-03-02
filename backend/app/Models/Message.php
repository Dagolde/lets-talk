<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Message extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'chat_id',
        'sender_id',
        'content',
        'type',
        'file_path',
        'file_name',
        'file_size',
        'file_type',
        'thumbnail_path',
        'duration',
        'latitude',
        'longitude',
        'location_name',
        'contact_data',
        'payment_data',
        'reply_to_id',
        'is_edited',
        'edited_at',
        'is_deleted',
        'deleted_at',
        'read_at',
        'delivered_at',
        'metadata',
    ];

    protected $casts = [
        'contact_data' => 'array',
        'payment_data' => 'array',
        'metadata' => 'array',
        'is_edited' => 'boolean',
        'is_deleted' => 'boolean',
        'edited_at' => 'datetime',
        'deleted_at' => 'datetime',
        'read_at' => 'datetime',
        'delivered_at' => 'datetime',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    /**
     * Get the chat this message belongs to.
     */
    public function chat()
    {
        return $this->belongsTo(Chat::class);
    }

    /**
     * Get the sender of this message.
     */
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Get the message this is replying to.
     */
    public function replyTo()
    {
        return $this->belongsTo(Message::class, 'reply_to_id');
    }

    /**
     * Get replies to this message.
     */
    public function replies()
    {
        return $this->hasMany(Message::class, 'reply_to_id');
    }

    /**
     * Check if this is a text message.
     */
    public function isText(): bool
    {
        return $this->type === 'text';
    }

    /**
     * Check if this is a media message.
     */
    public function isMedia(): bool
    {
        return in_array($this->type, ['image', 'video', 'audio', 'file']);
    }

    /**
     * Check if this is an image message.
     */
    public function isImage(): bool
    {
        return $this->type === 'image';
    }

    /**
     * Check if this is a video message.
     */
    public function isVideo(): bool
    {
        return $this->type === 'video';
    }

    /**
     * Check if this is an audio message.
     */
    public function isAudio(): bool
    {
        return $this->type === 'audio';
    }

    /**
     * Check if this is a file message.
     */
    public function isFile(): bool
    {
        return $this->type === 'file';
    }

    /**
     * Check if this is a location message.
     */
    public function isLocation(): bool
    {
        return $this->type === 'location';
    }

    /**
     * Check if this is a contact message.
     */
    public function isContact(): bool
    {
        return $this->type === 'contact';
    }

    /**
     * Check if this is a payment message.
     */
    public function isPayment(): bool
    {
        return $this->type === 'payment';
    }

    /**
     * Get the file URL.
     */
    public function getFileUrlAttribute(): ?string
    {
        if ($this->file_path) {
            return asset('storage/' . $this->file_path);
        }
        return null;
    }

    /**
     * Get the thumbnail URL.
     */
    public function getThumbnailUrlAttribute(): ?string
    {
        if ($this->thumbnail_path) {
            return asset('storage/' . $this->thumbnail_path);
        }
        return null;
    }

    /**
     * Get formatted file size.
     */
    public function getFormattedFileSizeAttribute(): ?string
    {
        if (!$this->file_size) {
            return null;
        }

        $units = ['B', 'KB', 'MB', 'GB'];
        $size = $this->file_size;
        $unit = 0;

        while ($size >= 1024 && $unit < count($units) - 1) {
            $size /= 1024;
            $unit++;
        }

        return round($size, 2) . ' ' . $units[$unit];
    }

    /**
     * Get formatted duration.
     */
    public function getFormattedDurationAttribute(): ?string
    {
        if (!$this->duration) {
            return null;
        }

        $minutes = floor($this->duration / 60);
        $seconds = $this->duration % 60;

        return sprintf('%02d:%02d', $minutes, $seconds);
    }

    /**
     * Check if message has been read.
     */
    public function isRead(): bool
    {
        return !is_null($this->read_at);
    }

    /**
     * Check if message has been delivered.
     */
    public function isDelivered(): bool
    {
        return !is_null($this->delivered_at);
    }

    /**
     * Mark message as read.
     */
    public function markAsRead(): void
    {
        $this->update(['read_at' => now()]);
    }

    /**
     * Mark message as delivered.
     */
    public function markAsDelivered(): void
    {
        $this->update(['delivered_at' => now()]);
    }

    /**
     * Scope for unread messages.
     */
    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    /**
     * Scope for read messages.
     */
    public function scopeRead($query)
    {
        return $query->whereNotNull('read_at');
    }

    /**
     * Scope for messages of specific type.
     */
    public function scopeOfType($query, $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Scope for media messages.
     */
    public function scopeMedia($query)
    {
        return $query->whereIn('type', ['image', 'video', 'audio', 'file']);
    }
}
