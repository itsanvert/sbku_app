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
        \Illuminate\Support\Facades\Auth::provider('firestore', function ($app, array $config) {
            return new \App\Providers\FirestoreUserProvider($app->make(\App\Services\FirestoreService::class));
        });
    }
}
