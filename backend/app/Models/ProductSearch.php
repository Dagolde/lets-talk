<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductSearch extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'query',
        'category',
        'price_min',
        'price_max',
        'location',
        'type',
        'results_count',
        'search_duration',
    ];

    protected $casts = [
        'price_min' => 'decimal:2',
        'price_max' => 'decimal:2',
        'search_duration' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
