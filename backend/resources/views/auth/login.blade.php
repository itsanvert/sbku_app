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
  <div class="hidden lg:flex flex-1 items-center justify-center bg-slate-100 relative overflow-hidden">

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
    <div class="bg-white/50 backdrop-blur-md border-t border-orange-100/60"
         style="box-shadow: 0 -1px 12px rgba(234, 88, 12, 0.06);">
        <div class="px-8 py-3 flex items-center justify-between">

          {{-- Left: Brand --}}
<div class="text-sm text-gray-600 relative inline-block">
    &copy; {{ date('Y') }}
    <span class="relative inline-block group/team cursor-pointer">
        <span class="font-semibold text-gray-800 border-b border-dashed border-gray-400 group-hover/team:border-gray-700 transition-colors duration-200">
            Vert San's Team
        </span>

        {{-- Hover Popup --}}
        <div class="absolute bottom-full left-1/2 -translate-x-1/2 mb-3 w-64 bg-white rounded-2xl shadow-2xl border border-gray-100 overflow-hidden
                    opacity-0 invisible translate-y-2
                    group-hover/team:opacity-100 group-hover/team:visible group-hover/team:translate-y-0
                    transition-all duration-300 ease-out z-50">

            {{-- Header --}}
            <div class="bg-gradient-to-r from-slate-800 to-slate-700 px-4 py-3">
                <p class="text-white text-xs font-semibold tracking-widest uppercase">Our Team</p>
            </div>

            {{-- Members List --}}
            <ul class="divide-y divide-gray-50 px-1 py-1">
                @php
                    $members = [

                        ['name' => 'Vert San',     'role' => 'Project Manager and Developer',   'avatar' => 'VS', 'color' => 'from-violet-500 to-purple-700'],
                        ['name' => 'Sina Horng', 'role' => 'UI/UX Designer and Developer',   'avatar' => 'AN', 'color' => 'from-pink-400 to-rose-600'],
                        ['name' => 'Sovannarak Chhoam',     'role' => 'Developer', 'avatar' => 'BT', 'color' => 'from-blue-400 to-blue-700'],
                        ['name' => 'Yuna Yun',    'role' => 'QA and Developer',     'avatar' => 'CL', 'color' => 'from-emerald-400 to-teal-600'],
                    ];
                @endphp

                @foreach($members as $member)
                <li class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-slate-50 transition-colors duration-150">
                    <div class="w-8 h-8 rounded-full bg-gradient-to-br {{ $member['color'] }} flex items-center justify-center flex-shrink-0 shadow-sm">
                        <span class="text-white text-xs font-bold">{{ $member['avatar'] }}</span>
                    </div>
                    <div class="min-w-0">
                        <p class="text-gray-900 text-xs font-semibold leading-tight truncate">{{ $member['name'] }}</p>
                        <p class="text-gray-400 text-[10px] leading-tight truncate">{{ $member['role'] }}</p>
                    </div>
                </li>
                @endforeach
            </ul>

            {{-- Arrow --}}
            <div class="absolute top-full left-1/2 -translate-x-1/2 -mt-px overflow-hidden w-4 h-2.5">
                <div class="w-3 h-3 bg-white border-r border-b border-gray-100 rotate-45 -translate-y-1.5 mx-auto shadow-sm"></div>
            </div>
        </div>
    </span>
    . All rights reserved.
</div>
        </div>
    </div>
</footer>
</div>

</x-guest-layout>

