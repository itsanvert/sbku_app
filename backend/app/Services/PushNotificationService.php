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

            $message = CloudMessage::new()
                ->withToken($token)
                ->withNotification($notification)
                ->withData($data);

            $messaging->send($message);
            return true;
        } catch (Exception $e) {
            \Log::error('FCM Send Error: ' . $e->getMessage(), [
                'code' => $e->getCode(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);
            return false;
        }
    }

    /**
     * Check if Firebase is properly configured and credentials work.
     *
     * @return array{configured: bool, message: string}
     */
    public function healthCheck(): array
    {
        try {
            $credentials = config('firebase.projects.app.credentials');
            if (!$credentials) {
                return ['configured' => false, 'message' => 'No credentials configured (FIREBASE_CREDENTIALS or FIREBASE_CREDENTIALS_JSON is not set)'];
            }

            if (str_starts_with($credentials, '{')) {
                return ['configured' => true, 'message' => 'Credentials from env var JSON (' . strlen($credentials) . ' chars)'];
            }

            if (file_exists($credentials)) {
                $size = filesize($credentials);
                return ['configured' => true, 'message' => "Credentials from file ($credentials, {$size} bytes)"];
            }

            return ['configured' => false, 'message' => "Credentials file not found: $credentials"];
        } catch (\Exception $e) {
            return ['configured' => false, 'message' => 'Error: ' . $e->getMessage()];
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

            $message = CloudMessage::new()
                ->withTopic($topic)
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
