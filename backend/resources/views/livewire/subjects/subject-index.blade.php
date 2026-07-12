<div>
    <x-slot name="header">
        <flux:heading size="xl">Subject Management</flux:heading>
        <flux:subheading>Manage academic subjects and their credit hours</flux:subheading>
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
                        placeholder="Search subjects…" size="sm" class="w-64" />
                </div>

                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Subject
                </flux:button>
            </div>

            {{-- Table --}}
            <flux:table :paginate="$subjects">
                <table class="w-full text-sm text-left">
                    <thead>
                        <tr class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] bg-gray-50 dark:bg-[#1e293b]">
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Code</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Name</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Credit Hours</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Created At</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-[#374151]">
                        @forelse ($subjects as $subject)
                            <tr class="hover:bg-gray-50/70 dark:hover:bg-[#263548]/50 transition-colors duration-100">
                                <td class="px-4 py-3 font-mono text-xs text-gray-600 dark:text-gray-400">{{ $subject->code }}</td>
                                <td class="px-4 py-3 font-medium text-gray-900 dark:text-gray-50">{{ $subject->name }}</td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">{{ $subject->credit_hours }}</td>
                                <td class="px-4 py-3 text-sm text-gray-400">{{ $subject->created_at?->format('M j, Y') ?? '—' }}</td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-2">
                                        <flux:button wire:click="edit('{{ $subject->id }}')" size="xs" variant="ghost">Edit</flux:button>
                                        <flux:button wire:click="delete('{{ $subject->id }}')" size="xs" variant="danger">Delete</flux:button>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="px-4 py-10 text-center text-gray-500 dark:text-gray-400">No subjects found.</td>
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
                    <flux:heading size="lg">Add New Subject</flux:heading>
                    <flux:button wire:click="$set('showCreateModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="store" class="p-6 space-y-4">
                    <flux:input label="Subject Name" wire:model="name" placeholder="e.g. Programming Fundamentals" />
                    <flux:input label="Subject Code" wire:model="code" placeholder="e.g. IT102" />
                    <flux:input label="Credit Hours" type="number" wire:model="credit_hours" />
                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showCreateModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Create Subject</flux:button>
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
                    <flux:heading size="lg">Edit Subject</flux:heading>
                    <flux:button wire:click="$set('showEditModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="update" class="p-6 space-y-4">
                    <flux:input label="Subject Name" wire:model="name" />
                    <flux:input label="Subject Code" wire:model="code" />
                    <flux:input label="Credit Hours" type="number" wire:model="credit_hours" />
                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showEditModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Update Subject</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
