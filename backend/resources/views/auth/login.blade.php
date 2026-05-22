<x-guest-layout>

<div class="flex min-h-screen w-full">

    {{-- ── LEFT: Form Panel ── --}}
    <div class="w-full lg:w-5/12 xl:w-[45%] flex flex-col justify-center px-8 sm:px-14 xl:px-20 py-12 bg-white">

        {{-- Logo --}}
        <div class="mb-10 ">
            <a href="{{ url('/') }}" class="inline-flex items-center space-x-2">
                <img src="{{ asset('img/logo.jpg') }}" alt="SBKU Logo" class="h-20  w-auto">
            </a>
        </div>

        {{-- Heading --}}
        <div class="mb-8">
            <h1 class="text-2xl font-bold text-gray-900 mb-1">Sign in to your account</h1>

        </div>

        {{-- Validation Errors --}}
        @if ($errors->any())
            <div class="mb-5 bg-red-50 border border-red-200 rounded-lg px-4 py-3 text-sm text-red-600 space-y-0.5">
                @foreach ($errors->all() as $error)
                    <p>{{ $error }}</p>
                @endforeach
            </div>
        @endif

        {{-- Session Status --}}
        @session('status')
            <div class="mb-5 bg-green-50 border border-green-200 rounded-lg px-4 py-3 text-sm text-green-700">
                {{ $value }}
            </div>
        @endsession

        {{-- Form --}}
        <form method="POST" action="{{ route('login') }}" class="space-y-5">
            @csrf

            {{-- Email --}}
            <div>
                <label for="email" class="block text-sm font-medium text-gray-700 mb-1.5">
                    {{ __('Email address') }}
                </label>
                <input id="email"
                       type="email"
                       name="email"
                       value="{{ old('email') }}"
                       required autofocus autocomplete="username"
                       class="w-full px-3.5 py-2.5 border border-gray-300 rounded-lg text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent transition duration-150">
            </div>

            {{-- Password --}}
            <div>
                <label for="password" class="block text-sm font-medium text-gray-700 mb-1.5">
                    {{ __('Password') }}
                </label>
                <input id="password"
                       type="password"
                       name="password"
                       required autocomplete="current-password"
                       class="w-full px-3.5 py-2.5 border border-gray-300 rounded-lg text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent transition duration-150">
            </div>


            {{-- Submit --}}
            <button type="submit"
                    class="w-full py-2.5 bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold rounded-lg transition-colors duration-150 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2">
                {{ __('Sign in') }}
            </button>
        </form>
    </div>

    {{-- ── RIGHT: Image Panel ── --}}
  <div class="hidden lg:flex flex-1 items-center justify-center bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200 relative overflow-hidden">

    {{-- Decorative circles --}}
    <div class="absolute top-20 left-20 w-72 h-72 bg-orange-300/30 rounded-full blur-3xl"></div>
    <div class="absolute bottom-20 right-20 w-96 h-96 bg-orange-400/20 rounded-full blur-3xl"></div>

    {{-- Brand panel --}}
    <div class="relative z-10 text-center px-8">
        <div class="w-32 h-32 mx-auto mb-6 bg-white/80 backdrop-blur rounded-2xl shadow-lg flex items-center justify-center">
            <img src="{{ asset('img/logo.jpg') }}" alt="SBKU" class="w-24 h-24 object-contain rounded-lg">
        </div>
        <h2 class="text-3xl font-bold text-gray-800 mb-2">SBKU App</h2>
        <p class="text-lg text-gray-600">Student Attendance System</p>
    </div>

    <footer class="absolute bottom-0 left-0 w-full z-10">
    <div class="bg-white/50 backdrop-blur-md border-t border-orange-100/60"
         style="box-shadow: 0 -1px 12px rgba(234, 88, 12, 0.06);">
        <div class="px-8 py-3 flex items-center justify-between">

            {{-- Left: Brand --}}
            <div class="text-sm text-gray-600">
                &copy; {{ date('Y') }} From Vert San. All rights reserved.
            </div>
        </div>
    </div>
</footer>
</div>

</x-guest-layout>

