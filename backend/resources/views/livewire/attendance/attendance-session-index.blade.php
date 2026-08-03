<div>
    <x-slot name="header">
        <flux:heading size="xl">Attendance Sessions</flux:heading>
        <flux:subheading>Manage current and past attendance sessions.</flux:subheading>
    </x-slot>

    <div class="space-y-4">
        @if (session()->has('message'))
            <flux:callout variant="success" icon="check-circle" dismissible>
                {{ session('message') }}
            </flux:callout>
        @endif

        <flux:card>
            {{-- Toolbar --}}
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                <div class="flex flex-wrap items-center gap-2">
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

            <flux:table :paginate="$sessions">
                <flux:table.columns>
                    <flux:table.column>
                        <flux:checkbox wire:model.live="selectAll" />
                    </flux:table.column>
                    <flux:table.column>Status</flux:table.column>
                    <flux:table.column>Teacher</flux:table.column>
                    <flux:table.column>Class Detail</flux:table.column>
                    <flux:table.column>Count</flux:table.column>
                    <flux:table.column>Started At</flux:table.column>
                    <flux:table.column>Room</flux:table.column>
                    <flux:table.column>Limit</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($sessions as $session)
                        <flux:table.row :key="$session->id">
                            <flux:table.cell>
                                <flux:checkbox wire:model.live="selected" value="{{ $session->id }}" />
                            </flux:table.cell>
                            <flux:table.cell>
                                @if(!$session->is_active || ($session->expires_at && $session->expires_at->isPast()))
                                    <flux:badge size="sm" color="zinc">Closed</flux:badge>
                                @else
                                    <flux:badge size="sm" color="green">Active</flux:badge>
                                @endif
                            </flux:table.cell>
                            <flux:table.cell variant="strong">{{ $session->teacher->user->name ?? 'Unknown' }}</flux:table.cell>
                            <flux:table.cell>
                                <div class="text-sm font-medium">{{ $session->academicClass->name ?? ($session->major->name ?? '—') }}</div>
                                <div class="text-xs text-zinc-400 dark:text-zinc-500">
                                    {{ $session->faculty->name ?? '' }}
                                    @if($session->academicClass)
                                        ({{ $session->major->name ?? '' }})
                                    @endif
                                    @if($session->shift)
                                        <span class="text-blue-500 font-medium">— {{ $session->shift->name }}</span>
                                    @endif
                                </div>
                                <div class="text-[10px] text-zinc-400 dark:text-zinc-500 mt-0.5">
                                    <flux:icon name="clock" class="inline w-3 h-3 mr-0.5" />
                                    {{ $session->schedule->full_display ?? ($session->schedule->name ?? '—') }}
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="blue">{{ $session->attendances_count }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $session->started_at->format('M d, H:i A') }}</flux:table.cell>
                            <flux:table.cell>
                                <div class="text-sm font-medium">{{ $session->room->name ?? '—' }}</div>
                                <div class="text-[10px] text-zinc-400 dark:text-zinc-500">{{ number_format($session->latitude, 4) }}, {{ number_format($session->longitude, 4) }}</div>
                            </flux:table.cell>
                            <flux:table.cell>{{ $session->time_limit_minutes ?? 'None' }} mins</flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="8">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="clock" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No sessions found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">No attendance sessions match your current filters.</p>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>
</div>
