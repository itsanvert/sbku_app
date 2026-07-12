<x-guest-layout>
    <div class="pt-4 bg-gray-100 dark:bg-[#1e293b]">
        <div class="min-h-screen flex flex-col items-center pt-6 sm:pt-0">
            <div>
                <x-authentication-card-logo />
            </div>

            <div class="w-full sm:max-w-2xl mt-6 p-6 bg-white dark:bg-[#1e293b] shadow-md dark:shadow-[0_8px_32px_rgba(0,0,0,0.25)] overflow-hidden sm:rounded-lg prose">
                {!! $policy !!}
            </div>
        </div>
    </div>
</x-guest-layout>
