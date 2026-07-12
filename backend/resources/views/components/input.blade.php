@props(['disabled' => false])

<input {{ $disabled ? 'disabled' : '' }} {!! $attributes->merge(['class' => 'border-gray-300 dark:border-[rgba(255,255,255,0.08)] dark:bg-[#1e293b] dark:text-gray-50 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm']) !!}>
