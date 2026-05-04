<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SyncsToFirestore;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    use SyncsToFirestore;

    protected $fillable = [
        'sender_id',
        'receiver_id',
        'title',
        'body',
        'type',
        'metadata',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    /**
     * Get the user who sent the message.
     */
    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Get the user who received the message.
     */
    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    /**
     * Customize the Firestore data.
     */
    public function toFirestoreArray()
    {
        $data = $this->toArray();
        $data['sender_name'] = $this->sender?->name ?? 'System';
        return $data;
    }
}
