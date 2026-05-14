<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\FirestoreService;
use App\Models\User;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (config('app.env') === 'production') {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }

        // Set Google Application Credentials if not already set or if using a file path
        // This helps the underlying Google Cloud SDK find the credentials
        if ($firebaseConfig = config('firebase.projects.app.credentials')) {
            if (is_string($firebaseConfig) && file_exists($firebaseConfig)) {
                putenv('GOOGLE_APPLICATION_CREDENTIALS=' . realpath($firebaseConfig));
            }
        }

        // Register Firestore User Provider for Authentication
        Auth::provider('firestore', function ($app, array $config) {
            return new \App\Providers\FirestoreUserProvider($app->make(FirestoreService::class));
        });

        // Register custom Token Guard for API (Stateless)
        Auth::viaRequest('firestore-token', function (Request $request) {
            $token = $request->bearerToken();
            if (!$token) return null;

            try {
                $decoded = base64_decode($token);
                if (str_starts_with($decoded, 'user_')) {
                    $parts = explode('_', $decoded);
                    $userId = $parts[1];
                    
                    $firestore = app(FirestoreService::class);
                    $userData = $firestore->getDocument('users', (string)$userId);
                    
                    if ($userData) {
                        $user = new User();
                        $user->forceFill($userData);
                        $user->exists = true;
                        return $user;
                    }
                }
            } catch (\Exception $e) {
                return null;
            }
            return null;
        });
    }
}
