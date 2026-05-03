<?php

namespace App\Livewire\Admin;

use App\Models\Message;
use App\Models\User;
use App\Services\PushNotificationService;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('layouts.app')]
class MessageCenter extends Component
{
    use WithPagination;

    public $title = '';
    public $body = '';
    public $type = 'announcement';
    public $receiver_id = '';
    public $send_push = true;

    protected $rules = [
        'title' => 'required|string|max:255',
        'body' => 'required|string',
        'type' => 'required|in:announcement,private,alert',
        'receiver_id' => 'nullable|exists:users,id',
    ];

    public function sendMessage(PushNotificationService $pushService)
    {
        $this->validate();

        $message = Message::create([
            'sender_id' => auth()->id(),
            'receiver_id' => $this->receiver_id ?: null,
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type,
        ]);

        if ($this->send_push) {
            if ($this->receiver_id) {
                $user = User::find($this->receiver_id);
                if ($user) {
                    $pushService->sendToUser($user, $this->title, $this->body, [
                        'message_id' => (string)$message->id,
                        'type' => $this->type,
                    ]);
                }
            } else {
                // Broadcast to a topic (e.g. 'all')
                $pushService->sendToTopic('all', $this->title, $this->body, [
                    'message_id' => (string)$message->id,
                    'type' => $this->type,
                ]);
            }
        }

        $this->reset(['title', 'body', 'receiver_id']);
        session()->flash('message', 'Message sent successfully!');
    }

    public function render()
    {
        return view('livewire.admin.message-center', [
            'messages' => Message::with(['sender', 'receiver'])->latest()->paginate(10),
            'users' => User::orderBy('name')->get(),
        ]);
    }
}
