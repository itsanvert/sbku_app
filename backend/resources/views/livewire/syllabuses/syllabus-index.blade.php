<div>
    <x-slot name="header">
        <flux:heading size="xl">Syllabus Management</flux:heading>
        <flux:subheading>Manage curriculum by Faculty, Major, and Year</flux:subheading>
    </x-slot>

    <div class="space-y-4">
        {{-- Flash Message --}}
        @if (session()->has('message'))
            <flux:callout variant="success" icon="check-circle" dismissible>
                {{ session('message') }}
            </flux:callout>
        @endif

        <div class="bg-white dark:bg-[#1e293b] rounded-xl border border-gray-200 dark:border-[rgba(255,255,255,0.08)] shadow-sm overflow-hidden">
            {{-- Toolbar --}}
            <div class="flex flex-wrap items-center justify-between gap-3 px-4 py-3 border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)]">
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

                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Syllabus Entry
                </flux:button>
            </div>

            {{-- Table --}}
            <flux:table :paginate="$this->syllabuses">
                <table class="w-full text-sm text-left">
                    <thead>
                        <tr class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] bg-gray-50 dark:bg-[#1e293b]">
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">#</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 cursor-pointer" wire:click="sort('subject_name')">Subject</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Faculty/Major</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Year/Sem</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Shift</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Teacher</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Schedule</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-[#374151]">
                        @forelse ($this->syllabuses as $syllabus)
                            <tr class="hover:bg-gray-50/70 dark:hover:bg-[#263548]/50 transition-colors duration-100">
                                <td class="px-4 py-3 tabular-nums text-xs text-gray-400 dark:text-gray-500">{{ $syllabus->id }}</td>
                                <td class="px-4 py-3 font-medium text-gray-900 dark:text-gray-50">{{ $syllabus->subject->name ?? '—' }}</td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                    <div class="flex flex-col">
                                        <span>{{ $syllabus->faculty->name ?? '—' }}</span>
                                        <span class="text-xs text-gray-400 dark:text-gray-500">{{ $syllabus->major->name ?? '—' }}</span>
                                    </div>
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                    {{ $syllabus->year_id }} - Sem {{ $syllabus->semester_id }}
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">{{ $syllabus->shift->name ?? '—' }}</td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">{{ $syllabus->teacher->user->name ?? '—' }}</td>
                                <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400 italic">{{ $syllabus->schedule_description }}</td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-2">
                                        <flux:button wire:click="openEditModal('{{ $syllabus->id }}')" size="xs" variant="ghost">Edit</flux:button>
                                        <flux:button wire:click="confirmDelete('{{ $syllabus->id }}')" size="xs" variant="danger">Delete</flux:button>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="8" class="px-4 py-10 text-center text-gray-500 dark:text-gray-400">No syllabus entries found.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </flux:table>
        </div>
    </div>

    {{-- Create Modal --}}
    @if ($showCreateModal)
        <livewire:syllabuses.syllabus-create :key="'create'" />
    @endif

    {{-- Edit Modal --}}
    @if ($showEditModal && $editSyllabusId)
        <livewire:syllabuses.syllabus-edit :syllabusId="$editSyllabusId" :key="'edit-' . $editSyllabusId" />
    @endif

    {{-- Delete Confirm Modal --}}
    <flux:modal name="confirm-delete-syllabus" class="min-w-[22rem] space-y-6">
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
    </flux:modal>
</div>
