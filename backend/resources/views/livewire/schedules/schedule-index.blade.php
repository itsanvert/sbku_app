<div>
    <x-slot name="header">
        <flux:heading size="xl">Schedule Management</flux:heading>
        <flux:subheading>Manage reusable time slots for teachers and students</flux:subheading>
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
                        placeholder="Search schedules…" size="sm" class="w-64" />
                </div>

                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">
                    Add Schedule
                </flux:button>
            </div>

            {{-- Table --}}
            <flux:table :paginate="$this->schedules">
                <table class="w-full text-sm text-left">
                    <thead>
                        <tr class="border-b border-zinc-200 bg-zinc-50">
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Name</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Teacher / Subject</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Class / Room</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Day / Time</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Dates</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-zinc-400">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-zinc-100">
                        @forelse ($schedules as $schedule)
                            <tr class="hover:bg-zinc-50/70 transition-colors duration-100">
                                <td class="px-4 py-3 font-medium text-zinc-900">{{ $schedule->name }}</td>
                                <td class="px-4 py-3 text-sm">
                                    <div class="text-zinc-900 font-medium">{{ $schedule->teacher?->user?->name ?? '—' }}</div>
                                    <div class="text-zinc-500 text-xs">{{ $schedule->subject?->name ?? '—' }}</div>
                                </td>
                                <td class="px-4 py-3 text-sm">
                                    <div class="text-zinc-900">{{ $schedule->academicClass?->name ?? '—' }}</div>
                                    <div class="text-zinc-500 text-xs">{{ $schedule->room?->name ?? '—' }}</div>
                                </td>
                                <td class="px-4 py-3 text-sm text-zinc-500">
                                    <div>{{ $schedule->day_of_the_week ?? '—' }}</div>
                                    @if($schedule->start_time && $schedule->end_time)
                                        <div class="text-xs">{{ $schedule->time_range }}</div>
                                    @endif
                                </td>
                                <td class="px-4 py-3 text-sm text-zinc-500">
                                    @if($schedule->start_date && $schedule->end_date)
                                        <div class="text-xs">{{ $schedule->start_date->format('Y-m-d') }}</div>
                                        <div class="text-xs">to {{ $schedule->end_date->format('Y-m-d') }}</div>
                                    @else
                                        —
                                    @endif
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-2">
                                        <flux:button wire:click="edit('{{ $schedule->id }}')" size="xs" variant="ghost">Edit</flux:button>
                                        <flux:button wire:click="delete('{{ $schedule->id }}')" size="xs" variant="danger">Delete</flux:button>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="px-4 py-10 text-center text-zinc-500">No schedules found.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </flux:table>
        </div>
    </div>

    {{-- Create Modal --}}
    @if ($showCreateModal)
        <div class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-xl shadow-xl w-full max-w-md">
                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                    <flux:heading size="lg">Add New Schedule</flux:heading>
                    <flux:button wire:click="$set('showCreateModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="store" class="p-6 space-y-4">
                    <flux:input label="Schedule Name" wire:model="name" placeholder="e.g. Morning Shift A" />
                    
                    <div class="grid grid-cols-2 gap-4">
                        <flux:select label="Teacher" wire:model="teacher_id">
                            <flux:select.option value="">Select Teacher</flux:select.option>
                            @foreach($teachers as $teacher)
                                <flux:select.option value="{{ (string)$teacher->id }}">{{ $teacher->user?->name ?? $teacher->user_name ?? chr(8212) }}</flux:select.option>
                            @endforeach
                        </flux:select>

                        <flux:select label="Subject" wire:model="subject_id">
                            <flux:select.option value="">Select Subject</flux:select.option>
                            @foreach($subjects as $subject)
                                <flux:select.option value="{{ (string)$subject->id }}">{{ $subject->name }}</flux:select.option>
                            @endforeach
                        </flux:select>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:select label="Class" wire:model="class_id">
                            <flux:select.option value="">Select Class</flux:select.option>
                            @foreach($academicClasses as $class)
                                <flux:select.option value="{{ (string)$class->id }}">{{ $class->name }}</flux:select.option>
                            @endforeach
                        </flux:select>

                        <flux:select label="Room" wire:model="room_id">
                            <flux:select.option value="">Select Room</flux:select.option>
                            @foreach($rooms as $room)
                                <flux:select.option value="{{ (string)$room->id }}">{{ $room->name }} ({{ $room->code }})</flux:select.option>
                            @endforeach
                        </flux:select>
                    </div>

                    <flux:select label="Link to Syllabus" wire:model="syllabus_id" wire:change="onSyllabusChange">
                        <flux:select.option value="">None (Standalone Schedule)</flux:select.option>
                        @foreach($syllabuses as $syllabus)
                            <flux:select.option value="{{ (string)$syllabus->id }}">{{ $syllabus->subject_name ?? $syllabus->subject?->name ?? chr(8212) }}
                            </flux:select.option>
                        @endforeach
                    </flux:select>

                    <flux:select label="Day of the Week" wire:model="day_of_the_week">
                        <flux:select.option value="">Select Day</flux:select.option>
                        <flux:select.option value="Monday">Monday</flux:select.option>
                        <flux:select.option value="Tuesday">Tuesday</flux:select.option>
                        <flux:select.option value="Wednesday">Wednesday</flux:select.option>
                        <flux:select.option value="Thursday">Thursday</flux:select.option>
                        <flux:select.option value="Friday">Friday</flux:select.option>
                        <flux:select.option value="Saturday">Saturday</flux:select.option>
                        <flux:select.option value="Sunday">Sunday</flux:select.option>
                    </flux:select>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:input label="Start Time" type="time" wire:model="start_time" />
                        <flux:input label="End Time" type="time" wire:model="end_time" />
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:input label="Start Date" type="date" wire:model="start_date" />
                        <flux:input label="End Date" type="date" wire:model="end_date" />
                    </div>

                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showCreateModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Create Schedule</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif

    {{-- Edit Modal --}}
    @if ($showEditModal)
        <div class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div class="bg-white rounded-xl shadow-xl w-full max-w-md">
                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                    <flux:heading size="lg">Edit Schedule</flux:heading>
                    <flux:button wire:click="$set('showEditModal', false)" variant="ghost" size="sm" icon="x-mark" />
                </div>
                <form wire:submit.prevent="update" class="p-6 space-y-4">
                    <flux:input label="Schedule Name" wire:model="name" />
                    
                    <div class="grid grid-cols-2 gap-4">
                        <flux:select label="Teacher" wire:model="teacher_id">
                            <flux:select.option value="">Select Teacher</flux:select.option>
                            @foreach($teachers as $teacher)
                                <flux:select.option value="{{ (string)$teacher->id }}">{{ $teacher->user?->name ?? $teacher->user_name ?? chr(8212) }}</flux:select.option>
                            @endforeach
                        </flux:select>

                        <flux:select label="Subject" wire:model="subject_id">
                            <flux:select.option value="">Select Subject</flux:select.option>
                            @foreach($subjects as $subject)
                                <flux:select.option value="{{ (string)$subject->id }}">{{ $subject->name }}</flux:select.option>
                            @endforeach
                        </flux:select>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:select label="Class" wire:model="class_id">
                            <flux:select.option value="">Select Class</flux:select.option>
                            @foreach($academicClasses as $class)
                                <flux:select.option value="{{ (string)$class->id }}">{{ $class->name }}</flux:select.option>
                            @endforeach
                        </flux:select>

                        <flux:select label="Room" wire:model="room_id">
                            <flux:select.option value="">Select Room</flux:select.option>
                            @foreach($rooms as $room)
                                <flux:select.option value="{{ (string)$room->id }}">{{ $room->name }} ({{ $room->code }})</flux:select.option>
                            @endforeach
                        </flux:select>
                    </div>

                    <flux:select label="Link to Syllabus" wire:model="syllabus_id" wire:change="onSyllabusChange">
                        <flux:select.option value="">None (Standalone Schedule)</flux:select.option>
                        @foreach($syllabuses as $syllabus)
                            <flux:select.option value="{{ (string)$syllabus->id }}">{{ $syllabus->subject_name ?? $syllabus->subject?->name ?? chr(8212) }}
                            </flux:select.option>
                        @endforeach
                    </flux:select>

                    <flux:select label="Day of the Week" wire:model="day_of_the_week">
                        <flux:select.option value="Monday">Monday</flux:select.option>
                        <flux:select.option value="Tuesday">Tuesday</flux:select.option>
                        <flux:select.option value="Wednesday">Wednesday</flux:select.option>
                        <flux:select.option value="Thursday">Thursday</flux:select.option>
                        <flux:select.option value="Friday">Friday</flux:select.option>
                        <flux:select.option value="Saturday">Saturday</flux:select.option>
                        <flux:select.option value="Sunday">Sunday</flux:select.option>
                    </flux:select>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:input label="Start Time" type="time" wire:model="start_time" />
                        <flux:input label="End Time" type="time" wire:model="end_time" />
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:input label="Start Date" type="date" wire:model="start_date" />
                        <flux:input label="End Date" type="date" wire:model="end_date" />
                    </div>

                    <div class="flex justify-end gap-2 pt-4">
                        <flux:button variant="ghost" wire:click="$set('showEditModal', false)">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Update Schedule</flux:button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>

