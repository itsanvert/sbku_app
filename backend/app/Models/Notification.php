<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'message',
        'notification_type',
        'is_read',
        'user_id',
    ];


    protected $casts = [
        'is_read' => 'boolean',
        'created' => 'datetime',
    ];

    public function scopeUnread($query)
    {
        return $query->where('is_read', false);
    }

    public function scopeRead($query)
    {
        return $query->where('is_read', true);
    }
    public function markAsRead()
    {
        $this->update(['is_read' => true]);
        return $this;
    }
    public function markAsUnread($userId)
    {
        return self::where('user_id', $userId)
            ->where('is_read', false)
            ->update(['is_read' => false]);
    }

}
