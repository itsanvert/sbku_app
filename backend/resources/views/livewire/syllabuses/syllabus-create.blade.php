<div class="fixed inset-0 bg-gray-900/50 dark:bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white dark:bg-[#1e293b] rounded-xl shadow-xl w-full max-w-3xl max-h-[90vh] overflow-y-auto">

        {{-- Header --}}
        <div class="px-6 py-4 border-b border-gray-100 dark:border-[rgba(255,255,255,0.08)] flex items-center justify-between">
            <flux:heading size="lg">Add New Syllabus Entry</flux:heading>
            <flux:button wire:click="closeModal"
                        variant="ghost"
                        size="sm"
                        icon="x-mark"
                        class="text-gray-400 dark:text-gray-500" />
        </div>

        {{-- Conflict Alert --}}
        @if (!empty($conflictErrors))
            <div class="mx-6 mt-4 p-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg">
                <div class="flex items-start gap-3">
                    <svg class="w-5 h-5 text-red-500 mt-0.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                    </svg>
                    <div>
                        <p class="text-sm font-semibold text-red-700 dark:text-red-400 mb-1">Scheduling Conflict Detected</p>
                        <ul class="list-disc list-inside space-y-1">
                            @foreach ($conflictErrors as $error)
                                <li class="text-sm text-red-600 dark:text-red-400">{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            </div>
        @endif

        {{-- Form --}}
        <form wire:submit.prevent="store" class="p-6 space-y-6">

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

            {{-- ─── Scheduling Section ─────────────────────────────────────── --}}
            <div class="rounded-lg border border-blue-100 dark:border-blue-800 bg-blue-50/50 dark:bg-blue-900/20 p-4 space-y-4">
                <div class="flex items-center gap-2 mb-1">
                    <svg class="w-4 h-4 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                    <span class="text-sm font-semibold text-blue-700 dark:text-blue-400">Schedule / Time Slot</span>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {{-- Day of Week --}}
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

                    {{-- Start Time --}}
                    <flux:field>
                        <flux:label>Start Time</flux:label>
                        <input
                            type="time"
                            wire:model.live="start_time"
                            class="w-full rounded-lg border border-gray-300 dark:border-[rgba(255,255,255,0.08)] px-3 py-2 text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 dark:focus:border-blue-400 dark:focus:ring-blue-800 outline-none transition"
                        />
                        <flux:error name="start_time" />
                    </flux:field>

                    {{-- End Time --}}
                    <flux:field>
                        <flux:label>End Time</flux:label>
                        <input
                            type="time"
                            wire:model.live="end_time"
                            class="w-full rounded-lg border border-gray-300 dark:border-[rgba(255,255,255,0.08)] px-3 py-2 text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-200 dark:focus:border-blue-400 dark:focus:ring-blue-800 outline-none transition"
                        />
                        <flux:error name="end_time" />
                    </flux:field>
                </div>

                {{-- Live conflict indicator --}}
                @if (!empty($conflictErrors))
                    <p class="text-xs text-red-500 flex items-center gap-1">
                        <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 10A8 8 0 110 10a8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                        </svg>
                        This time slot conflicts with an existing schedule.
                    </p>
                @elseif ($teacher_id && $day_of_week && $start_time && $end_time)
                    <p class="text-xs text-green-600 dark:text-green-400 flex items-center gap-1">
                        <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                        </svg>
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
            <div class="flex justify-end gap-2 pt-4 border-t border-gray-100 dark:border-[rgba(255,255,255,0.08)]">
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
</div>
