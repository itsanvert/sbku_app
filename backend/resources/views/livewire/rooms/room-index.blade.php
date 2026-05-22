<div>
    <x-slot name="header">
        <flux:heading size="xl">Room Management</flux:heading>
        <flux:subheading>Manage rooms and classrooms</flux:subheading>
    </x-slot>

    <div class="space-y-4">
        @if (session()->has('message'))
            <flux:callout variant="success" icon="check-circle" dismissible>
                {{ session('message') }}
            </flux:callout>
        @endif

        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">
            <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-zinc-200">
                <div class="flex items-center gap-2">
                    <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                        placeholder="Search rooms…" size="sm" class="w-64" />
                </div>

                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Room
                </flux:button>
            </div>

            <flux:table :paginate="$rooms">
                <table class="w-full text-sm text-left">
                    <thead>
                        <tr class="border-b border-zinc-200 bg-zinc-50">
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Name</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Code</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Created At</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-zinc-100">
                        @forelse ($rooms as $room)
                            <tr class="hover:bg-zinc-50/70 transition-colors duration-100">
                                <td class="px-4 py-3 font-medium text-zinc-900">{{ $room->name }}</td>
                                <td class="px-4 py-3 font-mono text-xs text-zinc-600">{{ $room->code ?? '—' }}</td>
                                <td class="px-4 py-3 text-sm text-zinc-400">{{ $room->created_at?->format('M j, Y') ?? '—' }}</td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-2">
                                        <flux:button wire:click="edit('{{ $room->id }}')" size="xs" variant="ghost">Edit</flux:button>
                                        <flux:button wire:click="delete('{{ $room->id }}')" size="xs" variant="danger">Delete</flux:button>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="px-4 py-10 text-center text-zinc-500">No rooms found.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </flux:table>
        </div>
    </div>

    {{-- Create Modal --}}
    @if ($showCreateModal)
        <div class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-xl shadow-xl w-full max-w-md">
                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                    <flux:heading size="lg">Add New Room</flux:heading>
                    <flux:button wire:click="$set('showCreateModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="store" class="p-6 space-y-4">
                    <flux:input label="Room Name" wire:model="name" placeholder="e.g. Lecture Hall A" />
                    <flux:input label="Room Code" wire:model="code" placeholder="e.g. LH-A" />
                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showCreateModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Create Room</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif

    {{-- Edit Modal --}}
    @if ($showEditModal)
        <div class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-xl shadow-xl w-full max-w-md">
                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                    <flux:heading size="lg">Edit Room</flux:heading>
                    <flux:button wire:click="$set('showEditModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="update" class="p-6 space-y-4">
                    <flux:input label="Room Name" wire:model="name" />
                    <flux:input label="Room Code" wire:model="code" />
                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showEditModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Update Room</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
