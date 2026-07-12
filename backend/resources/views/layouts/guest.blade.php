<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>

        <link rel="preload" href="{{ asset('img/logo.webp') }}" as="image" type="image/webp">
        <link rel="preload" href="{{ asset('img/logo.jpg') }}" as="image" type="image/jpeg">

        <!-- Styles -->
        @vite(['resources/css/app.css'])

        @livewireStyles
        @fluxAppearance

        <script>
            (function() {
                const stored = localStorage.getItem('theme');
                const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                const isDark = stored === 'dark' || (!stored && prefersDark);
                if (isDark) {
                    document.documentElement.classList.add('dark');
                } else {
                    document.documentElement.classList.remove('dark');
                }
            })();
        </script>
    </head>
    <body class="bg-white dark:bg-[#0f172a]">
        <div class="font-sans text-gray-900 dark:text-gray-50 antialiased">
            {{ $slot }}
        </div>

        @vite(['resources/js/app.js'])
        @livewireScripts
        @fluxScripts
        <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js" defer></script>

    </body>
</html>
