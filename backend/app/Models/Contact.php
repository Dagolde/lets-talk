<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Contact extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'phone',
        'email',
        'avatar',
        'is_favorite',
        'notes',
    ];

    protected $casts = [
        'is_favorite' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeFavorite($query)
    {
        return $query->where('is_favorite', true);
    }

    public function toggleFavorite()
    {
        $this->update(['is_favorite' => !$this->is_favorite]);
        return $this;
    }
}
