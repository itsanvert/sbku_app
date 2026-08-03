<div>
    <x-slot name="header">
        <flux:heading size="xl">Syllabuses</flux:heading>
        <flux:subheading>Manage curriculum, subjects, and academic programs.</flux:subheading>
    </x-slot>

    <div class="space-y-4">
        {{-- Flash Message --}}
        @if (session()->has('message'))
            <flux:callout variant="success" icon="check-circle" dismissible>
                {{ session('message') }}
            </flux:callout>
        @endif

        <flux:card>
            {{-- Toolbar --}}
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                <div class="flex flex-wrap items-center gap-2">
                    <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                        placeholder="Search Subjects…" size="sm" class="w-52" />
                    <flux:select wire:model.live="faculty_id" size="sm" class="w-44" placeholder="All Faculties">
                        <flux:select.option value="">All Faculties</flux:select.option>
                        @foreach($faculties as $f)
                            <flux:select.option value="{{ (string)$f->id }}">{{ $f->name }}</flux:select.option>
                        @endforeach
                    </flux:select>
                    <flux:select wire:model.live="year_id" size="sm" class="w-32" placeholder="All Years">
                        <flux:select.option value="">All Years</flux:select.option>
                        <flux:select.option value="Y1">Year 1</flux:select.option>
                        <flux:select.option value="Y2">Year 2</flux:select.option>
                        <flux:select.option value="Y3">Year 3</flux:select.option>
                        <flux:select.option value="Y4">Year 4</flux:select.option>
                        <flux:select.option value="Y5">Year 5</flux:select.option>
                    </flux:select>
                </div>
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">Add Syllabus Entry</flux:button>
            </div>

            <flux:table :paginate="$this->syllabuses">
                <flux:table.columns>
                    <flux:table.column>#</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'subject_name'" :direction="$sortDirection" wire:click="sort('subject_name')">Subject</flux:table.column>
                    <flux:table.column>Faculty/Major</flux:table.column>
                    <flux:table.column>Year/Sem</flux:table.column>
                    <flux:table.column>Shift</flux:table.column>
                    <flux:table.column>Teacher</flux:table.column>
                    <flux:table.column>Schedule</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($this->syllabuses as $syllabus)
                        <flux:table.row :key="$syllabus->id">
                            <flux:table.cell class="tabular-nums text-xs text-zinc-400 dark:text-zinc-500">{{ $syllabus->id }}</flux:table.cell>
                            <flux:table.cell variant="strong">{{ $syllabus->subject->name ?? '—' }}</flux:table.cell>
                            <flux:table.cell>
                                <div class="flex flex-col">
                                    <span>{{ $syllabus->faculty->name ?? '—' }}</span>
                                    <span class="text-xs text-zinc-400 dark:text-zinc-500">{{ $syllabus->major->name ?? '—' }}</span>
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="zinc">{{ $syllabus->year_id }} · Sem {{ $syllabus->semester_id }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="indigo">{{ $syllabus->shift->name ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $syllabus->teacher->user->name ?? '—' }}</flux:table.cell>
                            <flux:table.cell class="italic text-zinc-400 dark:text-zinc-500">{{ $syllabus->schedule_description }}</flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-1.5">
                                    <flux:button wire:click="openEditModal('{{ $syllabus->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="confirmDelete('{{ $syllabus->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="8">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="book-open" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No syllabus entries found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your filters or add a new syllabus entry.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Syllabus Entry</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-syllabus" wire:model="showCreateModal" class="!max-w-2xl">
        @if ($showCreateModal)
            <livewire:syllabuses.syllabus-create :key="'create'" />
        @endif
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-syllabus" wire:model="showEditModal" class="!max-w-2xl">
        @if ($showEditModal && $editSyllabusId)
            <livewire:syllabuses.syllabus-edit :syllabusId="$editSyllabusId" :key="'edit-' . $editSyllabusId" />
        @endif
    </flux:modal>

    {{-- Delete Confirm Modal --}}
    <flux:modal name="confirm-delete-syllabus">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Delete this syllabus entry?</flux:heading>
                <flux:subheading>This action cannot be undone.</flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteSyllabus" size="sm" variant="danger">Delete</flux:button>
            </div>
        </div>
    </flux:modal>
</div>
