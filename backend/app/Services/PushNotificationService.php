<?php

namespace App\Services;

use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Laravel\Firebase\Facades\Firebase;
use App\Models\User;
use Exception;

class PushNotificationService
{
    /**
     * Send a notification to a specific user.
     *
     * @param User $user
     * @param string $title
     * @param string $body
     * @param array $data
     * @return bool
     */
    public function sendToUser(User $user, $title, $body, array $data = [])
    {
        if (!$user->fcm_token) {
            return false;
        }

        return $this->sendToToken($user->fcm_token, $title, $body, $data);
    }

    /**
     * Send a notification to a specific FCM token.
     *
     * @param string $token
     * @param string $title
     * @param string $body
     * @param array $data
     * @return bool
     */
    public function sendToToken($token, $title, $body, array $data = [])
    {
        try {
            $messaging = \Kreait\Laravel\Firebase\Facades\Firebase::messaging();

            $notification = Notification::create($title, $body);

            $message = CloudMessage::withTarget('token', $token)
                ->withNotification($notification)
                ->withData($data);

            $messaging->send($message);
            return true;
        } catch (Exception $e) {
            \Log::error('FCM Send Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send a notification to a specific topic.
     *
     * @param string $topic
     * @param string $title
     * @param string $body
     * @param array $data
     * @return bool
     */
    public function sendToTopic($topic, $title, $body, array $data = [])
    {
        try {
            $messaging = \Kreait\Laravel\Firebase\Facades\Firebase::messaging();

            $notification = Notification::create($title, $body);

            $message = CloudMessage::withTarget('topic', $topic)
                ->withNotification($notification)
                ->withData($data);

            $messaging->send($message);
            return true;
        } catch (Exception $e) {
            \Log::error('FCM Topic Send Error: ' . $e->getMessage());
            return false;
        }
    }
}
