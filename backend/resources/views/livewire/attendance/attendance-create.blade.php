<div>
    <x-slot name="header">
        <flux:heading size="xl">Create Attendance Session</flux:heading>
        <flux:subheading>Manually start a new QR attendance session</flux:subheading>
    </x-slot>

    <div class="py-6">
        <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 space-y-4">
            <div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden p-6 space-y-6">
                
                <form wire:submit.prevent="createSession" class="space-y-6">

                    <flux:field>
                        <flux:label>Teacher</flux:label>
                        <flux:select wire:model="teacher_id" placeholder="Select Teacher" class="w-full">
                            @foreach($teachers as $teacher)
                                <flux:select.option value="{{ $teacher->id }}">{{ $teacher->user->name ?? 'Unknown Teacher' }}</flux:select.option>
                            @endforeach
                        </flux:select>
                        <flux:error name="teacher_id" />
                    </flux:field>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:field>
                            <flux:label>Faculty</flux:label>
                            <flux:select wire:model="faculty_id" placeholder="Select Faculty" class="w-full">
                                @foreach($faculties as $faculty)
                                    <flux:select.option value="{{ $faculty->id }}">{{ $faculty->name }}</flux:select.option>
                                @endforeach
                            </flux:select>
                            <flux:error name="faculty_id" />
                        </flux:field>

                        <flux:field>
                            <flux:label>Major</flux:label>
                            <flux:select wire:model="major_id" placeholder="Select Major" class="w-full">
                                @foreach($majors as $major)
                                    <flux:select.option value="{{ $major->id }}">{{ $major->name }}</flux:select.option>
                                @endforeach
                            </flux:select>
                            <flux:error name="major_id" />
                        </flux:field>
                    </div>

                    <flux:field>
                        <flux:label>Schedule / Class</flux:label>
                        <flux:select wire:model="schedule_id" placeholder="Select Schedule" class="w-full">
                            @foreach($schedules as $schedule)
                                <flux:select.option value="{{ $schedule->id }}">{{ $schedule->name }}</flux:select.option>
                            @endforeach
                        </flux:select>
                        <flux:error name="schedule_id" />
                    </flux:field>

                    <div class="grid grid-cols-2 gap-4">
                        <flux:field>
                            <flux:label>Latitude</flux:label>
                            <flux:input wire:model="latitude" type="text" />
                            <flux:error name="latitude" />
                        </flux:field>

                        <flux:field>
                            <flux:label>Longitude</flux:label>
                            <flux:input wire:model="longitude" type="text" />
                            <flux:error name="longitude" />
                        </flux:field>
                    </div>

                    <div class="flex justify-end gap-3 mt-6">
                        <flux:button href="{{ route('attendance.sessions.index') }}" variant="ghost">Cancel</flux:button>
                        <flux:button type="submit" variant="primary">Start Session</flux:button>
                    </div>

                </form>

            </div>
        </div>
    </div>
</div>
