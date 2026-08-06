<div>
    <x-slot name="header">
        <flux:heading size="xl">Attendance</flux:heading>
        <flux:subheading>Track attendance records and monitor participation.</flux:subheading>
    </x-slot>

    <div class="space-y-4">
        <flux:card>
            {{-- Toolbar --}}
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                <div class="flex flex-wrap items-center gap-2">
                    <flux:input wire:model.live="search" icon="magnifying-glass"
                        placeholder="Student name..." size="sm" class="w-48" />
                    <flux:input wire:model.live="filterDate" type="date" size="sm" class="w-40" />
                    <flux:select wire:model.live="filterMonth" size="sm" class="w-32" placeholder="Month">
                        <flux:select.option value="">All Months</flux:select.option>
                        @for($i=1; $i<=12; $i++)
                            <flux:select.option value="{{ str_pad($i, 2, '0', STR_PAD_LEFT) }}">{{ date('F', mktime(0, 0, 0, $i, 1)) }}</flux:select.option>
                        @endfor
                    </flux:select>
                    <flux:select wire:model.live="filterYear" size="sm" class="w-28" placeholder="Year">
                        <flux:select.option value="">All Years</flux:select.option>
                        @for($i=date('Y'); $i>=2020; $i--)
                            <flux:select.option value="{{ $i }}">{{ $i }}</flux:select.option>
                        @endfor
                    </flux:select>
                    @if($search || $filterDate || $filterMonth || $filterYear)
                        <flux:button wire:click="$set('search', ''); $set('filterDate', ''); $set('filterMonth', ''); $set('filterYear', '');" size="sm" variant="ghost" icon="x-mark">Clear</flux:button>
                    @endif
                </div>
                <div class="flex items-center gap-2">
                    <flux:button wire:click="exportPdf" icon="document-text" size="sm" variant="outline">PDF</flux:button>
                    <flux:button wire:click="exportExcel" icon="table-cells" size="sm" variant="outline">Excel</flux:button>
                </div>
            </div>

            <flux:table :paginate="$records">
                <flux:table.columns>
                    <flux:table.column>Status</flux:table.column>
                    <flux:table.column>Student</flux:table.column>
                    <flux:table.column>Session / Teacher</flux:table.column>
                    <flux:table.column>Checked In At</flux:table.column>
                    <flux:table.column>GPS Dist</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($records as $record)
                        <flux:table.row :key="$record->id">
                            <flux:table.cell>
                                @if($record->status === 'Y')
                                    <flux:badge size="sm" color="green">Present</flux:badge>
                                @elseif($record->status === 'N')
                                    <flux:badge size="sm" color="red">Absent</flux:badge>
                                @elseif($record->status === 'L')
                                    <flux:badge size="sm" color="orange">Late</flux:badge>
                                @else
                                    <flux:badge size="sm" color="zinc">{{ ucfirst($record->status) }}</flux:badge>
                                @endif
                            </flux:table.cell>
                            <flux:table.cell variant="strong">{{ $record->student->user->name ?? 'Unknown Student' }}</flux:table.cell>
                            <flux:table.cell>{{ $record->session->teacher->user->name ?? 'Unknown Teacher' }}</flux:table.cell>
                            <flux:table.cell>{{ $record->check_in_time ? $record->check_in_time->format('M d, H:i:s') : '—' }}</flux:table.cell>
                            <flux:table.cell>—</flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="5">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="clipboard-document-check" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No attendance records found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">No check-ins match your current filters.</p>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>
</div>
