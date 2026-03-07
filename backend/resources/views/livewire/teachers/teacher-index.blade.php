<div>
    <x-slot name="header">
        <flux:heading size="xl">Teachers</flux:heading>
        <flux:subheading>Manage teachers</flux:subheading>
    </x-slot>

    <div class="py-6">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-4">

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
                        <flux:input
                            wire:model.live.debounce.300ms="search"
                            icon="magnifying-glass"
                            placeholder="Search teachers…"
                            size="sm"
                            class="w-52"
                        />
                        @if(count($selected) > 0)
                            <flux:button wire:click="confirmBulkDelete" size="sm" variant="danger" icon="trash">
                                Delete ({{ count($selected) }})
                            </flux:button>
                        @endif
                    </div>

                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                        Add Teacher
                    </flux:button>
                </div>

                {{-- Table --}}
                <flux:table :paginate="$this->teachers">
                    <table class="w-full text-sm text-left">
                        <colgroup>
                            <col class="w-10">    {{-- checkbox --}}
                            <col class="w-12">    {{-- # --}}
                            <col class="w-52">    {{-- name --}}
                            <col>                 {{-- email --}}
                            <col class="w-28">    {{-- major --}}
                            <col class="w-28">    {{-- faculty --}}
                            <col class="w-16">    {{-- year --}}
                            <col class="w-36">    {{-- schedule --}}
                            <col class="w-28">    {{-- phone --}}
                            <col class="w-28">    {{-- joined --}}
                            <col class="w-32">    {{-- actions --}}
                        </colgroup>
                        <thead>
                            <tr class="border-b border-zinc-200 bg-zinc-50">
                                <th class="px-4 py-3">
                                    <flux:checkbox wire:model.live="selectAll" />
                                </th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('id')">#</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('name')">Name</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('email')">Email</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('major_id')">Major</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('faculty_id')">Faculty</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('year')">Year</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('schedule')">Schedule</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('phone')">Phone</th>                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400 cursor-pointer hover:text-zinc-600 select-none" wire:click="sort('created_at')">Joined</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-zinc-100">
                            @forelse ($this->teachers as $teacher)
                                <tr class="hover:bg-zinc-50/70 transition-colors duration-100">

                                    {{-- Checkbox --}}
                                    <td class="px-4 py-3">
                                        <flux:checkbox wire:model.live="selected" value="{{ $teacher->id }}" />
                                    </td>

                                    {{-- ID --}}
                                    <td class="px-4 py-3 tabular-nums text-xs text-zinc-400">
                                        {{ $teacher->id }}
                                    </td>

                                    {{-- Name --}}
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-2.5">
                                            <img
                                                class="h-7 w-7 rounded-lg object-cover ring-1 ring-zinc-200 shrink-0"
                                                src="https://ui-avatars.com/api/?name={{ urlencode($teacher->name) }}&background=6366f1&color=ffffff&size=64&bold=true&font-size=0.4"
                                                alt="{{ $teacher->name }}"
                                            />
                                            <span class="font-medium text-zinc-900 truncate">{{ $teacher->name }}</span>
                                        </div>
                                    </td>



                                    {{-- Email --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $teacher->user->email ?? '—' }}
                                    </td>

                                    {{-- Major --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $teacher->major->name ?? '—' }}
                                    </td>

                                    {{-- Faculty --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $teacher->faculty->name ?? '—' }}
                                    </td>

                                    {{-- Year --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $teacher->year ?? '—' }}
                                    </td>

                                    {{-- Schedule --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $teacher->schedule->name ?? '—' }}
                                    </td>

                                    {{-- Phone --}}
                                    <td class="px-4 py-3 text-sm text-zinc-500">
                                        {{ $teacher->phone ?? '—' }}
                                    </td>

                                    {{-- Joined --}}
                                    <td class="px-4 py-3 text-sm text-zinc-400">
                                        {{ $teacher->created_at?->format('M j, Y') ?? '—' }}
                                    </td>

                                    {{-- Actions --}}
                                    <td class="px-3 py-3">
                                        <div class="flex items-center gap-1.5">
                                            <flux:button wire:click="openEditModal({{ $teacher->id }})" size="sm" variant="ghost">Edit</flux:button>
                                            <flux:button wire:click="confirmDelete({{ $teacher->id }})" size="sm" variant="danger">Delete</flux:button>
                                        </div>
                                    </td>

                                </tr>
                            @empty
                                <tr>
                                    <td colspan="11" class="px-4 py-14 text-center">
                                        <div class="flex flex-col items-center gap-1.5 text-zinc-400">
                                            <flux:icon name="users" class="w-6 h-6 mb-0.5" />
                                            <p class="text-sm font-medium text-zinc-500">No teachers found</p>
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
    </div>

    {{-- Create Modal --}}
    @if ($showCreateModal)
        <livewire:teachers.teacher-create :key="'create'" />
    @endif

    {{-- Edit Modal --}}
    @if ($showEditModal && $editTeacherId)
        <livewire:teachers.teacher-edit :teacherId="$editTeacherId" :key="'edit-'.$editTeacherId" />
    @endif

    {{-- Delete Confirm Modal --}}
    <div>
        <flux:modal name="confirm-delete" class="min-w-[22rem] space-y-6">
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
        </flux:modal>

        {{-- Bulk Delete Confirm Modal --}}
        <flux:modal name="confirm-bulk-delete" class="min-w-[22rem] space-y-6">
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
        </flux:modal>
    </div>

</div>
