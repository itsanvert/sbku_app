<div>
    <x-slot name="header">
        <flux:heading size="xl">Classes</flux:heading>
        <flux:subheading>Manage class sections, student enrollment, and schedules.</flux:subheading>
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
                    placeholder="Search classes…" size="sm" class="w-full sm:w-72" />
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Class
                </flux:button>
            </div>

            <flux:table :paginate="$classes">
                <flux:table.columns>
                    <flux:table.column>Name</flux:table.column>
                    <flux:table.column>Code</flux:table.column>
                    <flux:table.column>Major</flux:column>
                    <flux:table.column>Year</flux:table.column>
                    <flux:table.column>Semester</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($classes as $class)
                        <flux:table.row :key="$class->id">
                            <flux:table.cell variant="strong">{{ $class->name }}</flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="zinc">{{ $class->code }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $class->major?->name ?? '—' }}</flux:table.cell>
                            <flux:table.cell>{{ $class->academic_year ?? '—' }}</flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="indigo">Sem {{ $class->semester }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-2">
                                    <flux:button wire:click="edit('{{ $class->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="delete('{{ $class->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="6">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="building-library" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No classes found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new class.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Class</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-class" wire:model="showCreateModal">
        <div>
            <flux:heading size="lg">Add New Class</flux:heading>
            <flux:subheading>Create an academic class</flux:subheading>
        </div>

        <form wire:submit="store" class="mt-6 space-y-4">
            <flux:input label="Class Name" wire:model="name" placeholder="e.g. CS First Year" />
            <flux:input label="Code" wire:model="code" placeholder="e.g. CS-1A" />
            <flux:select label="Major" wire:model="major_id" placeholder="Select a major">
                @foreach($majors as $major)
                    <flux:select.option value="{{ (string) $major->id }}">{{ $major->name }}</flux:select.option>
                @endforeach
            </flux:select>
            <flux:input label="Academic Year" wire:model="academic_year" placeholder="e.g. 2025" />
            <flux:input label="Semester" type="number" wire:model="semester" min="1" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Create Class</flux:button>
            </div>
        </form>
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-class" wire:model="showEditModal">
        <div>
            <flux:heading size="lg">Edit Class</flux:heading>
            <flux:subheading>Update class details</flux:subheading>
        </div>

        <form wire:submit="update" class="mt-6 space-y-4">
            <flux:input label="Class Name" wire:model="name" />
            <flux:input label="Code" wire:model="code" />
            <flux:select label="Major" wire:model="major_id">
                @foreach($majors as $major)
                    <flux:select.option value="{{ (string) $major->id }}">{{ $major->name }}</flux:select.option>
                @endforeach
            </flux:select>
            <flux:input label="Academic Year" wire:model="academic_year" />
            <flux:input label="Semester" type="number" wire:model="semester" min="1" />

            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button type="submit" variant="primary">Update Class</flux:button>
            </div>
        </form>
    </flux:modal>
</div>
