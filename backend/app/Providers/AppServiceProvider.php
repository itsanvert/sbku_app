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
        // Only force HTTPS in production when behind a trusted proxy
        if (config('app.env') === 'production' && request()->server('HTTP_X_FORWARDED_PROTO') === 'https') {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }

        // Register custom Firestore User Provider for state management and auth
        \Illuminate\Support\Facades\Auth::provider('firestore', function ($app, array $config) {
            return new \App\Providers\FirestoreUserProvider($app->make(\App\Services\FirestoreService::class));
        });
    }
}
