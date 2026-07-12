<div class="min-h-screen flex flex-col sm:justify-center items-center pt-6 sm:pt-0 bg-gray-100 dark:bg-[#0f172a]">
    <div>
        {{ $logo }}
    </div>

    <div class="w-full sm:max-w-md mt-6 px-6 py-4 bg-white dark:bg-[#1e293b] shadow-md dark:shadow-[0_8px_32px_rgba(0,0,0,0.25)] overflow-hidden sm:rounded-2xl dark:border dark:border-[rgba(255,255,255,0.08)]">
        {{ $slot }}
    </div>
</div>
