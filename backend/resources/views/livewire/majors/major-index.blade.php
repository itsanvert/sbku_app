<div>
    <x-slot name="header">
        <flux:heading size="xl">Majors</flux:heading>
        <flux:subheading>Manage majors, curricula, and faculty associations.</flux:subheading>
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
                    placeholder="Search majors…" size="sm" class="w-full sm:w-72" />
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Major
                </flux:button>
            </div>

            <flux:table :paginate="$majors">
                <flux:table.columns>
                    <flux:table.column>Name</flux:table.column>
                    <flux:table.column>Faculty</flux:table.column>
                    <flux:table.column>Created At</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($majors as $major)
                        <flux:table.row :key="$major->id">
                            <flux:table.cell variant="strong">{{ $major->name }}</flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="zinc">{{ $major->faculty->name ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $major->created_at?->format('M j, Y') ?? '—' }}</flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-2">
                                    <flux:button wire:click="edit('{{ $major->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="delete('{{ $major->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="4">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="academic-cap" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No majors found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new major.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Major</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-major" wire:model="showCreateModal">
        <div>
            <flux:heading size="lg">Add New Major</flux:heading>
            <flux:subheading>Create an academic major</flux:subheading>
        </div>

        <form wire:submit="store" class="mt-6 space-y-4">
            <flux:input label="Major Name" wire:model="name" placeholder="e.g. Computer Science" />

            <flux:select label="Faculty" wire:model="faculty_id" placeholder="Select a faculty">
                @foreach($faculties as $faculty)
                    <flux:select.option value="{{ (string) $faculty->id }}">{{ $faculty->name }}</flux:select.option>
                @endforeach
            </flux:select>

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Create Major</flux:button>
            </div>
        </form>
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-major" wire:model="showEditModal">
        <div>
            <flux:heading size="lg">Edit Major</flux:heading>
            <flux:subheading>Update major details</flux:subheading>
        </div>

        <form wire:submit="update" class="mt-6 space-y-4">
            <flux:input label="Major Name" wire:model="name" />

            <flux:select label="Faculty" wire:model="faculty_id">
                @foreach($faculties as $faculty)
                    <flux:select.option value="{{ (string) $faculty->id }}">{{ $faculty->name }}</flux:select.option>
                @endforeach
            </flux:select>

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Update Major</flux:button>
            </div>
        </form>
    </flux:modal>
</div>
