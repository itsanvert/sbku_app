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
        try {
            $students = Student::with('user')
                ->whereIn('id', $this->studentIds)
                ->whereNotNull('user_id')
                ->get();

            $sentCount = 0;
            $skippedCount = 0;

            foreach ($students as $student) {
                if ($student->user && $student->user->fcm_token) {
                    $result = $pushService->sendToUser($student->user, $this->title, $this->body, $this->data);
                    if ($result) {
                        $sentCount++;
                    } else {
                        \Log::warning('PushNotification: failed to send to user #' . $student->user_id . ' (no FCM token or send error)');
                    }
                } else {
                    $skippedCount++;
                }
            }

            \Log::info("PushNotification: sent to {$sentCount} users, skipped {$skippedCount} (no FCM token)");
        } catch (\Throwable $e) {
            \Log::error('PushNotification job failed: ' . $e->getMessage(), [
                'student_count' => count($this->studentIds),
                'trace' => $e->getTraceAsString(),
            ]);
        }
    }
}
