<div>
    <x-slot name="header">
        <flux:heading size="xl">Subjects</flux:heading>
        <flux:subheading>Manage courses, credits, and subject information.</flux:subheading>
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
                    placeholder="Search subjects…" size="sm" class="w-full sm:w-72" />
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Subject
                </flux:button>
            </div>

            <flux:table :paginate="$subjects">
                <flux:table.columns>
                    <flux:table.column>Name</flux:table.column>
                    <flux:table.column>Code</flux:table.column>
                    <flux:table.column>Credit Hours</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($subjects as $subject)
                        <flux:table.row :key="$subject->id">
                            <flux:table.cell variant="strong">{{ $subject->name }}</flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="zinc">{{ $subject->code }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $subject->credit_hours ?? '—' }}</flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-2">
                                    <flux:button wire:click="edit('{{ $subject->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="delete('{{ $subject->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="4">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="book-open" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No subjects found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new subject.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Subject</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-subject" wire:model="showCreateModal">
        <div>
            <flux:heading size="lg">Add New Subject</flux:heading>
            <flux:subheading>Create an academic subject</flux:subheading>
        </div>

        <form wire:submit="store" class="mt-6 space-y-4">
            <flux:input label="Subject Name" wire:model="name" placeholder="e.g. Data Structures" />
            <flux:input label="Code" wire:model="code" placeholder="e.g. CS-201" />
            <flux:input label="Credit Hours" type="number" wire:model="credit_hours" min="1" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Create Subject</flux:button>
            </div>
        </form>
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-subject" wire:model="showEditModal">
        <div>
            <flux:heading size="lg">Edit Subject</flux:heading>
            <flux:subheading>Update subject details</flux:subheading>
        </div>

        <form wire:submit="update" class="mt-6 space-y-4">
            <flux:input label="Subject Name" wire:model="name" />
            <flux:input label="Code" wire:model="code" />
            <flux:input label="Credit Hours" type="number" wire:model="credit_hours" min="1" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Update Subject</flux:button>
            </div>
        </form>
    </flux:modal>
</div>
