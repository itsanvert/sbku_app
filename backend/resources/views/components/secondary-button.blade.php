<button {{ $attributes->merge(['type' => 'button', 'class' => 'inline-flex items-center px-4 py-2 bg-white dark:bg-[#1e293b] border border-gray-300 dark:border-[rgba(255,255,255,0.08)] rounded-md font-semibold text-xs text-gray-700 dark:text-gray-300 uppercase tracking-widest shadow-sm hover:bg-gray-50 dark:hover:bg-[#263548] focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 dark:focus:ring-offset-[#1f2937] disabled:opacity-25 transition ease-in-out duration-150']) }}>
    {{ $slot }}
</button>
