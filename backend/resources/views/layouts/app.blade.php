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
            /* ================================================================
               FLUX DARK MODE OVERRIDES — Three-Surface-Level Premium Palette
               ================================================================ */

            /* -- Sidebar background: surface level 0 -- */
            html.dark .flux-sidebar,
            html.dark [data-flux-sidebar],
            html.dark ui-sidebar {
                background-color: #0f172a !important;
                border-color: rgba(255, 255, 255, 0.08) !important;
            }

            /* -- Navlist item base: muted text -- */
            html.dark .flux-sidebar [data-flux-navlist-item],
            html.dark ui-sidebar [data-flux-navlist-item] {
                color: #94a3b8 !important;
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1) !important;
            }

            /* -- Navlist item hover -- */
            html.dark .flux-sidebar [data-flux-navlist-item]:hover,
            html.dark ui-sidebar [data-flux-navlist-item]:hover {
                background-color: rgba(30, 41, 59, 0.8) !important;
                color: #f1f5f9 !important;
                transform: translateX(3px);
            }

            /* -- Navlist item ACTIVE -- */
            html.dark .flux-sidebar [data-flux-navlist-item][data-current],
            html.dark ui-sidebar [data-flux-navlist-item][data-current] {
                background: linear-gradient(135deg, rgba(37, 99, 235, 0.2), rgba(59, 130, 246, 0.1)) !important;
                color: #ffffff !important;
                border-color: transparent !important;
                box-shadow: 0 0 12px rgba(37, 99, 235, 0.15), inset 0 0 0 1px rgba(59, 130, 246, 0.2) !important;
                font-weight: 600 !important;
            }

            html.dark .flux-sidebar [data-flux-navlist-item][data-current] svg,
            html.dark ui-sidebar [data-flux-navlist-item][data-current] svg {
                color: #3b82f6 !important;
            }

            html.dark .flux-sidebar [data-flux-navlist-item][data-current]:hover,
            html.dark ui-sidebar [data-flux-navlist-item][data-current]:hover {
                background: linear-gradient(135deg, rgba(37, 99, 235, 0.3), rgba(59, 130, 246, 0.15)) !important;
            }

            html.dark .flux-sidebar [data-flux-navlist-item][data-current] [data-content],
            html.dark ui-sidebar [data-flux-navlist-item][data-current] [data-content] {
                color: #ffffff !important;
            }

            /* -- Profile -- */
            html.dark .flux-sidebar [data-flux-profile] {
                color: #cbd5e1 !important;
            }

            /* -- Brand -- */
            html.dark .flux-sidebar [data-flux-brand] {
                color: #f8fafc !important;
            }

            /* -- Dropdown / Menu: surface level 1 -- */
            html.dark .flux-dropdown__menu,
            html.dark .flux-menu {
                background-color: #1e293b !important;
                border: 1px solid rgba(255, 255, 255, 0.08) !important;
                box-shadow: 0 16px 48px rgba(0, 0, 0, 0.45) !important;
                backdrop-filter: blur(14px) !important;
            }

            html.dark .flux-dropdown__menu a,
            html.dark .flux-menu a,
            html.dark .flux-dropdown__menu button,
            html.dark .flux-menu button {
                color: #cbd5e1 !important;
            }

            html.dark .flux-dropdown__menu a:hover,
            html.dark .flux-menu a:hover,
            html.dark .flux-dropdown__menu button:hover,
            html.dark .flux-menu button:hover {
                background-color: rgba(59, 130, 246, 0.1) !important;
                color: #3b82f6 !important;
            }

            /* -- Header: glass -- */
            html.dark .flux-header {
                background-color: rgba(15, 23, 42, 0.8) !important;
                backdrop-filter: blur(14px) !important;
                border-color: rgba(255, 255, 255, 0.08) !important;
            }

            /* -- Main content -- */
            html.dark .flux-main {
                background-color: #0f172a !important;
            }

            /* -- Primary button -- */
            html.dark .flux-button--primary,
            html.dark [data-flux-button-variant="primary"] {
                background-color: #3b82f6 !important;
            }

            html.dark .flux-button--primary:hover,
            html.dark [data-flux-button-variant="primary"]:hover {
                background-color: #2563eb !important;
            }

            /* -- Inputs -- */
            html.dark input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]),
            html.dark textarea,
            html.dark select {
                background-color: #1e293b !important;
                border-color: rgba(255, 255, 255, 0.08) !important;
                color: #f8fafc !important;
            }

            html.dark input::placeholder,
            html.dark textarea::placeholder {
                color: #475569 !important;
            }

            html.dark input:focus,
            html.dark textarea:focus,
            html.dark select:focus {
                border-color: #3b82f6 !important;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15) !important;
                outline: none !important;
            }

            /* -- Modals -- */
            html.dark [data-flux-dialog],
            html.dark .flux-dialog {
                background-color: #1e293b !important;
                border-color: rgba(255, 255, 255, 0.08) !important;
                box-shadow: 0 24px 64px rgba(0, 0, 0, 0.5) !important;
            }
        </style>
    </head>
    <body class="min-h-screen bg-white dark:bg-[#0f172a] antialiased font-sans text-gray-900 dark:text-[#f8fafc] flex flex-col">
        <div class="flex flex-1 flex-col lg:flex-row">
            <flux:sidebar stashable sticky class="lg:bg-gray-50 lg:dark:bg-[#0f172a] border-r border-gray-200 dark:border-[rgba(255,255,255,0.08)]">
                <flux:sidebar.toggle class="lg:hidden" icon="x-mark" />

                <flux:brand href="{{ route('dashboard') }}" logo="/img/logo.webp" name="SBKU" class="px-2" />

                <flux:navlist variant="pill" class="mt-6">
                    <flux:navlist.item icon="home" href="{{ route('dashboard') }}" :current="request()->routeIs('dashboard')">Dashboard</flux:navlist.item>

                    @if(auth()->user()->isSuperAdmin())
                        <flux:navlist.item icon="user" href="{{ route('users.index') }}" :current="request()->routeIs('users.index')">User</flux:navlist.item>
                    @endif

                    @if(auth()->user()->isAdmin())
                        <flux:navlist.item icon="academic-cap" href="{{ route('teachers.index') }}" :current="request()->routeIs('teachers.index')">Teacher</flux:navlist.item>
                    @endif

                    @if(auth()->user()->isAdmin())
                        <flux:navlist.item icon="users" href="{{ route('students.index') }}" :current="request()->routeIs('students.index')">Student</flux:navlist.item>
                    @endif

                    @if(auth()->user()->isAdmin())
                        <flux:navlist.item icon="book-open" href="{{ route('syllabuses.index') }}" :current="request()->routeIs('syllabuses.index')">Syllabus</flux:navlist.item>
                    @endif

                    @if(auth()->user()->isAdmin())
                        <flux:navlist.item icon="bookmark" href="{{ route('subjects.index') }}" :current="request()->routeIs('subjects.index')">Subject</flux:navlist.item>
                    @endif

                    @if(auth()->user()->isAdmin())
                        <flux:navlist.item icon="building-library" href="{{ route('faculties.index') }}" :current="request()->routeIs('faculties.index')">Faculty</flux:navlist.item>
                        <flux:navlist.item icon="academic-cap" href="{{ route('majors.index') }}" :current="request()->routeIs('majors.index')">Major</flux:navlist.item>
                        <flux:navlist.item icon="user-group" href="{{ route('classes.index') }}" :current="request()->routeIs('classes.index')">Class</flux:navlist.item>
                        <flux:navlist.item icon="building-office" href="{{ route('rooms.index') }}" :current="request()->routeIs('rooms.index')">Room</flux:navlist.item>
                        <flux:navlist.item icon="clock" href="{{ route('schedules.index') }}" :current="request()->routeIs('schedules.index')">Schedule</flux:navlist.item>
                        <flux:navlist.item icon="arrow-path" href="{{ route('shifts.index') }}" :current="request()->routeIs('shifts.index')">Shift</flux:navlist.item>
                        <flux:navlist.item icon="chat-bubble-left-right" href="{{ route('messages') }}" :current="request()->routeIs('messages')">Messages</flux:navlist.item>
                    @endif

                    @guest
                    @else
                        @if(auth()->user()->isAdmin() || auth()->user()->role === 'teacher')
                            <flux:navlist.item icon="calendar-days" href="{{ route('attendance.sessions.index') }}" :current="request()->routeIs('attendance.sessions.*')">Sessions</flux:navlist.item>
                        @endif

                        @if(auth()->user()->isAdmin() || auth()->user()->role === 'teacher' || auth()->user()->role === 'student')
                            <flux:navlist.item icon="clipboard-document-check" href="{{ route('attendance.records.index') }}" :current="request()->routeIs('attendance.records.*')">Records</flux:navlist.item>
                        @endif
                    @endguest
                </flux:navlist>

                <flux:spacer />

                <flux:navlist variant="pill" class="mb-2">
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

                        <div class="border-t border-gray-200 dark:border-[rgba(255,255,255,0.08)]"></div>

                        {{-- Dark Mode Quick Toggle --}}
                        <div x-data="themeToggle()" x-init="init()">
                            <button @click="cycleTheme()" class="flex items-center gap-2 w-full px-4 py-2 text-sm text-gray-700 dark:text-[#cbd5e1] hover:bg-gray-50 dark:hover:bg-[rgba(59,130,246,0.1)] hover:text-gray-900 dark:hover:text-[#3b82f6] transition-colors">
                                <template x-if="theme === 'dark'">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4"><path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" /></svg>
                                </template>
                                <template x-if="theme === 'light'">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4"><path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" /></svg>
                                </template>
                                <template x-if="theme === 'system'">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4"><path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 7.41A2.25 2.25 0 012.25 5.495V5.25" /></svg>
                                </template>
                                <span x-text="theme === 'dark' ? 'Dark Mode' : (theme === 'light' ? 'Light Mode' : 'System')"></span>
                            </button>
                        </div>

                        <div class="border-t border-gray-200 dark:border-[rgba(255,255,255,0.08)]"></div>

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
                <flux:header class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] lg:hidden">
                    <flux:sidebar.toggle icon="bars-3" inset="left" />
                    <flux:spacer />
                    <flux:dropdown>
                        <flux:profile avatar="{{ auth()->user()->profile_photo_url }}" />
                        <flux:menu>
                            <flux:menu.item icon="arrow-right-start-on-rectangle" href="{{ route('logout') }}" onclick="event.preventDefault(); document.getElementById('logout-form').submit();" variant="danger">Log out</flux:menu.item>
                        </flux:menu>
                    </flux:dropdown>
                </flux:header>

                <flux:main>
                    @if (isset($header))
                        {{ $header }}
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
