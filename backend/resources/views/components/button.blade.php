<button {{ $attributes->merge(['type' => 'submit', 'class' => 'inline-flex items-center px-4 py-2 bg-[#FF6A00] border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-[#E85D00] focus:bg-[#E85D00] active:bg-[#CC5200] focus:outline-none focus:ring-2 focus:ring-[#FF6A00] focus:ring-offset-2 dark:focus:ring-offset-[#1f2937] disabled:opacity-50 transition ease-in-out duration-150 shadow-lg shadow-orange-500/20']) }}>
    {{ $slot }}
</button>
