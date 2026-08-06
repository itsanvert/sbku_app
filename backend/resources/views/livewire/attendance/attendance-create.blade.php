<div>
    <x-slot name="header">
        <flux:heading size="xl">Create Attendance Session</flux:heading>
        <flux:subheading>Select a syllabus schedule to start a QR attendance session</flux:subheading>
    </x-slot>

    <div class="py-6">
        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-5">

            {{-- Flash Success --}}
            @if (session()->has('message'))
                <flux:callout variant="success" icon="check-circle" dismissible>
                    {{ session('message') }}
                </flux:callout>
            @endif

            <form wire:submit.prevent="createSession" class="space-y-5">

                {{-- Step 1: Teacher --}}
                <flux:card class="space-y-4">
                    <p class="flex items-center gap-2 text-sm font-semibold">
                        <span class="flex items-center justify-center w-6 h-6 rounded-full bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 text-xs font-bold">1</span>
                        Select Teacher
                    </p>

                    <flux:field>
                        <flux:label>Teacher</flux:label>
                        <flux:select wire:model.live="teacher_id" placeholder="— Choose a teacher —" class="w-full">
                            <flux:select.option value="">— Choose a teacher —</flux:select.option>
                            @foreach($teachers as $teacher)
                                <flux:select.option value="{{ $teacher->id }}">
                                    {{ $teacher->user->name ?? 'Unknown' }}
                                    @if($teacher->major)
                                        · {{ $teacher->major->name }}
                                    @endif
                                </flux:select.option>
                            @endforeach
                        </flux:select>
                        <flux:error name="teacher_id" />
                    </flux:field>
                </flux:card>

                {{-- Step 2: Syllabus / Class Schedule --}}
                <flux:card class="space-y-4">
                    <p class="flex items-center gap-2 text-sm font-semibold {{ $teacher_id ? '' : 'text-zinc-400 dark:text-zinc-500' }}">
                        <span class="flex items-center justify-center w-6 h-6 rounded-full
                            {{ $teacher_id ? 'bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300' : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-400 dark:text-zinc-500' }}
                            text-xs font-bold">2</span>
                        Select Class Schedule (Syllabus)
                    </p>

                    @if(!$teacher_id)
                        <flux:callout variant="secondary" icon="information-circle">
                            Please select a teacher first to see their scheduled classes.
                        </flux:callout>
                    @elseif($syllabuses->isEmpty())
                        <flux:callout variant="warning" icon="exclamation-triangle">
                            No structured syllabus schedules found for this teacher. Please add a syllabus with day and time in the
                            <a href="{{ route('syllabuses.index') }}" class="underline font-medium" wire:navigate>Syllabus page</a>.
                        </flux:callout>
                    @else
                        <flux:field>
                            <flux:label>Class Schedule</flux:label>
                            <flux:select wire:model.live="syllabus_id" placeholder="— Choose a class —" class="w-full">
                                <flux:select.option value="">— Choose a class —</flux:select.option>
                                @foreach($syllabuses as $syl)
                                    <flux:select.option value="{{ $syl->id }}">
                                        {{ ucfirst($syl->day_of_week) }}
                                        @if($syl->start_time && $syl->end_time)
                                            · {{ \Carbon\Carbon::parse($syl->start_time)->format('H:i') }}–{{ \Carbon\Carbon::parse($syl->end_time)->format('H:i') }}
                                        @endif
                                        · {{ $syl->subject?->name ?? 'No Subject' }}
                                        ({{ $syl->major?->name ?? '?' }} · {{ $syl->year_id }} Sem {{ $syl->semester_id }})
                                    </flux:select.option>
                                @endforeach
                            </flux:select>
                            <flux:error name="syllabus_id" />
                        </flux:field>
                    @endif
                </flux:card>

                {{-- Step 3: Auto-filled Class & Schedule Summary --}}
                @if($selectedSyllabus)
                    <flux:card class="space-y-4">
                        <div class="flex items-center justify-between border-b border-zinc-200 dark:border-white/10 pb-3">
                            <p class="flex items-center gap-2 text-sm font-semibold">
                                <flux:icon name="clipboard-document-list" class="w-4 h-4" />
                                Session Preview — Auto-filled from Syllabus
                            </p>
                            <flux:badge size="sm" color="zinc">ID #{{ $selectedSyllabus->id }}</flux:badge>
                        </div>

                        <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                            <div class="rounded-lg border border-zinc-200 dark:border-white/10 p-3">
                                <p class="text-xs text-zinc-400 dark:text-zinc-500 uppercase tracking-wide mb-1">Subject</p>
                                <p class="text-sm font-semibold">{{ $selectedSyllabus->subject?->name ?? '—' }}</p>
                                @if($selectedSyllabus->subject?->code)
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">{{ $selectedSyllabus->subject->code }}</p>
                                @endif
                            </div>

                            <div class="rounded-lg border border-zinc-200 dark:border-white/10 p-3">
                                <p class="text-xs text-zinc-400 dark:text-zinc-500 uppercase tracking-wide mb-1">Class Group</p>
                                <p class="text-sm font-semibold">{{ $selectedSyllabus->major?->name ?? '—' }}</p>
                                <p class="text-xs text-zinc-400 dark:text-zinc-500">
                                    {{ $selectedSyllabus->year_id }} · Semester {{ $selectedSyllabus->semester_id }}
                                </p>
                            </div>

                            <div class="rounded-lg border border-zinc-200 dark:border-white/10 p-3">
                                <p class="text-xs text-zinc-400 dark:text-zinc-500 uppercase tracking-wide mb-1">Faculty</p>
                                <p class="text-sm font-semibold">{{ $selectedSyllabus->faculty?->name ?? '—' }}</p>
                            </div>

                            <div class="rounded-lg border border-zinc-200 dark:border-white/10 p-3">
                                <p class="text-xs text-zinc-400 dark:text-zinc-500 uppercase tracking-wide mb-1">Day</p>
                                <p class="text-sm font-semibold">{{ $selectedSyllabus->day_of_week ? ucfirst($selectedSyllabus->day_of_week) : '—' }}</p>
                            </div>

                            <div class="rounded-lg border border-zinc-200 dark:border-white/10 p-3">
                                <p class="text-xs text-zinc-400 dark:text-zinc-500 uppercase tracking-wide mb-1">Time Slot</p>
                                @if($selectedSyllabus->start_time && $selectedSyllabus->end_time)
                                    <p class="text-sm font-semibold">
                                        {{ \Carbon\Carbon::parse($selectedSyllabus->start_time)->format('H:i') }}
                                        –
                                        {{ \Carbon\Carbon::parse($selectedSyllabus->end_time)->format('H:i') }}
                                    </p>
                                @else
                                    <p class="text-sm text-zinc-400 dark:text-zinc-500">Not set</p>
                                @endif
                            </div>

                            <div class="rounded-lg border border-zinc-200 dark:border-white/10 p-3">
                                <p class="text-xs text-zinc-400 dark:text-zinc-500 uppercase tracking-wide mb-1">Enrolled Students</p>
                                <div class="flex items-baseline gap-1">
                                    <p class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ $enrolledStudents }}</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">students</p>
                                </div>
                            </div>
                        </div>

                        @if($selectedSyllabus->shift)
                            <div class="flex items-center gap-1.5">
                                <span class="text-xs text-zinc-400 dark:text-zinc-500">Shift:</span>
                                <flux:badge size="sm" color="blue">{{ $selectedSyllabus->shift->name }}</flux:badge>
                            </div>
                        @endif
                    </flux:card>
                @endif

                {{-- Step 4: Location --}}
                <flux:card class="space-y-4">
                    <p class="flex items-center gap-2 text-sm font-semibold">
                        <span class="flex items-center justify-center w-6 h-6 rounded-full bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 text-xs font-bold">3</span>
                        Location (Check-in Radius)
                    </p>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:field>
                            <flux:label>Latitude</flux:label>
                            <flux:input wire:model="latitude" type="text" placeholder="e.g. 11.5564" />
                            <flux:error name="latitude" />
                        </flux:field>

                        <flux:field>
                            <flux:label>Longitude</flux:label>
                            <flux:input wire:model="longitude" type="text" placeholder="e.g. 104.9282" />
                            <flux:error name="longitude" />
                        </flux:field>
                    </div>

                    <flux:field>
                        <flux:label>Check-in Radius (meters)</flux:label>
                        <flux:input wire:model="radius" type="number" min="1" placeholder="e.g. 100 (default)" />
                        <flux:error name="radius" />
                        <flux:description>Students must be within this distance (meters) of the coordinate above to check in. Leave empty to use the default.</flux:description>
                    </flux:field>

                    <flux:field>
                        <flux:label>Room / Location Name</flux:label>
                        <flux:select wire:model="room_id" placeholder="— Select Room (Optional) —" class="w-full">
                            <flux:select.option value="">— Use default / No Room —</flux:select.option>
                            @foreach($rooms as $room)
                                <flux:select.option value="{{ $room->id }}">{{ $room->name }} ({{ $room->code }})</flux:select.option>
                            @endforeach
                        </flux:select>
                        <flux:error name="room_id" />
                    </flux:field>

                    <p class="text-xs text-zinc-400 dark:text-zinc-500 flex items-center gap-1">
                        <flux:icon name="map-pin" class="w-3.5 h-3.5" />
                        Students must be within range of this coordinate to check in via QR.
                    </p>
                </flux:card>

                {{-- Submit --}}
                <div class="flex justify-end gap-3">
                    <flux:button href="{{ route('attendance.sessions.index') }}" variant="ghost" wire:navigate>
                        Cancel
                    </flux:button>
                    <flux:button
                        type="submit"
                        variant="primary"
                        icon="play"
                        :disabled="!$syllabus_id"
                        wire:loading.attr="disabled"
                        wire:target="createSession"
                    >
                        <span wire:loading.remove wire:target="createSession">Start Session</span>
                        <span wire:loading wire:target="createSession">Starting...</span>
                    </flux:button>
                </div>

            </form>
        </div>
    </div>
</div>
