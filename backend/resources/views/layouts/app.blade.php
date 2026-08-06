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

        <!-- Styles -->
        @livewireStyles
        @fluxAppearance

        <script>
            (function() {
                const stored = localStorage.getItem('theme');
                const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                // stored is null = system, 'dark' = dark, 'light' = light
                const isDark = stored === 'dark' || (!stored && prefersDark);
                if (isDark) {
                    document.documentElement.classList.add('dark');
                } else {
                    document.documentElement.classList.remove('dark');
                }
            })();
        </script>

        <style>
            /* Native Flux appearance — no custom overrides */
        </style>
    </head>
    <body class="min-h-screen bg-gray-50 dark:bg-zinc-900 antialiased font-sans text-zinc-900 dark:text-zinc-100 flex flex-col">
        <div class="flex flex-1 flex-col lg:flex-row">
            <flux:sidebar stashable sticky class="lg:bg-gray-50 lg:dark:bg-zinc-900 border-r border-gray-200 dark:border-white/10">
                <flux:sidebar.toggle class="lg:hidden" icon="x-mark" />

                <flux:brand href="{{ route('dashboard') }}" logo="/img/logo.webp" name="SBKU" class="px-2" />

                <flux:navlist variant="pill" class="mt-4 space-y-4">
                    <flux:navlist.group heading="General">
                        <flux:navlist.item icon="home" href="{{ route('dashboard') }}" :current="request()->routeIs('dashboard')">Dashboard</flux:navlist.item>
                    </flux:navlist.group>

                    @if(auth()->user()->isAdmin() || auth()->user()->isSuperAdmin())
                        <flux:navlist.group heading="Academic">
                            @if(auth()->user()->isSuperAdmin())
                                <flux:navlist.item icon="user" href="{{ route('users.index') }}" :current="request()->routeIs('users.index')">User</flux:navlist.item>
                            @endif

                            <flux:navlist.item icon="academic-cap" href="{{ route('teachers.index') }}" :current="request()->routeIs('teachers.index')">Teacher</flux:navlist.item>
                            <flux:navlist.item icon="users" href="{{ route('students.index') }}" :current="request()->routeIs('students.index')">Student</flux:navlist.item>
                            <flux:navlist.item icon="book-open" href="{{ route('syllabuses.index') }}" :current="request()->routeIs('syllabuses.index')">Syllabus</flux:navlist.item>
                            <flux:navlist.item icon="bookmark" href="{{ route('subjects.index') }}" :current="request()->routeIs('subjects.index')">Subject</flux:navlist.item>
                            <flux:navlist.item icon="building-library" href="{{ route('faculties.index') }}" :current="request()->routeIs('faculties.index')">Faculty</flux:navlist.item>
                            <flux:navlist.item icon="academic-cap" href="{{ route('majors.index') }}" :current="request()->routeIs('majors.index')">Major</flux:navlist.item>
                            <flux:navlist.item icon="user-group" href="{{ route('classes.index') }}" :current="request()->routeIs('classes.index')">Class</flux:navlist.item>
                            <flux:navlist.item icon="building-office" href="{{ route('rooms.index') }}" :current="request()->routeIs('rooms.index')">Room</flux:navlist.item>
                        </flux:navlist.group>

                        <flux:navlist.group heading="Operations">
                            <flux:navlist.item icon="clock" href="{{ route('schedules.index') }}" :current="request()->routeIs('schedules.index')">Schedule</flux:navlist.item>
                            <flux:navlist.item icon="arrow-path" href="{{ route('shifts.index') }}" :current="request()->routeIs('shifts.index')">Shift</flux:navlist.item>
                        </flux:navlist.group>

                        <flux:navlist.group heading="Communication">
                            <flux:navlist.item icon="chat-bubble-left-right" href="{{ route('messages') }}" :current="request()->routeIs('messages')">Messages</flux:navlist.item>
                        </flux:navlist.group>
                    @endif

                    @if(auth()->user()->isAdmin() || auth()->user()->role === 'teacher' || auth()->user()->role === 'student')
                        <flux:navlist.group heading="Attendance">
                            @if(auth()->user()->isAdmin() || auth()->user()->role === 'teacher')
                                <flux:navlist.item icon="calendar-days" href="{{ route('attendance.sessions.index') }}" :current="request()->routeIs('attendance.sessions.*')">Sessions</flux:navlist.item>
                            @endif

                            <flux:navlist.item icon="clipboard-document-check" href="{{ route('attendance.records.index') }}" :current="request()->routeIs('attendance.records.*')">Records</flux:navlist.item>
                        </flux:navlist.group>
                    @endif
                </flux:navlist>

                <flux:spacer />

                <flux:navlist variant="pill" class="mb-2 space-y-1">
                    <flux:navlist.item
                        x-data="themeToggle"
                        x-on:click="cycleTheme()"
                        icon="sun"
                        icon-variant="outline"
                    >
                        <span x-text="theme === 'dark' ? 'Dark mode' : theme === 'light' ? 'Light mode' : 'System theme'">Theme</span>
                    </flux:navlist.item>
                    <flux:navlist.item icon="cog-6-tooth" href="{{ route('profile.show') }}" :current="request()->routeIs('profile.show')">Settings</flux:navlist.item>
                </flux:navlist>

                <flux:dropdown class="mb-5" position="top">
                    <flux:profile name="{{ auth()->user()->name }}" avatar="{{ auth()->user()->profile_photo_url }}" />

                    <flux:menu>
                         <!-- Account Management -->
                        <div class="block px-4 py-2 text-xs text-gray-400 dark:text-gray-500">
                            {{ __('Manage Account') }}
                        </div>

                        <flux:menu.item icon="user" href="{{ route('profile.show') }}">
                            {{ __('Profile') }}
                        </flux:menu.item>

                        @if (Laravel\Jetstream\Jetstream::hasApiFeatures())
                            <flux:menu.item icon="key" href="{{ route('api-tokens.index') }}">
                                {{ __('API Tokens') }}
                            </flux:menu.item>
                        @endif

                        <div class="border-t border-gray-200 dark:border-white/10"></div>


                        <div class="border-t border-gray-200 dark:border-white/10"></div>

                        <flux:menu.item icon="arrow-right-start-on-rectangle" href="{{ route('logout') }}" onclick="event.preventDefault(); document.getElementById('logout-form').submit();" variant="danger">
                            Log out
                        </flux:menu.item>
                    </flux:menu>
                </flux:dropdown>

                <!-- Hidden Forms for Actions -->
                <form id="logout-form" action="{{ route('logout') }}" method="POST" class="hidden">
                    @csrf
                </form>

            </flux:sidebar>

            <div class="flex-1 flex flex-col min-w-0">
                <flux:header class="border-b border-gray-200 dark:border-white/10 lg:hidden">
                    <flux:sidebar.toggle icon="bars-3" inset="left" />
                    <flux:spacer />
                    <flux:dropdown>
                        <flux:profile avatar="{{ auth()->user()->profile_photo_url }}" />
                        <flux:menu>
                            <flux:menu.item icon="arrow-right-start-on-rectangle" href="{{ route('logout') }}" onclick="event.preventDefault(); document.getElementById('logout-form').submit();" variant="danger">Log out</flux:menu.item>
                        </flux:menu>
                    </flux:dropdown>
                </flux:header>

                <flux:main class="relative">
                    @if (isset($header))
                        <div class="mb-8">
                            {{ $header }}
                        </div>
                    @endif

                    {{ $slot }}
                </flux:main>
            </div>
        </div>

        @stack('modals')

        @vite(['resources/js/app.js'])
        @livewireScripts
        @fluxScripts

        {{-- Global Theme Toggle Alpine Component --}}
        <script>
            document.addEventListener('alpine:init', () => {
                window.themeToggle = function() {
                    return {
                        theme: 'system',
                        init() {
                            const stored = localStorage.getItem('theme');
                            this.theme = stored || 'system';
                            this.applyTheme();
                            // Listen for OS preference changes
                            window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
                                if (this.theme === 'system') this.applyTheme();
                            });
                        },
                        setTheme(value) {
                            this.theme = value;
                            if (value === 'system') {
                                localStorage.removeItem('theme');
                            } else {
                                localStorage.setItem('theme', value);
                            }
                            this.applyTheme();
                        },
                        cycleTheme() {
                            const order = ['system', 'dark', 'light'];
                            const next = order[(order.indexOf(this.theme) + 1) % order.length];
                            this.setTheme(next);
                        },
                        applyTheme() {
                            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                            const isDark = this.theme === 'dark' || (this.theme === 'system' && prefersDark);
                            document.documentElement.classList.toggle('dark', isDark);
                        }
                    }
                }
            });
        </script>

        @stack('scripts')
    </body>
</html>
