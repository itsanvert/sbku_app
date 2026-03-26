<div>
    <x-slot name="header">
        <flux:heading size="xl">Attendance Sessions</flux:heading>
        <flux:subheading>Manage current and past attendance sessions</flux:subheading>
    </x-slot>

    <div class="py-6">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-4">

            @if (session()->has('message'))
                <flux:callout variant="success" icon="check-circle" dismissible>
                    {{ session('message') }}
                </flux:callout>
            @endif

            <div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">

                {{-- Toolbar --}}
                <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-zinc-200">
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
                            <col class="w-24"> {{-- Location --}}
                            <col class="w-24"> {{-- Time Limit --}}
                        </colgroup>
                        <thead>
                            <tr class="border-b border-zinc-200 bg-zinc-50">
                                <th class="px-4 py-3">
                                    <flux:checkbox wire:model.live="selectAll" />
                                </th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Status</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Teacher</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Class Detail</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Count</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Started At</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Coords</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Limit</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100">
                            @forelse ($sessions as $session)
                                <tr class="hover:bg-zinc-50/70 transition-colors duration-100">
                                    
                                    <td class="px-4 py-3">
                                        <flux:checkbox wire:model.live="selected" value="{{ $session->id }}" />
                                    </td>

                                    <td class="px-4 py-3">
                                        @if($session->expires_at && $session->expires_at->isPast())
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800">Closed</span>
                                        @else
                                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">Active</span>
                                        @endif
                                    </td>

                                    <td class="px-4 py-3">
                                        <div class="font-medium text-zinc-900 truncate">{{ $session->teacher->user->name ?? 'Unknown' }}</div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        <div>{{ $session->faculty->name ?? '' }} - {{ $session->major->name ?? '' }}</div>
                                        <div class="text-xs text-zinc-400">{{ $session->schedule->name ?? '' }}</div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        <span class="font-bold border px-2 py-1 rounded bg-blue-50 text-blue-700">{{ $session->attendances_count }}</span>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $session->started_at->format('M d, H:i A') }}
                                    </td>

                                    <td class="px-4 py-3 text-xs text-zinc-400">
                                        {{ number_format($session->latitude, 4) }}, {{ number_format($session->longitude, 4) }}
                                    </td>

                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $session->time_limit_minutes ?? 'None' }} mins
                                    </td>

                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="px-4 py-14 text-center">
                                        <div class="flex flex-col items-center gap-1.5 text-zinc-400">
                                            <flux:icon name="clock" class="w-6 h-6 mb-0.5" />
                                            <p class="text-sm font-medium text-zinc-500">No sessions found</p>
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
</div>
