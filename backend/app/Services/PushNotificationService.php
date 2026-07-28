<?php

namespace App\Services;

use App\Models\User;
use Exception;

class PushNotificationService
{
    private ?array $_credentials = null;
    private ?string $_accessToken = null;
    private int $_tokenExpiresAt = 0;

    /**
     * Check if Firebase credentials are configured.
     */
    public function isConfigured(): bool
    {
        return $this->healthCheck()['configured'];
    }

    /**
     * Send a notification to a specific user.
     */
    public function sendToUser(User $user, $title, $body, array $data = []): bool
    {
        if (!$user->fcm_token) {
            return false;
        }
        return $this->sendToToken($user->fcm_token, $title, $body, $data);
    }

    /**
     * Send a notification to a specific FCM token via direct HTTP v1 API.
     */
    public function sendToToken($token, $title, $body, array $data = []): bool
    {
        try {
            $projectId = $this->getProjectId();
            if (!$projectId) {
                \Log::error('FCM Send failed: could not determine project ID');
                return false;
            }

            $accessToken = $this->getAccessToken();
            if (!$accessToken) {
                return false;
            }

            $message = [
                'message' => [
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => array_merge(['type' => $data['type'] ?? 'general'], $data),
                ],
            ];

            return $this->sendFcmRequest($projectId, $accessToken, $message);
        } catch (Exception $e) {
            \Log::error('FCM Send Error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);
            error_log('FCM Send Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send a notification to a topic via direct HTTP v1 API.
     */
    public function sendToTopic($topic, $title, $body, array $data = []): bool
    {
        try {
            $projectId = $this->getProjectId();
            if (!$projectId) {
                \Log::error('FCM Topic Send failed: could not determine project ID');
                return false;
            }

            $accessToken = $this->getAccessToken();
            if (!$accessToken) {
                return false;
            }

            $message = [
                'message' => [
                    'topic' => $topic,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => array_merge(['type' => $data['type'] ?? 'general'], $data),
                ],
            ];

            return $this->sendFcmRequest($projectId, $accessToken, $message);
        } catch (Exception $e) {
            \Log::error('FCM Topic Send Error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);
            error_log('FCM Topic Send Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send the FCM HTTP v1 request.
     */
    private function sendFcmRequest(string $projectId, string $accessToken, array $payload): bool
    {
        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json; UTF-8',
            ],
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 10,
            CURLOPT_CONNECTTIMEOUT => 5,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($response === false) {
            \Log::error('FCM HTTP request failed: ' . $error);
            return false;
        }

        if ($httpCode >= 200 && $httpCode < 300) {
            \Log::info('FCM send success: ' . $response);
            return true;
        }

        \Log::error('FCM HTTP error [' . $httpCode . ']: ' . $response);
        error_log('FCM HTTP error [' . $httpCode . ']: ' . $response);
        return false;
    }

    /**
     * Get the project ID from the credentials JSON.
     */
    private function getProjectId(): ?string
    {
        $creds = $this->loadCredentials();
        return $creds['project_id'] ?? null;
    }

    /**
     * Load and parse the service account credentials.
     */
    private function loadCredentials(): ?array
    {
        if ($this->_credentials !== null) {
            return $this->_credentials;
        }

        $raw = config('firebase.projects.app.credentials');
        if (!$raw) {
            return null;
        }

        // If it's already a JSON string, decode it
        if (is_string($raw) && str_starts_with(trim($raw), '{')) {
            $this->_credentials = json_decode($raw, true);
            return $this->_credentials;
        }

        // If it's a file path, read and decode it
        if (is_string($raw) && file_exists($raw)) {
            $content = file_get_contents($raw);
            $this->_credentials = json_decode($content, true);
            return $this->_credentials;
        }

        return null;
    }

    /**
     * Get an OAuth2 access token for the Firebase service account
     * by creating and exchanging a JWT assertion.
     */
    private function getAccessToken(): ?string
    {
        if ($this->_accessToken && time() < $this->_tokenExpiresAt - 60) {
            return $this->_accessToken;
        }

        $creds = $this->loadCredentials();
        if (!$creds || empty($creds['client_email']) || empty($creds['private_key'])) {
            \Log::error('FCM: invalid service account credentials (missing client_email or private_key)');
            return null;
        }

        $now = time();
        $jwtHeader = self::base64UrlEncode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $jwtPayload = self::base64UrlEncode(json_encode([
            'iss' => $creds['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'exp' => $now + 3600,
            'iat' => $now,
        ]));

        $signature = '';
        openssl_sign(
            "{$jwtHeader}.{$jwtPayload}",
            $signature,
            $creds['private_key'],
            OPENSSL_ALGO_SHA256
        );
        $jwt = "{$jwtHeader}.{$jwtPayload}." . self::base64UrlEncode($signature);

        // Exchange JWT for access token
        $ch = curl_init('https://oauth2.googleapis.com/token');
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]),
            CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 10,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200 || $response === false) {
            \Log::error('FCM OAuth token exchange failed [' . $httpCode . ']: ' . ($response ?: 'no response'));
            return null;
        }

        $data = json_decode($response, true);
        if (!$data || empty($data['access_token'])) {
            \Log::error('FCM OAuth response missing access_token: ' . $response);
            return null;
        }

        $this->_accessToken = $data['access_token'];
        $this->_tokenExpiresAt = $now + ($data['expires_in'] ?? 3600);

        return $this->_accessToken;
    }

    /**
     * Check if Firebase credentials are properly configured.
     */
    public function healthCheck(): array
    {
        $raw = config('firebase.projects.app.credentials');

        if (!$raw) {
            return ['configured' => false, 'message' => 'No credentials configured'];
        }

        try {
            $creds = $this->loadCredentials();
            if (!$creds) {
                return ['configured' => false, 'message' => 'Could not parse credentials'];
            }

            $hasEmail = !empty($creds['client_email']);
            $hasKey = !empty($creds['private_key']);
            $hasProject = !empty($creds['project_id']);

            if ($hasEmail && $hasKey && $hasProject) {
                return [
                    'configured' => true,
                    'message' => "Service account: {$creds['client_email']}, project: {$creds['project_id']}",
                ];
            }

            $missing = [];
            if (!$hasEmail) $missing[] = 'client_email';
            if (!$hasKey) $missing[] = 'private_key';
            if (!$hasProject) $missing[] = 'project_id';
            return ['configured' => false, 'message' => 'Missing fields: ' . implode(', ', $missing)];
        } catch (\Exception $e) {
            return ['configured' => false, 'message' => 'Error: ' . $e->getMessage()];
        }
    }

    private static function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}