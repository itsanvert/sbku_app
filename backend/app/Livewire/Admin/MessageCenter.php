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

    private $firestore;

    public function boot()
    {
        $this->firestore = app(\App\Services\FirestoreService::class);
    }

    protected $rules = [
        'title' => 'required|string|max:255',
        'body' => 'required|string',
        'type' => 'required|in:announcement,private,alert',
        'receiver_id' => 'nullable',
    ];

    public function sendMessage(PushNotificationService $pushService)
    {
        if (\App\Services\FirestoreService::isActive()) {
            $this->validate([
                'title' => 'required|string|max:255',
                'body' => 'required|string',
                'type' => 'required|in:announcement,private,alert',
                'receiver_id' => 'nullable',
            ]);

            $data = [
                'sender_id' => auth()->id(),
                'receiver_id' => $this->receiver_id ?: null,
                'title' => $this->title,
                'body' => $this->body,
                'type' => $this->type,
                'created_at' => now()->toIso8601String(),
            ];

            $messageId = $this->firestore->create('messages', $data);
        } else {
            $this->validate();
            $message = Message::create([
                'sender_id' => auth()->id(),
                'receiver_id' => $this->receiver_id ?: null,
                'title' => $this->title,
                'body' => $this->body,
                'type' => $this->type,
            ]);
            $messageId = $message->id;
        }

        $pushStatus = '';
        if ($this->send_push) {
            $success = false;
            if ($this->receiver_id) {
                $user = User::find($this->receiver_id);
                if ($user) {
                    $success = $pushService->sendToUser($user, $this->title, $this->body, [
                        'message_id' => (string)$messageId,
                        'type' => $this->type,
                    ]);
                }
            } else {
                $success = $pushService->sendToTopic('all', $this->title, $this->body, [
                    'message_id' => (string)$messageId,
                    'type' => $this->type,
                ]);
            }
            $pushStatus = $success ? ' (Push sent)' : ' (Push failed - check logs)';
        }

        $this->reset(['title', 'body', 'receiver_id']);
        session()->flash('message', 'Message saved successfully!' . $pushStatus);
    }

    public function render()
    {
        if (\App\Services\FirestoreService::isActive()) {
            $messagesData = $this->firestore->list('messages', [], 'created_at', 'desc');
            $collection = collect($messagesData);

            $items = $collection->forPage($this->getPage(), 10)->map(function ($data) {
                $m = new Message();
                $m->forceFill($data);
                $m->exists = true;

                // Mock relationships
                if (isset($data['sender_id'])) {
                    $sender = new User();
                    $sender->forceFill(['id' => $data['sender_id'], 'name' => 'Admin']);
                    $m->setRelation('sender', $sender);
                }

                return $m;
            });

            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $items,
                $collection->count(),
                10,
                $this->getPage(),
                ['path' => \Illuminate\Pagination\Paginator::resolveCurrentPath()]
            );

            $users = collect($this->firestore->list('users'))->map(function($data) {
                $u = new User();
                $u->forceFill($data);
                $u->exists = true;
                return $u;
            })->sortBy('name');

            return view('livewire.admin.message-center', [
                'messages' => $paginated,
                'users' => $users,
            ]);
        }

        return view('livewire.admin.message-center', [
            'messages' => Message::with(['sender', 'receiver'])->latest()->paginate(10),
            'users' => User::orderBy('name')->get(),
        ]);
    }
}
