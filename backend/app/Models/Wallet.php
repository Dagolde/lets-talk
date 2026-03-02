<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Wallet extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'balance',
        'currency',
        'is_active',
        'is_frozen',
        'frozen_at',
        'frozen_reason',
        'daily_limit',
        'monthly_limit',
        'total_transactions',
        'total_volume',
        'last_transaction_at',
        'settings',
        'metadata',
    ];

    protected $casts = [
        'balance' => 'decimal:2',
        'is_active' => 'boolean',
        'is_frozen' => 'boolean',
        'frozen_at' => 'datetime',
        'daily_limit' => 'decimal:2',
        'monthly_limit' => 'decimal:2',
        'total_volume' => 'decimal:2',
        'last_transaction_at' => 'datetime',
        'settings' => 'array',
        'metadata' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class, 'sender_id', 'user_id');
    }

    public function receivedPayments()
    {
        return $this->hasMany(Payment::class, 'recipient_id', 'user_id');
    }

    public function isFrozen(): bool
    {
        return $this->is_frozen;
    }

    public function freeze($reason = null): void
    {
        $this->update([
            'is_frozen' => true,
            'frozen_at' => now(),
            'frozen_reason' => $reason,
        ]);
    }

    public function unfreeze(): void
    {
        $this->update([
            'is_frozen' => false,
            'frozen_at' => null,
            'frozen_reason' => null,
        ]);
    }

    public function canWithdraw($amount): bool
    {
        if ($this->is_frozen) {
            return false;
        }

        if ($this->balance < $amount) {
            return false;
        }

        if ($this->daily_limit && $this->total_transactions >= $this->daily_limit) {
            return false;
        }

        return true;
    }

    public function withdraw($amount): bool
    {
        if (!$this->canWithdraw($amount)) {
            return false;
        }

        $this->decrement('balance', $amount);
        $this->increment('total_transactions');
        $this->update(['last_transaction_at' => now()]);

        return true;
    }

    public function deposit($amount): void
    {
        $this->increment('balance', $amount);
        $this->increment('total_transactions');
        $this->update(['last_transaction_at' => now()]);
    }
}
