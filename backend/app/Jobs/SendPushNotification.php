<?php

namespace App\Jobs;

use App\Models\Student;
use App\Services\PushNotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendPushNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        private readonly array $studentIds,
        private readonly string $title,
        private readonly string $body,
        private readonly array $data,
    ) {}

    public function handle(PushNotificationService $pushService): void
    {
        $students = Student::with('user')
            ->whereIn('id', $this->studentIds)
            ->whereNotNull('user_id')
            ->get();

        foreach ($students as $student) {
            if ($student->user && $student->user->fcm_token) {
                $pushService->sendToUser($student->user, $this->title, $this->body, $this->data);
            }
        }
    }
}
