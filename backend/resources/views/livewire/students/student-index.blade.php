<div>
    <x-slot name="header">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
            <div>
                <flux:heading size="xl">Students</flux:heading>
                <flux:subheading>Manage student records, academic information, enrollment, and class assignments.</flux:subheading>
            </div>
            <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">Add Student</flux:button>
        </div>
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
            <div class="flex flex-wrap items-center gap-2 mb-4">
                <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                    placeholder="Search students…" size="sm" class="w-56" />
                <flux:select wire:model.live="role" size="sm" class="w-36" placeholder="All Roles">
                    <flux:select.option value="">All Roles</flux:select.option>
                    <flux:select.option value="admin">Admin</flux:select.option>
                    <flux:select.option value="student">Student</flux:select.option>
                    <flux:select.option value="teacher">Teacher</flux:select.option>
                </flux:select>
                @if(count($selected) > 0)
                    <flux:button wire:click="confirmBulkDelete" size="sm" variant="danger" icon="trash">
                        Delete ({{ count($selected) }})
                    </flux:button>
                @endif
            </div>

            <flux:table :paginate="$this->students">
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
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'phone'" :direction="$sortDirection" wire:click="sort('phone')">Phone</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'created_at'" :direction="$sortDirection" wire:click="sort('created_at')">Joined</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($this->students as $student)
                        <flux:table.row :key="$student->id">
                            <flux:table.cell>
                                <flux:checkbox wire:model.live="selected" value="{{ $student->id }}" />
                            </flux:table.cell>
                            <flux:table.cell class="tabular-nums text-xs text-zinc-400 dark:text-zinc-500">{{ $student->id }}</flux:table.cell>
                            <flux:table.cell variant="strong">
                                <div class="flex items-center gap-3">
                                    <img class="w-8 h-8 rounded-full object-cover"
                                        src="{{ $student->profile_image_path ? asset('storage/' . $student->profile_image_path) : 'https://ui-avatars.com/api/?name=' . urlencode($student->name) . '&background=10b981&color=ffffff&size=64&bold=true&font-size=0.4' }}"
                                        alt="{{ $student->name }}" />
                                    <div class="min-w-0">
                                        <div class="truncate">{{ $student->name }}</div>
                                        @if($student->shift)
                                            <div class="flex items-center gap-1 text-xs text-zinc-400 dark:text-zinc-500">
                                                <flux:icon name="clock" class="w-3 h-3" />
                                                {{ $student->shift->name }}
                                            </div>
                                        @endif
                                    </div>
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <span class="inline-flex items-center gap-1.5">
                                    <flux:icon name="envelope" class="w-3.5 h-3.5 text-zinc-300 dark:text-zinc-600" />
                                    {{ $student->user->email ?? '—' }}
                                </span>
                            </flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="zinc">{{ $student->major->name ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>{{ $student->faculty->name ?? '—' }}</flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="emerald">Y{{ $student->year ?? '—' }}</flux:badge>
                            </flux:table.cell>
                            <flux:table.cell>
                                <div class="truncate max-w-[150px]" title="{{ $student->schedule->full_display ?? '—' }}">
                                    {{ $student->schedule->full_display ?? '—' }}
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <span class="inline-flex items-center gap-1.5">
                                    <flux:icon name="phone" class="w-3.5 h-3.5 text-zinc-300 dark:text-zinc-600" />
                                    {{ $student->phone ?? '—' }}
                                </span>
                            </flux:table.cell>
                            <flux:table.cell class="text-zinc-400 dark:text-zinc-500">{{ $student->created_at?->format('M j, Y') ?? '—' }}</flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-1.5">
                                    <flux:button wire:click="openEditModal('{{ $student->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="confirmDelete('{{ $student->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="11">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="users" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No students found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new student.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Student</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>

    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-student" wire:model="showCreateModal" class="!max-w-2xl">
        @if ($showCreateModal)
            <livewire:students.student-create :key="'create'" />
        @endif
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-student" wire:model="showEditModal" class="!max-w-2xl">
        @if ($showEditModal && $editStudentId)
            <livewire:students.student-edit :studentId="$editStudentId" :key="'edit-' . $editStudentId" />
        @endif
    </flux:modal>

    {{-- Delete Confirm Modal --}}
    <flux:modal name="confirm-delete">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Delete this student?</flux:heading>
                <flux:subheading>This action cannot be undone. The student will be permanently removed.</flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteStudent" size="sm" variant="danger">Delete</flux:button>
            </div>
        </div>
    </flux:modal>

    {{-- Bulk Delete Confirm Modal --}}
    <flux:modal name="confirm-bulk-delete">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Delete selected students?</flux:heading>
                <flux:subheading>This action cannot be undone. All selected students will be permanently removed.</flux:subheading>
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
