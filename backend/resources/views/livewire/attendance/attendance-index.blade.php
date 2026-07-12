<div>
    <x-slot name="header">
        <flux:heading size="xl">Attendance Records</flux:heading>
        <flux:subheading>Manage individual student attendance records</flux:subheading>
    </x-slot>

    <div class="space-y-4">

            <div class="bg-white dark:bg-[#1e293b] rounded-xl border border-gray-200 dark:border-[rgba(255,255,255,0.08)] shadow-sm overflow-hidden">

                {{-- Toolbar --}}
                <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)]">
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
                            <tr class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] bg-gray-50 dark:bg-[#1e293b]">
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Status</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Student</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Session / Teacher</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">Checked In At</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 select-none">GPS Dist</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-[#374151]">
                            @forelse ($records as $record)
                                <tr class="hover:bg-gray-50/70 dark:hover:bg-[#263548]/50 transition-colors duration-100">

                                    <td class="px-4 py-3 font-medium">
                                        @if($record->status === 'Y')
                                            <span class="text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30 px-2 py-1 rounded">Present</span>
                                        @elseif($record->status === 'N')
                                            <span class="text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30 px-2 py-1 rounded">Absent</span>
                                        @elseif($record->status === 'L')
                                            <span class="text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-900/30 px-2 py-1 rounded">Late</span>
                                        @else
                                            <span class="text-gray-600 dark:text-gray-300">{{ ucfirst($record->status) }}</span>
                                        @endif
                                    </td>

                                    <td class="px-4 py-3">
                                        <div class="font-medium text-gray-900 dark:text-gray-50 truncate">{{ $record->student->user->name ?? 'Unknown Student' }}</div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        {{ $record->session->teacher->user->name ?? 'Unknown Teacher' }}
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        {{ $record->check_in_time ? $record->check_in_time->format('M d, H:i:s') : '—' }}
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        —
                                    </td>

                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" class="px-4 py-14 text-center">
                                        <div class="flex flex-col items-center gap-1.5 text-gray-400 dark:text-gray-500">
                                            <flux:icon name="users" class="w-6 h-6 mb-0.5" />
                                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">No attendance records found</p>
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
