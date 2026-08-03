@props(['disabled' => false])

<input {{ $disabled ? 'disabled' : '' }} {!! $attributes->merge(['class' => 'border-gray-300 dark:border-white/10 dark:bg-zinc-800 dark:text-zinc-50 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm']) !!}>
