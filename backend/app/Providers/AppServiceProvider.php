<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\FirestoreService;
use App\Providers\FirestoreUserProvider;
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
        if ($firebaseConfig = config('firebase.projects.app.credentials')) {
            $path = $firebaseConfig;
            if (!str_starts_with($path, '/') && !str_contains($path, ':')) {
                $path = base_path($path);
            }
            
            if (file_exists($path)) {
                putenv('GOOGLE_APPLICATION_CREDENTIALS=' . $path);
            }
        }

        // Register Firestore User Provider for Authentication
        Auth::provider('firestore', function ($app, array $config) {
            return new FirestoreUserProvider($app->make(FirestoreService::class));
        });

        // Register custom Firestore Token Guard
        Auth::extend('firestore-token', function ($app, $name, array $config) {
            return new \Illuminate\Auth\RequestGuard(function ($request) use ($app, $config) {
                $token = $request->bearerToken();
                if (!$token) return null;

                try {
                    $decoded = base64_decode($token);
                    if (!$decoded) return null;

                    // format: user_<id>_<timestamp>
                    $parts = explode('_', $decoded);
                    if (count($parts) < 2 || $parts[0] !== 'user') return null;

                    $userId = $parts[1];
                    $provider = Auth::createUserProvider($config['provider']);
                    return $provider->retrieveById($userId);
                } catch (\Exception $e) {
                    return null;
                }
            }, $app['request']);
        });

        // Global Gate bypass for super_admin
        \Illuminate\Support\Facades\Gate::before(function ($user, $ability) {
            return $user->role === 'super_admin' ? true : null;
        });
    }
}
