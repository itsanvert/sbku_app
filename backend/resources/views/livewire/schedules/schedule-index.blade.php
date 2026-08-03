<div>
    <x-slot name="header">
        <flux:heading size="xl">Schedules</flux:heading>
        <flux:subheading>Create and manage course timetables and room allocations.</flux:subheading>
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
                <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                    placeholder="Search schedules…" size="sm" class="w-64" />
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">Add Schedule</flux:button>
            </div>

            <flux:table :paginate="$schedules">
                <flux:table.columns>
                    <flux:table.column>Name</flux:table.column>
                    <flux:table.column>Teacher / Subject</flux:table.column>
                    <flux:table.column>Class / Room</flux:table.column>
                    <flux:table.column>Day / Time</flux:table.column>
                    <flux:table.column>Dates</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($schedules as $schedule)
                        <flux:table.row :key="$schedule->id">
                            <flux:table.cell variant="strong">
                                <div class="flex items-center gap-3">
                                    <div class="w-8 h-8 rounded-lg bg-zinc-100 dark:bg-zinc-800 text-zinc-500 dark:text-zinc-400 flex items-center justify-center shrink-0">
                                        <flux:icon name="calendar-days" class="w-4 h-4" />
                                    </div>
                                    {{ $schedule->name }}
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <div class="text-sm font-medium text-zinc-800 dark:text-white">{{ $schedule->teacher?->user?->name ?? '—' }}</div>
                                <div class="flex items-center gap-1 text-xs text-zinc-400 dark:text-zinc-500">
                                    <flux:icon name="book-open" class="w-3 h-3" />
                                    {{ $schedule->subject?->name ?? '—' }}
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <div class="text-sm">{{ $schedule->academicClass?->name ?? '—' }}</div>
                                <div class="flex items-center gap-1 text-xs text-zinc-400 dark:text-zinc-500">
                                    <flux:icon name="building-office" class="w-3 h-3" />
                                    {{ $schedule->room?->name ?? '—' }}
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <flux:badge size="sm" color="indigo">{{ $schedule->day_of_the_week ?? '—' }}</flux:badge>
                                @if($schedule->start_time && $schedule->end_time)
                                    <div class="text-xs text-zinc-400 dark:text-zinc-500 mt-1">{{ $schedule->time_range }}</div>
                                @endif
                            </flux:table.cell>
                            <flux:table.cell>
                                @if($schedule->start_date && $schedule->end_date)
                                    <div class="text-xs text-zinc-400 dark:text-zinc-500">{{ $schedule->start_date->format('Y-m-d') }}</div>
                                    <div class="text-xs text-zinc-400 dark:text-zinc-500">to {{ $schedule->end_date->format('Y-m-d') }}</div>
                                @else
                                    —
                                @endif
                            </flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-1.5">
                                    <flux:button wire:click="edit('{{ $schedule->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="delete('{{ $schedule->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="6">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="calendar-days" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No schedules found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new schedule.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add Schedule</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>
    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-schedule" wire:model="showCreateModal" class="!max-w-2xl">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Add New Schedule</flux:heading>
                <flux:subheading>Create a reusable time slot</flux:subheading>
            </div>

            <form wire:submit.prevent="store" class="space-y-4">
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

                    <flux:select label="Room" wire:model="room_id" :disabled="$this->syllabusRoom ? true : false">
                        <flux:select.option value="">Select Room</flux:select.option>
                        @foreach($rooms as $room)
                            <flux:select.option value="{{ (string)$room->id }}">{{ $room->name }} ({{ $room->code }})</flux:select.option>
                        @endforeach
                    </flux:select>
                    @if($this->syllabusRoom)
                        <p class="text-xs text-zinc-500 dark:text-zinc-400 col-span-2 -mt-2">Room is set by the selected syllabus.</p>
                    @endif
                </div>

                <flux:select label="Link to Syllabus" wire:model.live="syllabus_id">
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
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-schedule" wire:model="showEditModal" class="!max-w-2xl">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Edit Schedule</flux:heading>
                <flux:subheading>Update time slot details</flux:subheading>
            </div>

            <form wire:submit.prevent="update" class="space-y-4">
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

                    <flux:select label="Room" wire:model="room_id" :disabled="$this->syllabusRoom ? true : false">
                        <flux:select.option value="">Select Room</flux:select.option>
                        @foreach($rooms as $room)
                            <flux:select.option value="{{ (string)$room->id }}">{{ $room->name }} ({{ $room->code }})</flux:select.option>
                        @endforeach
                    </flux:select>
                    @if($this->syllabusRoom)
                        <p class="text-xs text-zinc-500 dark:text-zinc-400 col-span-2 -mt-2">Room is set by the selected syllabus.</p>
                    @endif
                </div>

                <flux:select label="Link to Syllabus" wire:model.live="syllabus_id">
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
    </flux:modal>
</div>
