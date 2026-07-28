<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

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
        // Increase memory limit for large queries (development safety net)
        ini_set('memory_limit', '1024M');

        // Only force HTTPS in production when behind a trusted proxy
        if (config('app.env') === 'production' && request()->server('HTTP_X_FORWARDED_PROTO') === 'https') {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }

        // Register custom Firestore User Provider for state management and auth
        \Illuminate\Support\Facades\Auth::provider('firestore', function ($app, array $config) {
            return new \App\Providers\FirestoreUserProvider($app->make(\App\Services\FirestoreService::class));
        });

        // Log Firebase credentials health on startup (for debugging push notifications)
        try {
            $pushService = $this->app->make(\App\Services\PushNotificationService::class);
            $health = $pushService->healthCheck();
            \Log::info('Firebase health check: ' . ($health['configured'] ? 'OK' : 'ISSUE') . ' — ' . $health['message']);
        } catch (\Throwable $e) {
            \Log::warning('Firebase health check failed: ' . $e->getMessage());
        }
    }
}
