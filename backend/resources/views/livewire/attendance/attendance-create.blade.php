<div>
    <x-slot name="header">
        <flux:heading size="xl">Create Attendance Session</flux:heading>
        <flux:subheading>Select a syllabus schedule to start a QR attendance session</flux:subheading>
    </x-slot>

    <div class="py-6">
        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-5">

            {{-- Flash Success --}}
            @if (session()->has('message'))
                <div class="flex items-center gap-3 p-4 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 rounded-xl text-green-700 dark:text-green-300 text-sm">
                    <svg class="w-5 h-5 shrink-0" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                    </svg>
                    {{ session('message') }}
                </div>
            @endif

            <form wire:submit.prevent="createSession" class="space-y-5">

                {{-- ── Step 1: Teacher ─────────────────────────────────────── --}}
                <div class="bg-white dark:bg-[#1e293b] rounded-xl border border-gray-200 dark:border-[rgba(255,255,255,0.08)] shadow-sm p-6 space-y-4">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="flex items-center justify-center w-6 h-6 rounded-full bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 text-xs font-bold">1</span>
                        <span class="text-sm font-semibold text-gray-700 dark:text-gray-300">Select Teacher</span>
                    </div>

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
                </div>

                {{-- ── Step 2: Syllabus / Class Schedule ───────────────────── --}}
                <div class="bg-white dark:bg-[#1e293b] rounded-xl border border-gray-200 dark:border-[rgba(255,255,255,0.08)] shadow-sm p-6 space-y-4"
                     x-data="{ open: @entangle('teacher_id') }">

                    <div class="flex items-center gap-2 mb-1">
                        <span class="flex items-center justify-center w-6 h-6 rounded-full
                            {{ $teacher_id ? 'bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300' : 'bg-gray-100 dark:bg-[#374151] text-gray-400 dark:text-gray-500' }}
                            text-xs font-bold">2</span>
                        <span class="text-sm font-semibold {{ $teacher_id ? 'text-gray-700 dark:text-gray-300' : 'text-gray-400 dark:text-gray-500' }}">
                            Select Class Schedule (Syllabus)
                        </span>
                    </div>

                    @if(!$teacher_id)
                        <div class="flex items-center gap-2 p-3 bg-gray-50 dark:bg-[#1e293b] rounded-lg border border-gray-100 dark:border-[rgba(255,255,255,0.08)] text-sm text-gray-400 dark:text-gray-500">
                            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            Please select a teacher first to see their scheduled classes.
                        </div>
                    @elseif($syllabuses->isEmpty())
                        <div class="flex items-center gap-2 p-3 bg-amber-50 dark:bg-amber-900/30 rounded-lg border border-amber-100 dark:border-amber-800 text-sm text-amber-600 dark:text-amber-400">
                            <svg class="w-4 h-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                            </svg>
                            No structured syllabus schedules found for this teacher.
                            Please add a syllabus with day and time in the
                            <a href="{{ route('syllabuses.index') }}" class="underline font-medium" wire:navigate>Syllabus page</a>.
                        </div>
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
                </div>

                {{-- ── Step 3: Auto-filled Class & Schedule Summary ─────────── --}}
                @if($selectedSyllabus)
                    <div class="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-xl border border-blue-200 dark:border-blue-800 shadow-sm overflow-hidden">

                        {{-- Header bar --}}
                        <div class="px-6 py-3 bg-blue-600 text-white flex items-center justify-between">
                            <div class="flex items-center gap-2">
                                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                          d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                                </svg>
                                <span class="text-sm font-semibold">Session Preview — Auto-filled from Syllabus</span>
                            </div>
                            <span class="text-xs bg-white/20 rounded-full px-2 py-0.5">
                                ID #{{ $selectedSyllabus->id }}
                            </span>
                        </div>

                        <div class="p-6">
                            {{-- 2-column info grid --}}
                            <div class="grid grid-cols-2 md:grid-cols-3 gap-4">

                                {{-- Subject --}}
                                <div class="bg-white dark:bg-[#1e293b] rounded-lg p-3 border border-blue-100 dark:border-blue-800 shadow-xs">
                                    <p class="text-xs text-gray-400 dark:text-gray-500 uppercase tracking-wide mb-1">Subject</p>
                                    <p class="text-sm font-semibold text-gray-800 dark:text-gray-200">
                                        {{ $selectedSyllabus->subject?->name ?? '—' }}
                                    </p>
                                    @if($selectedSyllabus->subject?->code)
                                        <p class="text-xs text-gray-400 dark:text-gray-500">{{ $selectedSyllabus->subject->code }}</p>
                                    @endif
                                </div>

                                {{-- Class --}}
                                <div class="bg-white dark:bg-[#1e293b] rounded-lg p-3 border border-blue-100 dark:border-blue-800 shadow-xs">
                                    <p class="text-xs text-gray-400 dark:text-gray-500 uppercase tracking-wide mb-1">Class Group</p>
                                    <p class="text-sm font-semibold text-gray-800 dark:text-gray-200">
                                        {{ $selectedSyllabus->major?->name ?? '—' }}
                                    </p>
                                    <p class="text-xs text-gray-400 dark:text-gray-500">
                                        {{ $selectedSyllabus->year_id }} · Semester {{ $selectedSyllabus->semester_id }}
                                    </p>
                                </div>

                                {{-- Faculty --}}
                                <div class="bg-white dark:bg-[#1e293b] rounded-lg p-3 border border-blue-100 dark:border-blue-800 shadow-xs">
                                    <p class="text-xs text-gray-400 dark:text-gray-500 uppercase tracking-wide mb-1">Faculty</p>
                                    <p class="text-sm font-semibold text-gray-800 dark:text-gray-200">
                                        {{ $selectedSyllabus->faculty?->name ?? '—' }}
                                    </p>
                                </div>

                                {{-- Day --}}
                                <div class="bg-white dark:bg-[#1e293b] rounded-lg p-3 border border-blue-100 dark:border-blue-800 shadow-xs">
                                    <p class="text-xs text-gray-400 dark:text-gray-500 uppercase tracking-wide mb-1">Day</p>
                                    <p class="text-sm font-semibold text-gray-800 dark:text-gray-200">
                                        {{ $selectedSyllabus->day_of_week ? ucfirst($selectedSyllabus->day_of_week) : '—' }}
                                    </p>
                                </div>

                                {{-- Time --}}
                                <div class="bg-white dark:bg-[#1e293b] rounded-lg p-3 border border-blue-100 dark:border-blue-800 shadow-xs">
                                    <p class="text-xs text-gray-400 dark:text-gray-500 uppercase tracking-wide mb-1">Time Slot</p>
                                    @if($selectedSyllabus->start_time && $selectedSyllabus->end_time)
                                        <p class="text-sm font-semibold text-gray-800 dark:text-gray-200">
                                            {{ \Carbon\Carbon::parse($selectedSyllabus->start_time)->format('H:i') }}
                                            –
                                            {{ \Carbon\Carbon::parse($selectedSyllabus->end_time)->format('H:i') }}
                                        </p>
                                    @else
                                        <p class="text-sm text-gray-400 dark:text-gray-500">Not set</p>
                                    @endif
                                </div>

                                {{-- Enrolled students --}}
                                <div class="bg-white dark:bg-[#1e293b] rounded-lg p-3 border border-blue-100 dark:border-blue-800 shadow-xs">
                                    <p class="text-xs text-gray-400 dark:text-gray-500 uppercase tracking-wide mb-1">Enrolled Students</p>
                                    <div class="flex items-baseline gap-1">
                                        <p class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ $enrolledStudents }}</p>
                                        <p class="text-xs text-gray-400 dark:text-gray-500">students</p>
                                    </div>
                                </div>

                            </div>

                            {{-- Shift badge if available --}}
                            @if($selectedSyllabus->shift)
                                <div class="mt-3 flex items-center gap-1.5">
                                    <span class="text-xs text-gray-400 dark:text-gray-500">Shift:</span>
                                    <span class="text-xs font-medium bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 px-2 py-0.5 rounded-full">
                                        {{ $selectedSyllabus->shift->name }}
                                    </span>
                                </div>
                            @endif
                        </div>
                    </div>
                @endif

                {{-- ── Step 4: Location ─────────────────────────────────────── --}}
                <div class="bg-white dark:bg-[#1e293b] rounded-xl border border-gray-200 dark:border-[rgba(255,255,255,0.08)] shadow-sm p-6 space-y-4">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="flex items-center justify-center w-6 h-6 rounded-full bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 text-xs font-bold">3</span>
                        <span class="text-sm font-semibold text-gray-700 dark:text-gray-300">Location (Check-in Radius)</span>
                    </div>

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
                        <flux:label>Room / Location Name</flux:label>
                        <flux:select wire:model="room_id" placeholder="— Select Room (Optional) —" class="w-full">
                            <flux:select.option value="">— Use default / No Room —</flux:select.option>
                            @foreach($rooms as $room)
                                <flux:select.option value="{{ $room->id }}">{{ $room->name }} ({{ $room->code }})</flux:select.option>
                            @endforeach
                        </flux:select>
                        <flux:error name="room_id" />
                    </flux:field>

                    <p class="text-xs text-gray-400 dark:text-gray-500 flex items-center gap-1">
                        <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                  d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                        </svg>
                        Students must be within range of this coordinate to check in via QR.
                    </p>
                </div>

                {{-- ── Submit ───────────────────────────────────────────────── --}}
                <div class="flex justify-end gap-3">
                    <flux:button href="{{ route('attendance.sessions.index') }}" variant="ghost" wire:navigate>
                        Cancel
                    </flux:button>
                    <flux:button
                        type="submit"
                        variant="primary"
                        :disabled="!$syllabus_id"
                        wire:loading.attr="disabled"
                        wire:target="createSession"
                    >
                        <span wire:loading.remove wire:target="createSession">
                            <span class="flex items-center gap-2">
                                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                          d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                          d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                </svg>
                                Start Session
                            </span>
                        </span>
                        <span wire:loading wire:target="createSession">Starting...</span>
                    </flux:button>
                </div>

            </form>
        </div>
    </div>
</div>
