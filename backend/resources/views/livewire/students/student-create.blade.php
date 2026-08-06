<div class="space-y-6">
    <div>
        <flux:heading size="lg">Create New Student</flux:heading>
        <flux:subheading>Add a student profile with class and schedule details</flux:subheading>
    </div>

    <form wire:submit.prevent="save" class="space-y-6">

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">

            <flux:input wire:model="name"
                        label="Name"
                        placeholder="e.g. John Doe" />

            <flux:input wire:model="email"
                        type="email"
                        label="Email"
                        placeholder="e.g. john@example.com" />

            <flux:input wire:model="password"
                        type="password"
                        label="Password"
                        placeholder="Minimum 8 characters" />

            <flux:field>
                <flux:label>Gender</flux:label>
                <flux:select wire:model="gender" size="sm" placeholder="Select Gender">
                    <flux:select.option value="male">Male</flux:select.option>
                    <flux:select.option value="female">Female</flux:select.option>
                </flux:select>
                <flux:error name="gender" />
            </flux:field>

            <flux:input wire:model="dob"
                        type="date"
                        label="Date of Birth" />

            <flux:field>
                <flux:label>Faculty</flux:label>
                <flux:select wire:model.live="faculty_id" size="sm" placeholder="Select Faculty">
                    @foreach ($faculties as $faculty)
                        <flux:select.option value="{{ $faculty->id }}">{{ $faculty->name }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="faculty_id" />
            </flux:field>

            <flux:field>
                <flux:label>Major</flux:label>
                <flux:select wire:model.live="major_id" size="sm" placeholder="Select Major" :disabled="!$faculty_id">
                    @foreach ($majors as $major)
                        <flux:select.option value="{{ $major->id }}">{{ $major->name }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="major_id" />
            </flux:field>

            <flux:field>
                <flux:label>Academic Class</flux:label>
                <flux:select wire:model="academic_class_id" size="sm" placeholder="Select Class" :disabled="!$major_id">
                    @foreach ($academic_classes as $class)
                        <flux:select.option value="{{ $class->id }}">{{ $class->name }} ({{ $class->code }})</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="academic_class_id" />
            </flux:field>

            <flux:field>
                <flux:label>Year</flux:label>
                <flux:select wire:model="year" size="sm">
                    <flux:select.option value="">Select</flux:select.option>
                    <flux:select.option value="1">1</flux:select.option>
                    <flux:select.option value="2">2</flux:select.option>
                    <flux:select.option value="3">3</flux:select.option>
                    <flux:select.option value="4">4</flux:select.option>
                </flux:select>
                <flux:error name="year" />
            </flux:field>

            <flux:field>
                <flux:label>Shift</flux:label>
                <flux:select wire:model="shift_id" size="sm" placeholder="Select Shift">
                    @foreach($shifts as $shift)
                        <flux:select.option value="{{ $shift->id }}">{{ $shift->name }}</flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="shift_id" />
            </flux:field>

            <flux:field>
                <flux:label>Schedule Slot</flux:label>
                <flux:select wire:model="schedule_id" placeholder="Select Schedule" class="w-full">
                    @foreach($schedules as $schedule)
                        <flux:select.option value="{{ $schedule->id }}">
                            {{ $schedule->full_display }}
                        </flux:select.option>
                    @endforeach
                </flux:select>
                <flux:error name="schedule_id" />
            </flux:field>

            <flux:input wire:model="generation"
                        label="Generation"
                        placeholder="e.g. 10, 11" />

            <flux:field>
                <flux:label>Profile Photo</flux:label>
                <div class="flex items-center gap-4">
                    @if ($photo)
                        <img src="{{ $photo->temporaryUrl() }}" class="w-16 h-16 rounded-xl object-cover ring-1 ring-zinc-200 dark:ring-white/10">
                    @else
                        <div class="w-16 h-16 rounded-xl bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center ring-1 ring-zinc-200 dark:ring-white/10">
                            <flux:icon name="camera" class="w-6 h-6 text-zinc-400" />
                        </div>
                    @endif
                    <flux:input type="file" wire:model="photo" size="sm" />
                </div>
                <flux:error name="photo" />
            </flux:field>

        </div>

        {{-- Actions --}}
        <div class="flex justify-end gap-3 pt-4 border-t border-zinc-200 dark:border-white/10">
            <flux:button wire:click="$dispatch('closeModal')" variant="ghost">
                Cancel
            </flux:button>

            <flux:button type="submit" variant="primary">
                <span wire:loading.remove wire:target="save">Create Student</span>
                <span wire:loading wire:target="save">Saving...</span>
            </flux:button>
        </div>

    </form>
</div>
