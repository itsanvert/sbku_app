<div>
    <x-slot name="header">
        <flux:heading size="xl">Faculties</flux:heading>
        <flux:subheading>Organize faculties and their academic programs.</flux:subheading>
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
                    placeholder="Search faculties…" size="sm" class="w-full sm:w-72" />
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Faculty
                </flux:button>
            </div>

            <flux:table :paginate="$faculties">
                <flux:table.columns>
                    <flux:table.column>Name</flux:table.column>
                    <flux:table.column>Created At</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($faculties as $faculty)
                        <flux:table.row :key="$faculty->id">
                            <flux:table.cell variant="strong">{{ $faculty->name }}</flux:table.cell>
                            <flux:table.cell>{{ $faculty->created_at?->format('M j, Y') ?? '—' }}</flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-2">
                                    <flux:button wire:click="edit('{{ $faculty->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="delete('{{ $faculty->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="3">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="building-library" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No faculties found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new faculty.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Faculty</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-faculty" wire:model="showCreateModal">
        <div>
            <flux:heading size="lg">Add New Faculty</flux:heading>
            <flux:subheading>Create an academic faculty</flux:subheading>
        </div>

        <form wire:submit="store" class="mt-6 space-y-4">
            <flux:input label="Faculty Name" wire:model="name" placeholder="e.g. Faculty of Engineering" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Create Faculty</flux:button>
            </div>
        </form>
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-faculty" wire:model="showEditModal">
        <div>
            <flux:heading size="lg">Edit Faculty</flux:heading>
            <flux:subheading>Update faculty details</flux:subheading>
        </div>

        <form wire:submit="update" class="mt-6 space-y-4">
            <flux:input label="Faculty Name" wire:model="name" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Update Faculty</flux:button>
            </div>
        </form>
    </flux:modal>
</div>
