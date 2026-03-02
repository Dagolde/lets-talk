<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QRCode extends Model
{
    use HasFactory;

    protected $table = 'qr_codes';

    protected $fillable = [
        'user_id',
        'type',
        'title',
        'description',
        'data',
        'image_path',
        'is_active',
        'is_public',
        'expires_at',
        'max_scans',
        'current_scans',
        'settings',
        'metadata',
    ];

    protected $casts = [
        'data' => 'array',
        'is_active' => 'boolean',
        'is_public' => 'boolean',
        'expires_at' => 'datetime',
        'settings' => 'array',
        'metadata' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeNotExpired($query)
    {
        return $query->where(function ($q) {
            $q->whereNull('expires_at')
              ->orWhere('expires_at', '>', now());
        });
    }

    public function isExpired(): bool
    {
        return $this->expires_at && $this->expires_at->isPast();
    }

    public function canBeScanned(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        if ($this->isExpired()) {
            return false;
        }

        if ($this->max_scans && $this->current_scans >= $this->max_scans) {
            return false;
        }

        return true;
    }

    public function incrementScans(): void
    {
        $this->increment('current_scans');
    }

    public function getImageUrlAttribute(): ?string
    {
        if (!$this->image_path) {
            return null;
        }

        return asset('storage/' . $this->image_path);
    }

    public function getQrDataAttribute(): array
    {
        $baseData = [
            'id' => $this->id,
            'type' => $this->type,
            'title' => $this->title,
        ];

        return array_merge($baseData, $this->data ?? []);
    }
}
