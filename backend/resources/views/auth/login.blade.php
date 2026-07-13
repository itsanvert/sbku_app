<x-guest-layout>

<div class="flex min-h-screen w-full">

    {{-- ── LEFT: Form Panel ── --}}
    <div class="w-full lg:w-5/12 xl:w-[45%] flex flex-col justify-center px-8 sm:px-14 xl:px-20 py-12 bg-white dark:bg-[#0f172a]">

        {{-- Logo --}}
        <div class="mb-10 ">
            <a href="{{ url('/') }}" class="inline-flex items-center space-x-2">
                <img src="{{ asset('img/logo.jpg') }}" alt="SBKU Logo" class="h-20  w-auto">
            </a>
        </div>

        {{-- Heading --}}
        <div class="mb-8">
            <h1 class="text-2xl font-bold text-gray-900 dark:text-gray-50 mb-1">Sign in to your account</h1>

        </div>

        {{-- Validation Errors --}}
        @if ($errors->any())
            <div class="mb-5 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg px-4 py-3 text-sm text-red-600 dark:text-red-400 space-y-0.5">
                @foreach ($errors->all() as $error)
                    <p>{{ $error }}</p>
                @endforeach
            </div>
        @endif

        {{-- Session Status --}}
        @session('status')
            <div class="mb-5 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 rounded-lg px-4 py-3 text-sm text-green-700 dark:text-green-400">
                {{ $value }}
            </div>
        @endsession

        {{-- Form --}}
        <form method="POST" action="{{ route('login') }}" class="space-y-5">
            @csrf

            {{-- Email --}}
            <div>
                <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">
                    {{ __('Email address') }}
                </label>
                <input id="email"
                       type="email"
                       name="email"
                       value="{{ old('email') }}"
                       required autofocus autocomplete="username"
                       class="w-full px-3.5 py-2.5 border border-gray-300 dark:border-[rgba(255,255,255,0.08)] rounded-lg text-sm text-gray-900 dark:text-gray-50 placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#FF6A00] focus:border-transparent transition duration-150 bg-white dark:bg-[#1e293b]">
            </div>

            {{-- Password --}}
            <div>
                <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">
                    {{ __('Password') }}
                </label>
                <input id="password"
                       type="password"
                       name="password"
                       required autocomplete="current-password"
                       class="w-full px-3.5 py-2.5 border border-gray-300 dark:border-[rgba(255,255,255,0.08)] rounded-lg text-sm text-gray-900 dark:text-gray-50 placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#FF6A00] focus:border-transparent transition duration-150 bg-white dark:bg-[#1e293b]">
            </div>


            {{-- Submit --}}
            <button type="submit"
                    class="w-full py-2.5 bg-[#FF6A00] hover:bg-[#E85D00] text-white text-sm font-semibold rounded-lg transition-colors duration-150 focus:outline-none focus:ring-2 focus:ring-[#FF6A00] focus:ring-offset-2 shadow-lg shadow-orange-500/20 hover:shadow-orange-500/30">
                {{ __('Sign in') }}
            </button>
        </form>
    </div>

    {{-- ── RIGHT: Image Panel ── --}}
  <div class="hidden lg:flex flex-1 items-center justify-center bg-gray-100 dark:bg-[#0f172a] relative overflow-hidden">

    {{-- Subtle background texture --}}
    <div class="absolute inset-0 opacity-30" style="background-image: radial-gradient(circle at 20% 80%, #cbd5e1 0%, transparent 50%), radial-gradient(circle at 80% 20%, #e2e8f0 0%, transparent 50%);"></div>

    <lottie-player
        src="{{ asset('lottie/welcome.json') }}"
        background="transparent"
        speed="1"
        loop
        autoplay
        style="width: 500px; height: 500px; position: relative; z-index: 1;">
    </lottie-player>

    <footer class="absolute bottom-0 left-0 w-full z-10">
    <div class="bg-white/50 dark:bg-[#1e293b]/50 backdrop-blur-md border-t border-gray-200/60 dark:border-[rgba(255,255,255,0.08)]"
         style="box-shadow: 0 -1px 12px rgba(0, 0, 0, 0.06);">
        <div class="px-8 py-3 flex items-center justify-between">

            {{-- Left: Brand --}}
            <div class="text-sm text-gray-600 dark:text-gray-400">
                &copy; {{ date('Y') }} From Vert San. All rights reserved.
            </div>
        </div>
    </div>
</footer>
</div>

</x-guest-layout>
