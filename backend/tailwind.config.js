import defaultTheme from "tailwindcss/defaultTheme";
import forms from "@tailwindcss/forms";

export default {
    darkMode: 'class',
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './vendor/livewire/flux-pro/stubs/**/*.blade.php',
        './vendor/livewire/flux/stubs/**/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
    ],

    theme: {
        extend: {
            fontFamily: {
                sans: ["ui-sans-serif", "system-ui", "sans-serif"],
            },
            colors: {
                dark: {
                    bg: '#111827',
                    surface: '#1f2937',
                    'surface-2': '#273549',
                    border: '#374151',
                    text: '#f9fafb',
                    'text-secondary': '#e5e7eb',
                    'text-muted': '#9ca3af',
                    primary: '#4f8cff',
                    'primary-hover': '#3b82f6',
                    success: '#10b981',
                    warning: '#f59e0b',
                    danger: '#ef4444',
                },
            },
        },
    },

    plugins: [forms],
};
