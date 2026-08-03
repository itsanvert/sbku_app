<x-app-layout>
    <x-slot name="header">
        <flux:heading size="xl">Settings</flux:heading>
    </x-slot>

    <div>
        <div class="max-w-7xl mx-auto py-6 space-y-6">

            {{-- Appearance / Dark Mode Toggle --}}
            <flux:card class="!p-6">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div class="flex items-center gap-4">
                        <div class="p-2 rounded-lg bg-zinc-100 dark:bg-white/10 text-zinc-600 dark:text-zinc-300">
                            <flux:icon name="sun" class="w-5 h-5" />
                        </div>
                        <div>
                            <flux:heading size="sm">Appearance</flux:heading>
                            <flux:subheading>Choose your preferred theme</flux:subheading>
                        </div>
                    </div>

                    {{-- Three-state toggle: System / Dark / Light --}}
                    <div x-data="themeToggle">
                        <div class="flex items-center gap-1 rounded-lg bg-zinc-100 dark:bg-white/10 p-1">
                            <button @click="setTheme('light')" type="button"
                                    class="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition"
                                    :class="theme === 'light' ? 'bg-white dark:bg-white/20 text-zinc-900 dark:text-white shadow-sm' : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200'">
                                <flux:icon name="sun" class="w-3.5 h-3.5" />
                                Light
                            </button>
                            <button @click="setTheme('dark')" type="button"
                                    class="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition"
                                    :class="theme === 'dark' ? 'bg-white dark:bg-white/20 text-zinc-900 dark:text-white shadow-sm' : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200'">
                                <flux:icon name="moon" class="w-3.5 h-3.5" />
                                Dark
                            </button>
                            <button @click="setTheme('system')" type="button"
                                    class="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition"
                                    :class="theme === 'system' ? 'bg-white dark:bg-white/20 text-zinc-900 dark:text-white shadow-sm' : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200'">
                                <flux:icon name="computer-desktop" class="w-3.5 h-3.5" />
                                System
                            </button>
                        </div>
                    </div>
                </div>
            </flux:card>

            @if (Laravel\Fortify\Features::canUpdateProfileInformation())
                @livewire('profile.update-profile-information-form')

                <x-section-border />
            @endif

            @if (Laravel\Fortify\Features::enabled(Laravel\Fortify\Features::updatePasswords()))
                <div class="mt-6 sm:mt-0">
                    @livewire('profile.update-password-form')
                </div>

                <x-section-border />
            @endif

            @if (Laravel\Fortify\Features::canManageTwoFactorAuthentication())
                <div class="mt-6 sm:mt-0">
                    @livewire('profile.two-factor-authentication-form')
                </div>

                <x-section-border />
            @endif

            <div class="mt-6 sm:mt-0">
                @livewire('profile.logout-other-browser-sessions-form')
            </div>

            @if (Laravel\Jetstream\Jetstream::hasAccountDeletionFeatures())
                <x-section-border />

                <div class="mt-6 sm:mt-0">
                    @livewire('profile.delete-user-form')
                </div>
            @endif
        </div>
    </div>
</x-app-layout>
