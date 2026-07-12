<div>
    <x-slot name="header">
        <flux:heading size="xl">Attendance Sessions</flux:heading>
        <flux:subheading>Manage current and past attendance sessions</flux:subheading>
    </x-slot>

    <div class="space-y-4">

            @if (session()->has('message'))
                <flux:callout variant="success" icon="check-circle" dismissible>
                    {{ session('message') }}
                </flux:callout>
            @endif

            <div class="bg-white dark:bg-[#1e293b] rounded-xl border border-gray-200 dark:border-[rgba(255,255,255,0.08)] shadow-sm overflow-hidden">

                {{-- Toolbar --}}
                <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)]">
                    <div class="flex items-center gap-2">
                        <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                            placeholder="Search by teacher..." size="sm" class="w-52" />    
                        @if(count($selected) > 0)
                            <flux:button wire:click="deleteSelected" size="sm" variant="danger" icon="trash">
                                Delete ({{ count($selected) }})
                            </flux:button>
                        @endif
                    </div>

                    <flux:button href="{{ route('attendance.sessions.create') }}" size="sm" variant="primary" icon="plus">
                        New Session
                    </flux:button>
                </div>

                {{-- Table --}}
                <flux:table :paginate="$sessions">    
                    <table class="w-full text-sm text-left">
                        <colgroup>
                            <col class="w-10"> {{-- checkbox --}}
                            <col class="w-16"> {{-- status --}}
                            <col class="w-52"> {{-- teacher --}}
                            <col class="w-28"> {{-- Target --}}
                            <col class="w-24"> {{-- Count --}}
                            <col class="w-32"> {{-- Start Time --}}
                            <col class="w-24"> {{-- Room --}}
                            <col class="w-24"> {{-- Time Limit --}}
                        </colgroup>
                        <thead>
                            <tr class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] bg-gray-50 dark:bg-[#1e293b]">
                                <th class="px-4 py-3">
                                    <flux:checkbox wire:model.live="selectAll" />
                                </th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Status</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Teacher</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Class Detail</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Count</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Started At</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Room</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Limit</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-[#374151]">
                            @forelse ($sessions as $session)
                                <tr class="hover:bg-gray-50/70 dark:hover:bg-[#263548]/50 transition-colors duration-100">
                                    
                                    <td class="px-4 py-3">
                                        <flux:checkbox wire:model.live="selected" value="{{ $session->id }}" />
                                    </td>

                                    <td class="px-4 py-3">
                                        @if(!$session->is_active || ($session->expires_at && $session->expires_at->isPast()))
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 dark:bg-[#374151] text-gray-800 dark:text-gray-200">Closed</span>
                                        @else
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 dark:bg-green-900/40 text-green-800 dark:text-green-300">Active</span>
                                        @endif
                                    </td>

                                    <td class="px-4 py-3">
                                        <div class="font-medium text-gray-900 dark:text-gray-50 truncate">{{ $session->teacher->user->name ?? 'Unknown' }}</div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        <div class="font-medium text-gray-900 dark:text-gray-50">{{ $session->academicClass->name ?? ($session->major->name ?? '—') }}</div>
                                        <div class="text-xs text-gray-400 dark:text-gray-500">
                                            {{ $session->faculty->name ?? '' }} 
                                            @if($session->academicClass)
                                                ({{ $session->major->name ?? '' }})
                                            @endif
                                            @if($session->shift)
                                                <span class="ml-1 text-blue-500 font-medium">— {{ $session->shift->name }}</span>
                                            @endif
                                        </div>
                                        <div class="text-[10px] text-gray-400 dark:text-gray-500 mt-0.5">
                                            <flux:icon name="clock" class="inline w-3 h-3 mr-0.5" />
                                            {{ $session->schedule->full_display ?? ($session->schedule->name ?? '—') }}
                                        </div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        <span class="font-bold border px-2 py-1 rounded bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300">{{ $session->attendances_count }}</span>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        {{ $session->started_at->format('M d, H:i A') }}
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        <div class="font-medium">{{ $session->room->name ?? '—' }}</div>
                                        <div class="text-[10px] text-gray-400 dark:text-gray-500">{{ number_format($session->latitude, 4) }}, {{ number_format($session->longitude, 4) }}</div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        {{ $session->time_limit_minutes ?? 'None' }} mins
                                    </td>

                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="px-4 py-14 text-center">
                                        <div class="flex flex-col items-center gap-1.5 text-gray-400 dark:text-gray-500">
                                            <flux:icon name="clock" class="w-6 h-6 mb-0.5" />
                                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">No sessions found</p>
                                        </div>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </flux:table>
            </div>
    </div>
</div>
