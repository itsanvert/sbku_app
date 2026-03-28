<div>
    <x-slot name="header">
        <flux:heading size="xl">Attendance Records</flux:heading>
        <flux:subheading>Manage individual student attendance records</flux:subheading>
    </x-slot>

    <div class="space-y-4">

            <div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">

                {{-- Toolbar --}}
                <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-zinc-200">
                    <div class="flex flex-wrap items-center gap-2">
                        <flux:input wire:model.live="search" icon="magnifying-glass"
                            placeholder="Student name..." size="sm" class="w-48" />

                        <flux:input wire:model.live="filterDate" type="date" size="sm" class="w-40" />

                        <div class="flex items-center gap-2">
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
                        </div>

                        @if($search || $filterDate || $filterMonth || $filterYear)
                            <flux:button wire:click="$set('search', ''); $set('filterDate', ''); $set('filterMonth', ''); $set('filterYear', '');" size="sm" variant="ghost" icon="x-mark">Clear</flux:button>
                        @endif
                    </div>
                    <div class="flex items-center gap-2">
                        <flux:button wire:click="exportPdf" icon="document-text" size="sm" variant="outline">PDF</flux:button>
                        <flux:button wire:click="exportExcel" icon="table-cells" size="sm" variant="outline">Excel</flux:button>
                    </div>
                </div>

                {{-- Table --}}
                <flux:table :paginate="$records">    
                    <table class="w-full text-sm text-left">
                        <colgroup>
                            <col class="w-16"> {{-- status --}}
                            <col class="w-48"> {{-- student --}}
                            <col class="w-48"> {{-- session --}}
                            <col class="w-32"> {{-- checked in --}}
                            <col class="w-24"> {{-- distance --}}
                        </colgroup>
                        <thead>
                            <tr class="border-b border-zinc-200 bg-zinc-50">
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Status</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Student</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Session / Teacher</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">Checked In At</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 select-none">GPS Dist</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100">
                            @forelse ($records as $record)
                                <tr class="hover:bg-zinc-50/70 transition-colors duration-100">

                                    <td class="px-4 py-3 font-medium">
                                        @if($record->status === 'Y')
                                            <span class="text-green-600 bg-green-50 px-2 py-1 rounded">Present</span>
                                        @elseif($record->status === 'N')
                                            <span class="text-red-600 bg-red-50 px-2 py-1 rounded">Absent</span>
                                        @elseif($record->status === 'L')
                                            <span class="text-orange-600 bg-orange-50 px-2 py-1 rounded">Late</span>
                                        @else
                                            <span class="text-gray-600">{{ ucfirst($record->status) }}</span>
                                        @endif
                                    </td>

                                    <td class="px-4 py-3">
                                        <div class="font-medium text-zinc-900 truncate">{{ $record->student->user->name ?? 'Unknown Student' }}</div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $record->session->teacher->user->name ?? 'Unknown Teacher' }}
                                    </td>

                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $record->check_in_time ? $record->check_in_time->format('M d, H:i:s') : '—' }}
                                    </td>

                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        —
                                    </td>

                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" class="px-4 py-14 text-center">
                                        <div class="flex flex-col items-center gap-1.5 text-zinc-400">
                                            <flux:icon name="users" class="w-6 h-6 mb-0.5" />
                                            <p class="text-sm font-medium text-zinc-500">No attendance records found</p>
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
