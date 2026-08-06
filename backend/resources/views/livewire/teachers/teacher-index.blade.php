<div>
    <x-slot name="header">
        <flux:heading size="xl">Teachers</flux:heading>
        <flux:subheading>Manage faculty profiles, departments, and teaching assignments.</flux:subheading>
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
                        placeholder="Search teachers…" size="sm" class="w-56" />
                    @if(count($selected) > 0)
                        <flux:button wire:click="confirmBulkDelete" size="sm" variant="danger" icon="trash">
                            Delete ({{ count($selected) }})
                        </flux:button>
                    @endif
                </div>
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">Add Teacher</flux:button>
            </div>

            <flux:table :paginate="$this->teachers">
                <flux:table.columns>
                    <flux:table.column>
                        <flux:checkbox wire:model.live="selectAll" />
                    </flux:table.column>
                    <flux:table.column wire:click="sort('id')">#</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'name'" :direction="$sortDirection" wire:click="sort('name')">Name</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'email'" :direction="$sortDirection" wire:click="sort('email')">Email</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'major_id'" :direction="$sortDirection" wire:click="sort('major_id')">Major</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'faculty_id'" :direction="$sortDirection" wire:click="sort('faculty_id')">Faculty</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'year'" :direction="$sortDirection" wire:click="sort('year')">Year</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'schedule'" :direction="$sortDirection" wire:click="sort('schedule')">Schedule</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'shift'" :direction="$sortDirection" wire:click="sort('shift')">Shift</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'phone'" :direction="$sortDirection" wire:click="sort('phone')">Phone</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'created_at'" :direction="$sortDirection" wire:click="sort('created_at')">Joined</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($this->teachers as $teacher)
                        <flux:table.row :key="$teacher->id">
                            <flux:table.cell>
                                <flux:checkbox wire:model.live="selected" value="{{ $teacher->id }}" />
                            </flux:table.cell>
                            <flux:table.cell class="tabular-nums text-xs text-zinc-400 dark:text-zinc-500">{{ $teacher->id }}</flux:table.cell>
                            <flux:table.cell variant="strong">
                                <div class="flex items-center gap-3">
                                    <img class="w-8 h-8 rounded-full object-cover"
                                        src="{{ $teacher->profile_image_path ? asset('storage/' . $teacher->profile_image_path) : 'https://ui-avatars.com/api/?name=' . urlencode($teacher->name) . '&background=8b5cf6&color=ffffff&size=64&bold=true&font-size=0.4' }}"
                                        alt="{{ $teacher->name }}" />
                                    <div class="min-w-0">
                                        <div class="truncate">{{ $teacher->name }}</div>
                                        @if($teacher->shift)
                                            <div class="flex items-center gap-1 text-xs text-zinc-400 dark:text-zinc-500">
                                                <flux:icon name="clock" class="w-3 h-3" />
                                                {{ $teacher->shift->name }}
                                            </div>
                                        @endif
                                    </div>
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <span class="inline-flex items-center gap-1.5">
                                    <flux:icon name="envelope" class="w-3.5 h-3.5 text-zinc-300 dark:text-zinc-600" />
                                    {{ $teacher->user->email ?? '—' }}
                                </span>
                            </flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="zinc">{{ $teacher->major->name ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $teacher->faculty->name ?? '—' }}</flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="gray">Y{{ $teacher->year ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>
                                <div class="truncate max-w-[150px]" title="{{ $teacher->schedule->full_display ?? '—' }}">
                                    {{ $teacher->schedule->full_display ?? '—' }}
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="indigo">{{ $teacher->shift->name ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>
                                <span class="inline-flex items-center gap-1.5">
                                    <flux:icon name="phone" class="w-3.5 h-3.5 text-zinc-300 dark:text-zinc-600" />
                                    {{ $teacher->phone ?? '—' }}
                                </span>
                            </flux:table.cell>
                            <flux:table.cell class="text-zinc-400 dark:text-zinc-500">{{ $teacher->created_at?->format('M j, Y') ?? '—' }}</flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-1.5">
                                    <flux:button wire:click="openEditModal('{{ $teacher->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="confirmDelete('{{ $teacher->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="12">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="academic-cap" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No teachers found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new teacher.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Teacher</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>

    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-teacher" wire:model="showCreateModal" class="!max-w-2xl">
        @if ($showCreateModal)
            <livewire:teachers.teacher-create :key="'create'" />
        @endif
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-teacher" wire:model="showEditModal" class="!max-w-2xl">
        @if ($showEditModal && $editTeacherId)
            <livewire:teachers.teacher-edit :teacherId="$editTeacherId" :key="'edit-' . $editTeacherId" />
        @endif
    </flux:modal>

    {{-- Delete Confirm Modal --}}
    <flux:modal name="confirm-delete">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Delete this teacher?</flux:heading>
                <flux:subheading>This action cannot be undone. The teacher will be permanently removed.</flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteTeacher" size="sm" variant="danger">Delete</flux:button>
            </div>
        </div>
    </flux:modal>

    {{-- Bulk Delete Confirm Modal --}}
    <flux:modal name="confirm-bulk-delete">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Delete selected teachers?</flux:heading>
                <flux:subheading>This action cannot be undone. All selected teachers will be permanently removed.</flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteSelected" variant="danger" icon="trash">Delete Selected</flux:button>
            </div>
        </div>
    </flux:modal>
</div>
