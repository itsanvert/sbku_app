<div class="space-y-6">
    <div>
        <flux:heading size="lg">Add New Syllabus Entry</flux:heading>
        <flux:subheading>Add a curriculum entry with faculty, major, and schedule details</flux:subheading>
    </div>

    {{-- Conflict Alert --}}
    @if (!empty($conflictErrors))
        <flux:callout variant="danger" icon="exclamation-triangle" title="Scheduling Conflict Detected" dismissible>
            <ul class="list-disc list-inside space-y-1">
                @foreach ($conflictErrors as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </flux:callout>
    @endif

    <form wire:submit.prevent="store" class="space-y-6">

        {{-- Row 1: Faculty & Major --}}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <flux:field>
                <flux:label>Faculty</flux:label>
                <flux:select wire:model.live="faculty_id" placeholder="Select Faculty">
                    <flux:select.option value="">Select Faculty</flux:select.option>
                    @foreach($faculties as $f)
                        <flux:select.option value="{{ $f->id }}">{{ $f->name }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="faculty_id" />
            </flux:field>

            <flux:field>
                <flux:label>Major</flux:label>
                <flux:select wire:model="major_id" placeholder="Select Major">
                    <flux:select.option value="">Select Major</flux:select.option>
                    @foreach($majors as $m)
                        <flux:select.option value="{{ $m->id }}">{{ $m->name }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="major_id" />
            </flux:field>
        </div>

        {{-- Row 2: Subject & Teacher --}}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <flux:field>
                <flux:label>Subject</flux:label>
                <flux:select wire:model="subject_id" placeholder="Select Subject">
                    <flux:select.option value="">Select Subject</flux:select.option>
                    @foreach($subjects as $s)
                        <flux:select.option value="{{ $s->id }}">{{ $s->name }} ({{ $s->code }})</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="subject_id" />
            </flux:field>

            <flux:field>
                <flux:label>Teacher</flux:label>
                <flux:select wire:model="teacher_id" placeholder="Select Teacher">
                    <flux:select.option value="">Select Teacher</flux:select.option>
                    @foreach($teachers as $t)
                        <flux:select.option value="{{ $t->id }}">{{ $t->user->name ?? '—' }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="teacher_id" />
            </flux:field>
        </div>

        {{-- Row 3: Year, Semester, Shift, Room --}}
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <flux:field>
                <flux:label>Year</flux:label>
                <flux:select wire:model="year_id" placeholder="Select Year">
                    <flux:select.option value="">Select Year</flux:select.option>
                    @foreach($years as $id => $label)
                        <flux:select.option value="{{ $id }}">{{ $label }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="year_id" />
            </flux:field>

            <flux:field>
                <flux:label>Semester</flux:label>
                <flux:select wire:model="semester_id" placeholder="Select Semester">
                    <flux:select.option value="1">Semester 1</flux:select.option>
                    <flux:select.option value="2">Semester 2</flux:select.option>
                </flux:select>
                <flux:error name="semester_id" />
            </flux:field>

            <flux:field>
                <flux:label>Shift</flux:label>
                <flux:select wire:model="shift_id" placeholder="Select Shift">
                    <flux:select.option value="">Select Shift</flux:select.option>
                    @foreach($shifts as $sh)
                        <flux:select.option value="{{ $sh->id }}">{{ $sh->name }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="shift_id" />
            </flux:field>

            <flux:field>
                <flux:label>Room</flux:label>
                <flux:select wire:model="room_id" placeholder="Select Room">
                    <flux:select.option value="">Select Room</flux:select.option>
                    @foreach($rooms as $r)
                        <flux:select.option value="{{ $r->id }}">{{ $r->name }} ({{ $r->code }})</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="room_id" />
            </flux:field>
        </div>

        {{-- Scheduling Section --}}
        <div class="rounded-lg border border-zinc-200 dark:border-white/10 bg-zinc-50 dark:bg-zinc-800/50 p-4 space-y-4">
            <p class="text-sm font-semibold text-zinc-700 dark:text-zinc-300 flex items-center gap-2">
                <flux:icon name="calendar-days" class="w-4 h-4" />
                Schedule / Time Slot
            </p>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <flux:field>
                    <flux:label>Day of Week</flux:label>
                    <flux:select wire:model.live="day_of_week" placeholder="Select Day">
                        <flux:select.option value="">Select Day</flux:select.option>
                        @foreach($days as $val => $label)
                            <flux:select.option value="{{ $val }}">{{ $label }}</flux:select.option>
                        @endforeach
                    </flux:select>
                    <flux:error name="day_of_week" />
                </flux:field>

                <flux:field>
                    <flux:label>Start Time</flux:label>
                    <flux:input type="time" wire:model.live="start_time" />
                    <flux:error name="start_time" />
                </flux:field>

                <flux:field>
                    <flux:label>End Time</flux:label>
                    <flux:input type="time" wire:model.live="end_time" />
                    <flux:error name="end_time" />
                </flux:field>
            </div>

            {{-- Live conflict indicator --}}
            @if (!empty($conflictErrors))
                <p class="text-xs text-red-500 flex items-center gap-1">
                    <flux:icon name="exclamation-triangle" class="w-3.5 h-3.5" />
                    This time slot conflicts with an existing schedule.
                </p>
            @elseif ($teacher_id && $day_of_week && $start_time && $end_time)
                <p class="text-xs text-green-600 dark:text-green-400 flex items-center gap-1">
                    <flux:icon name="check-circle" class="w-3.5 h-3.5" />
                    No conflicts — time slot is available.
                </p>
            @endif
        </div>

        {{-- Optional schedule description (legacy/display) --}}
        <flux:input
            label="Schedule Notes (optional)"
            wire:model="schedule_description"
            placeholder="e.g., Lab session in Room 302"
        />

        {{-- Footer --}}
        <div class="flex justify-end gap-2 pt-4 border-t border-zinc-200 dark:border-white/10">
            <flux:button variant="ghost" wire:click="closeModal">Cancel</flux:button>
            <flux:button
                type="submit"
                variant="primary"
                :disabled="!empty($conflictErrors)"
            >
                <span wire:loading.remove wire:target="store">Create Syllabus</span>
                <span wire:loading wire:target="store">Saving...</span>
            </flux:button>
        </div>
    </form>
</div>
