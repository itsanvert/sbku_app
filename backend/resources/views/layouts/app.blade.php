<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=inter:400,500,600&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])

        <!-- Styles -->
        @livewireStyles
        @fluxAppearance
    </head>
    <body class="min-h-screen bg-white dark:bg-zinc-900 antialiased font-sans text-zinc-900 dark:text-zinc-100 flex flex-col">
        <div class="flex flex-1 flex-col lg:flex-row">
            <flux:sidebar stashable sticky class="lg:bg-zinc-50 lg:dark:bg-zinc-900 border-r border-zinc-200 dark:border-zinc-800">
                <flux:sidebar.toggle class="lg:hidden" icon="x-mark" />

                <flux:brand href="{{ route('dashboard') }}" logo="/img/logo.jpg" name="SBKU" class="px-2" />

                <flux:navlist variant="pill" class="mt-6">
                    <flux:navlist.item icon="home" href="{{ route('dashboard') }}" :current="request()->routeIs('dashboard')">Dashboard</flux:navlist.item>

                    @if(auth()->user()->role === 'admin' || auth()->user()->hasTeamPermission(auth()->user()->currentTeam, 'manage-users'))
                        <flux:navlist.item icon="user" href="{{ route('users.index') }}" :current="request()->routeIs('users.index')">User</flux:navlist.item>
                    @endif

                    @if(auth()->user()->role === 'admin' || auth()->user()->hasTeamPermission(auth()->user()->currentTeam, 'manage-teachers'))
                        <flux:navlist.item icon="academic-cap" href="{{ route('teachers.index') }}" :current="request()->routeIs('teachers.index')">Teacher</flux:navlist.item>
                    @endif

                    @if(auth()->user()->role === 'admin' || auth()->user()->hasTeamPermission(auth()->user()->currentTeam, 'manage-students'))
                        <flux:navlist.item icon="users" href="{{ route('students.index') }}" :current="request()->routeIs('students.index')">Student</flux:navlist.item>
                    @endif

                    @if(auth()->user()->role === 'admin' || auth()->user()->hasTeamPermission(auth()->user()->currentTeam, 'manage-syllabus'))
                        <flux:navlist.item icon="book-open" href="{{ route('syllabuses.index') }}" :current="request()->routeIs('syllabuses.index')">Syllabus</flux:navlist.item>
                    @endif

                    @if(auth()->user()->role === 'admin' || auth()->user()->hasTeamPermission(auth()->user()->currentTeam, 'manage-subjects'))
                        <flux:navlist.item icon="bookmark" href="{{ route('subjects.index') }}" :current="request()->routeIs('subjects.index')">Subject</flux:navlist.item>
                    @endif

                    @guest
                    @else
                        @if(auth()->user()->role === 'admin' || auth()->user()->role === 'teacher' || auth()->user()->hasTeamPermission(auth()->user()->currentTeam, 'view-sessions'))
                            <flux:navlist.item icon="calendar-days" href="{{ route('attendance.sessions.index') }}" :current="request()->routeIs('attendance.sessions.*')">Sessions</flux:navlist.item>
                        @endif

                        @if(auth()->user()->role === 'admin' || auth()->user()->role === 'teacher' || auth()->user()->role === 'student' || auth()->user()->hasTeamPermission(auth()->user()->currentTeam, 'view-attendance'))
                            <flux:navlist.item icon="clipboard-document-check" href="{{ route('attendance.records.index') }}" :current="request()->routeIs('attendance.records.*')">Records</flux:navlist.item>
                        @endif
                    @endguest
                </flux:navlist>

                <flux:spacer />

                <flux:navlist variant="pill">
                    <flux:navlist.item icon="cog-6-tooth" href="{{ route('profile.show') }}">Settings</flux:navlist.item>
                </flux:navlist>

                <flux:dropdown class="mb-5" position="top">
                    <flux:profile name="{{ auth()->user()->name }}" avatar="{{ auth()->user()->profile_photo_url }}" />

                    <flux:menu>
                         <!-- Account Management -->
                        <div class="block px-4 py-2 text-xs text-gray-400">
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

                        <div class="border-t border-gray-200"></div>

                        @if (Laravel\Jetstream\Jetstream::hasTeamFeatures() && Auth::user()->currentTeam)
                             <!-- Team Management -->
                            <div class="block px-4 py-2 text-xs text-gray-400">
                                {{ __('Manage Team') }}
                            </div>

                            <!-- Team Settings -->
                            <flux:menu.item icon="cog-6-tooth" href="{{ route('teams.show', Auth::user()->currentTeam->id) }}">
                                {{ __('Team Settings') }}
                            </flux:menu.item>

                            @can('create', Laravel\Jetstream\Jetstream::newTeamModel())
                                <flux:menu.item icon="plus" href="{{ route('teams.create') }}">
                                    {{ __('Create New Team') }}
                                </flux:menu.item>
                            @endcan

                            @if (Auth::user()->allTeams()->count() > 1)
                                <div class="border-t border-gray-200"></div>

                                <div class="block px-4 py-2 text-xs text-gray-400">
                                    {{ __('Switch Teams') }}
                                </div>

                                @foreach (Auth::user()->allTeams() as $team)
                                    <flux:menu.item onclick="document.getElementById('switch-team-{{ $team->id }}').submit()">
                                        <div class="flex items-center gap-2">
                                            @if (Auth::user()->isCurrentTeam($team))
                                                <flux:icon name="check" variant="solid" class="w-4 h-4 text-green-500" />
                                            @endif
                                            {{ $team->name }}
                                        </div>
                                    </flux:menu.item>
                                @endforeach
                            @endif
                        @endif

                        <div class="border-t border-gray-200"></div>

                        <flux:menu.item icon="arrow-right-start-on-rectangle" href="{{ route('logout') }}" onclick="event.preventDefault(); document.getElementById('logout-form').submit();" variant="danger">
                            Log out
                        </flux:menu.item>
                    </flux:menu>
                </flux:dropdown>

                <!-- Hidden Forms for Actions -->
                <form id="logout-form" action="{{ route('logout') }}" method="POST" class="hidden">
                    @csrf
                </form>

                @if (Laravel\Jetstream\Jetstream::hasTeamFeatures())
                    @foreach (Auth::user()->allTeams() as $team)
                        <form method="POST" action="{{ route('current-team.update') }}" id="switch-team-{{ $team->id }}" class="hidden">
                            @method('PUT')
                            @csrf
                            <input type="hidden" name="team_id" value="{{ $team->id }}">
                        </form>
                    @endforeach
                @endif
            </flux:sidebar>

            <div class="flex-1 flex flex-col min-w-0">
                <flux:header class="border-b border-zinc-200 dark:border-zinc-800 lg:hidden">
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

        @livewireScripts
        @fluxScripts
        @stack('scripts')
    </body>
</html>
