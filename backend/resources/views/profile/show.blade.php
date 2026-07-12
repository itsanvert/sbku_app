<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Settings') }}
        </h2>
    </x-slot>

    <div>
        <div class="max-w-7xl mx-auto py-10 sm:px-6 lg:px-8">

            {{-- Appearance / Dark Mode Toggle --}}
            <div class="sm:rounded-xl dark:bg-[#1e293b] dark:border dark:border-[rgba(255,255,255,0.08)] bg-white border border-gray-200 shadow-sm p-6 mb-10 backdrop-blur-xl">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <div class="p-2.5 rounded-xl bg-blue-50 dark:bg-[rgba(59,130,246,0.15)] text-blue-600 dark:text-[#3b82f6]">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" /></svg>
                        </div>
                        <div>
                            <h3 class="text-sm font-semibold text-gray-900 dark:text-[#f8fafc]">Appearance</h3>
                            <p class="text-xs text-gray-500 dark:text-[#64748b] mt-0.5">Choose your preferred theme</p>
                        </div>
                    </div>

                    {{-- Three-state toggle: System / Dark / Light --}}
                    <div x-data="themeToggle()" x-init="init()">
                        <div class="flex items-center bg-gray-100 dark:bg-[rgba(30,41,59,0.8)] rounded-xl p-1 border border-gray-200 dark:border-[rgba(255,255,255,0.08)]">
                            <button @click="setTheme('light')"
                                    class="relative flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all duration-200"
                                    :class="theme === 'light' ? 'bg-white dark:bg-[#3b82f6] text-gray-900 dark:text-white shadow-sm' : 'text-gray-500 dark:text-[#64748b] hover:text-gray-700 dark:hover:text-[#94a3b8]'">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-3.5 h-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" /></svg>
                                Light
                            </button>
                            <button @click="setTheme('dark')"
                                    class="relative flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all duration-200"
                                    :class="theme === 'dark' ? 'bg-white dark:bg-[#3b82f6] text-gray-900 dark:text-white shadow-sm' : 'text-gray-500 dark:text-[#64748b] hover:text-gray-700 dark:hover:text-[#94a3b8]'">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-3.5 h-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" /></svg>
                                Dark
                            </button>
                            <button @click="setTheme('system')"
                                    class="relative flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all duration-200"
                                    :class="theme === 'system' ? 'bg-white dark:bg-[#3b82f6] text-gray-900 dark:text-white shadow-sm' : 'text-gray-500 dark:text-[#64748b] hover:text-gray-700 dark:hover:text-[#94a3b8]'">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-3.5 h-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 7.41A2.25 2.25 0 012.25 5.495V5.25" /></svg>
                                System
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            @if (Laravel\Fortify\Features::canUpdateProfileInformation())
                @livewire('profile.update-profile-information-form')

                <x-section-border />
            @endif

            @if (Laravel\Fortify\Features::enabled(Laravel\Fortify\Features::updatePasswords()))
                <div class="mt-10 sm:mt-0">
                    @livewire('profile.update-password-form')
                </div>

                <x-section-border />
            @endif

            @if (Laravel\Fortify\Features::canManageTwoFactorAuthentication())
                <div class="mt-10 sm:mt-0">
                    @livewire('profile.two-factor-authentication-form')
                </div>

                <x-section-border />
            @endif

            <div class="mt-10 sm:mt-0">
                @livewire('profile.logout-other-browser-sessions-form')
            </div>

            @if (Laravel\Jetstream\Jetstream::hasAccountDeletionFeatures())
                <x-section-border />

                <div class="mt-10 sm:mt-0">
                    @livewire('profile.delete-user-form')
                </div>
            @endif
        </div>
    </div>

    @push('scripts')
    <script>
        function themeToggle() {
            return {
                theme: 'system',
                init() {
                    const stored = localStorage.getItem('theme');
                    this.theme = stored || 'system';
                    this.applyTheme();
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
                applyTheme() {
                    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    const isDark = this.theme === 'dark' || (this.theme === 'system' && prefersDark);
                    document.documentElement.classList.toggle('dark', isDark);
                }
            }
        }
    </script>
    @endpush
</x-app-layout>
