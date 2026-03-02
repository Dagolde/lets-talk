<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdminSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'key',
        'value',
        'type',
        'group',
        'description',
        'is_public',
    ];

    protected $casts = [
        'is_public' => 'boolean',
    ];

    /**
     * Get setting value with type casting.
     */
    public function getTypedValueAttribute()
    {
        switch ($this->type) {
            case 'boolean':
                return filter_var($this->value, FILTER_VALIDATE_BOOLEAN);
            case 'integer':
                return (int) $this->value;
            case 'json':
                return json_decode($this->value, true);
            default:
                return $this->value;
        }
    }

    /**
     * Set setting value with type validation.
     */
    public function setTypedValue($value)
    {
        switch ($this->type) {
            case 'boolean':
                $this->value = $value ? 'true' : 'false';
                break;
            case 'integer':
                $this->value = (string) (int) $value;
                break;
            case 'json':
                $this->value = json_encode($value);
                break;
            default:
                $this->value = (string) $value;
        }
    }

    /**
     * Scope for public settings.
     */
    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    /**
     * Scope for settings by group.
     */
    public function scopeByGroup($query, $group)
    {
        return $query->where('group', $group);
    }

    /**
     * Get setting by key.
     */
    public static function getValue($key, $default = null)
    {
        $setting = static::where('key', $key)->first();
        return $setting ? $setting->typed_value : $default;
    }

    /**
     * Set setting value.
     */
    public static function setValue($key, $value, $type = 'string', $group = 'general', $description = null)
    {
        $setting = static::firstOrNew(['key' => $key]);
        $setting->type = $type;
        $setting->group = $group;
        $setting->description = $description;
        $setting->setTypedValue($value);
        $setting->save();
        
        return $setting;
    }
}
