<div>
    <x-slot name="header">
        <flux:heading size="xl">Rooms</flux:heading>
        <flux:subheading>Manage classrooms, capacities, locations, and availability.</flux:subheading>
    </x-slot>

    <div class="space-y-4">
        @if (session()->has('message'))
            <flux:callout variant="success" icon="check-circle" dismissible>
                {{ session('message') }}
            </flux:callout>
        @endif

        <flux:card>
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                    placeholder="Search rooms…" size="sm" class="w-full sm:w-72" />
            </div>

            <flux:table :paginate="$rooms">
                <flux:table.columns>
                    <flux:table.column>Name</flux:table.column>
                    <flux:table.column>Code</flux:table.column>
                    <flux:table.column>Created At</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($rooms as $room)
                        <flux:table.row :key="$room->id">
                            <flux:table.cell variant="strong">{{ $room->name }}</flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="zinc">{{ $room->code ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $room->created_at?->format('M j, Y') ?? '—' }}</flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-2">
                                    <flux:button wire:click="edit('{{ $room->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="delete('{{ $room->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="4">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="building-office" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No rooms found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new room.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Room</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-room" wire:model="showCreateModal">
        <div>
            <flux:heading size="lg">Add New Room</flux:heading>
            <flux:subheading>Create a room or classroom</flux:subheading>
        </div>

        <form wire:submit="store" class="mt-6 space-y-4">
            <flux:input label="Room Name" wire:model="name" placeholder="e.g. Lecture Hall A" />
            <flux:input label="Room Code" wire:model="code" placeholder="e.g. LH-A" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Create Room</flux:button>
            </div>
        </form>
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-room" wire:model="showEditModal">
        <div>
            <flux:heading size="lg">Edit Room</flux:heading>
            <flux:subheading>Update room details</flux:subheading>
        </div>

        <form wire:submit="update" class="mt-6 space-y-4">
            <flux:input label="Room Name" wire:model="name" />
            <flux:input label="Room Code" wire:model="code" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Update Room</flux:button>
            </div>
        </form>
    </flux:modal>
</div>
