<div>
    <x-slot name="header">
        <flux:heading size="xl">Class Management</flux:heading>
        <flux:subheading>Manage academic classes, years, and semesters</flux:subheading>
    </x-slot>

    <div class="space-y-4">
        {{-- Flash Message --}}
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
                        placeholder="Search classes…" size="sm" class="w-64" />
                </div>

                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Class
                </flux:button>
            </div>

            {{-- Table --}}
            <flux:table :paginate="$this->classes">
                <table class="w-full text-sm text-left">
                    <thead>
                        <tr class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] bg-gray-50 dark:bg-[#1e293b]">
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Code</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Name</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Major</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Year/Sem</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-[#374151]">
                        @forelse ($classes as $class)
                            <tr class="hover:bg-gray-50/70 dark:hover:bg-[#263548]/50 transition-colors duration-100">
                                <td class="px-4 py-3 font-mono text-xs text-gray-600 dark:text-gray-400">{{ $class->code }}</td>
                                <td class="px-4 py-3 font-medium text-gray-900 dark:text-gray-50">{{ $class->name }}</td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                    {{ $class->major->name ?? '—' }}
                                    <div class="text-xs text-gray-400">{{ $class->major->faculty->name ?? '' }}</div>
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                    {{ $class->academic_year }}
                                    <div class="text-xs text-gray-400">Semester {{ $class->semester }}</div>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-2">
                                        <flux:button wire:click="edit('{{ $class->id }}')" size="xs" variant="ghost">Edit</flux:button>
                                        <flux:button wire:click="delete('{{ $class->id }}')" size="xs" variant="danger">Delete</flux:button>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="px-4 py-10 text-center text-gray-500 dark:text-gray-400">No classes found.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </flux:table>
        </div>
    </div>

    {{-- Create Modal --}}
    @if ($showCreateModal)
        <div class="fixed inset-0 bg-gray-900/50 dark:bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white dark:bg-[#1e293b] rounded-xl shadow-xl w-full max-w-md">
                <div class="px-6 py-4 border-b border-gray-100 dark:border-[rgba(255,255,255,0.08)] flex items-center justify-between">
                    <flux:heading size="lg">Add New Class</flux:heading>
                    <flux:button wire:click="$set('showCreateModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="store" class="p-6 space-y-4">
                    <flux:input label="Class Name" wire:model="name" placeholder="e.g. M1-A" />
                    <flux:input label="Class Code" wire:model="code" placeholder="e.g. CLS001" />

                    <flux:select label="Major" wire:model="major_id" placeholder="Select a major">
                        <flux:select.option value="">Select Major</flux:select.option>
                        @foreach($majors as $major)
                            <flux:select.option value="{{ (string)$major->id }}">{{ $major->name }} ({{ $major->faculty->name ?? '' }})</flux:select.option>
                        @endforeach
                    </flux:select>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:input label="Academic Year" wire:model="academic_year" placeholder="e.g. 2025-2026" />
                        <flux:select label="Semester" wire:model="semester">
                            <flux:select.option value="1">Semester 1</flux:select.option>
                            <flux:select.option value="2">Semester 2</flux:select.option>
                        </flux:select>
                    </div>

                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showCreateModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Create Class</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif

    {{-- Edit Modal --}}
    @if ($showEditModal)
        <div class="fixed inset-0 bg-gray-900/50 dark:bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white dark:bg-[#1e293b] rounded-xl shadow-xl w-full max-w-md">
                <div class="px-6 py-4 border-b border-gray-100 dark:border-[rgba(255,255,255,0.08)] flex items-center justify-between">
                    <flux:heading size="lg">Edit Class</flux:heading>
                    <flux:button wire:click="$set('showEditModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="update" class="p-6 space-y-4">
                    <flux:input label="Class Name" wire:model="name" />
                    <flux:input label="Class Code" wire:model="code" />

                    <flux:select label="Major" wire:model="major_id">
                        @foreach($majors as $major)
                            <flux:select.option value="{{ (string)$major->id }}">{{ $major->name }} ({{ $major->faculty->name ?? '' }})</flux:select.option>
                        @endforeach
                    </flux:select>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:input label="Academic Year" wire:model="academic_year" />
                        <flux:select label="Semester" wire:model="semester">
                            <flux:select.option value="1">Semester 1</flux:select.option>
                            <flux:select.option value="2">Semester 2</flux:select.option>
                        </flux:select>
                    </div>

                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showEditModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Update Class</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
