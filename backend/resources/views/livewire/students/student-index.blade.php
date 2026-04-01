<div>
    <x-slot name="header">
        <flux:heading size="xl">Students</flux:heading>
        <flux:subheading>Manage students</flux:subheading>
    </x-slot>

    <div class="space-y-4">

            {{-- Flash Message --}}
            @if (session()->has('message'))
                <flux:callout variant="success" icon="check-circle" dismissible>
                    {{ session('message') }}
                </flux:callout>
            @endif

            <div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">

                {{-- Toolbar --}}
                <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-zinc-200">
                    <div class="flex items-center gap-2">
                        <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                            placeholder="Search students…" size="sm" class="w-52" />

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

                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                        Add Student
                    </flux:button>
                </div>

                {{-- Table --}}
                <flux:table :paginate="$this->students">
                    <table class="w-full text-sm text-left">
                        <colgroup>
                            <col class="w-10"> {{-- checkbox --}}
                            <col class="w-12"> {{-- # --}}
                            <col class="w-52"> {{-- name --}}
                            <col> {{-- email --}}
                            <col class="w-28"> {{-- major --}}
                            <col class="w-28"> {{-- faculty --}}
                            <col class="w-16"> {{-- year --}}
                            <col class="w-36"> {{-- schedule --}}
                            <col class="w-28"> {{-- phone --}}
                            <col class="w-28"> {{-- joined --}}
                            <col class="w-32"> {{-- actions --}}
                        </colgroup>
                        <thead>
                            <tr class="border-b border-zinc-200 bg-zinc-50">
                                <th class="px-4 py-3">
                                    <flux:checkbox wire:model.live="selectAll" />
                                </th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('id')">#</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('name')">Name</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('email')">Email</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('major_id')">Major</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('faculty_id')">Faculty</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('year')">Year</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('schedule')">Schedule</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('phone')">Phone</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none"
                                    wire:click="sort('created_at')">Joined</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">
                                    Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100">
                            @forelse ($this->students as $student)
                                <tr class="hover:bg-zinc-50/70 transition-colors duration-100">

                                    {{-- Checkbox --}}
                                    <td class="px-4 py-3">
                                        <flux:checkbox wire:model.live="selected" value="{{ $student->id }}" />
                                    </td>

                                    {{-- ID --}}
                                    <td class="px-4 py-3 tabular-nums text-xs text-zinc-400">
                                        {{ $student->id }}
                                    </td>

                                    {{-- Name --}}
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-2.5">
                                            <img class="h-7 w-7 rounded-lg object-cover ring-1 ring-zinc-200 shrink-0"
                                                src="{{ $student->profile_image_path ? asset('storage/' . $student->profile_image_path) : 'https://ui-avatars.com/api/?name=' . urlencode($student->name) . '&background=6366f1&color=ffffff&size=64&bold=true&font-size=0.4' }}"
                                                alt="{{ $student->name }}" />
                                            <span class="font-medium text-zinc-900 truncate">{{ $student->name }}</span>
                                        </div>
                                    </td>



                                    {{-- Email --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $student->user->email ?? '—' }}
                                    </td>

                                    {{-- Major --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $student->major->name ?? '—' }}
                                    </td>

                                    {{-- Faculty --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $student->faculty->name ?? '—' }}
                                    </td>

                                    {{-- Year --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $student->year ?? '—' }}
                                    </td>

                                    {{-- Schedule --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $student->schedule->day_of_the_week ?? '—' }}
                                    </td>

                                    {{-- Phone --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $student->phone ?? '—' }}
                                    </td>

                                    {{-- Joined --}}
                                    <td class="px-4 py-3 text-sm text-zinc-400">
                                        {{ $student->created_at?->format('M j, Y') ?? '—' }}
                                    </td>

                                    {{-- Actions --}}
                                    <td class="px-3 py-3">
                                        <div class="flex items-center gap-1.5">
                                            <flux:button wire:click="openEditModal({{ $student->id }})" size="sm"
                                                variant="ghost">Edit</flux:button>
                                            <flux:button wire:click="confirmDelete({{ $student->id }})" size="sm"
                                                variant="danger">Delete</flux:button>
                                        </div>
                                    </td>

                                </tr>
                            @empty
                                <tr>
                                    <td colspan="11" class="px-4 py-14 text-center">
                                        <div class="flex flex-col items-center gap-1.5 text-zinc-400">
                                            <flux:icon name="users" class="w-6 h-6 mb-0.5" />
                                            <p class="text-sm font-medium text-zinc-500">No students found</p>
                                            <p class="text-xs">Try adjusting your search or filters</p>
                                        </div>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </flux:table>

            </div>
    </div>

    {{-- Create Modal --}}
    @if ($showCreateModal)
        <livewire:students.student-create :key="'create'" />
    @endif

    {{-- Edit Modal --}}
    @if ($showEditModal && $editStudentId)
        <livewire:students.student-edit :studentId="$editStudentId" :key="'edit-' . $editStudentId" />
    @endif

    {{-- Delete Confirm Modal --}}
    <div>
        <flux:modal name="confirm-delete" class="min-w-[22rem] space-y-6">
            <div>
                <flux:heading size="lg">Delete this student?</flux:heading>
                <flux:subheading>This action cannot be undone. The student will be permanently removed.
                </flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteStudent" size="sm" variant="danger">Delete</flux:button>
            </div>
        </flux:modal>

        {{-- Bulk Delete Confirm Modal --}}
        <flux:modal name="confirm-bulk-delete" class="min-w-[22rem] space-y-6">
            <div>
                <flux:heading size="lg">Delete selected students?</flux:heading>
                <flux:subheading>This action cannot be undone. All selected students will be permanently removed.
                </flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteSelected" variant="danger" icon="trash">Delete Selected</flux:button>
            </div>
        </flux:modal>
    </div>

</div>
