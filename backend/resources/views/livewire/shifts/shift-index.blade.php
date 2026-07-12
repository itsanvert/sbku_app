<div>
    <x-slot name="header">
        <flux:heading size="xl">Shift Management</flux:heading>
        <flux:subheading>Manage academic shifts (e.g. Morning, Afternoon, Evening)</flux:subheading>
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
                        placeholder="Search shifts…" size="sm" class="w-64" />
                </div>

                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Shift
                </flux:button>
            </div>

            {{-- Table --}}
            <flux:table :paginate="$shifts">
                <table class="w-full text-sm text-left">
                    <thead>
                        <tr class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] bg-gray-50 dark:bg-[#1e293b]">
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Name</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Created At</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-[#374151]">
                        @forelse ($shifts as $shift)
                            <tr class="hover:bg-gray-50/70 dark:hover:bg-[#263548]/50 transition-colors duration-100">
                                <td class="px-4 py-3 font-medium text-gray-900 dark:text-gray-50">{{ $shift->name }}</td>
                                <td class="px-4 py-3 text-sm text-gray-400 dark:text-gray-500">{{ $shift->created_at?->format('M j, Y') ?? '—' }}</td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-2">
                                        <flux:button wire:click="edit('{{ $shift->id }}')" size="xs" variant="ghost">Edit</flux:button>
                                        <flux:button wire:click="delete('{{ $shift->id }}')" size="xs" variant="danger">Delete</flux:button>
                                    </div>
                                </td>
                            </tr>
@empty
                            <tr>
                                <td colspan="3" class="px-4 py-10 text-center text-gray-500 dark:text-gray-400">No shifts found.</td>
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
                    <flux:heading size="lg">Add New Shift</flux:heading>
                    <flux:button wire:click="$set('showCreateModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="store" class="p-6 space-y-4">
                    <flux:input label="Shift Name" wire:model="name" placeholder="e.g. Morning" />
                    
                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showCreateModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Create Shift</flux:button>
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
                    <flux:heading size="lg">Edit Shift</flux:heading>
                    <flux:button wire:click="$set('showEditModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="update" class="p-6 space-y-4">
                    <flux:input label="Shift Name" wire:model="name" />
                    
                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showEditModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Update Shift</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
