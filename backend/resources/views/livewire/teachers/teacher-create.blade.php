<div class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-3xl max-h-[90vh] overflow-y-auto">

        {{-- Header --}}
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <flux:heading size="lg">Create New Teacher</flux:heading>
            <flux:button wire:click="$dispatch('closeModal')"
                        variant="ghost"
                        size="sm"
                        icon="x-mark"
                        class="text-gray-400" />
        </div>

        {{-- Form --}}
        <form wire:submit.prevent="save" class="p-6 space-y-6">

            {{-- Account Info --}}
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">

                <flux:input wire:model="name"
                            label="Name"
                            placeholder="e.g. Jane Doe" />

                <flux:input wire:model="email"
                            type="email"
                            label="Email"
                            placeholder="e.g. jane@example.com" />

                <flux:input wire:model="password"
                            type="password"
                            label="Password"
                            placeholder="Minimum 8 characters" />

                <flux:field>
                    <flux:label>Gender</flux:label>
                    <flux:select wire:model="gender" size="sm">
                        <flux:select.option value="">Select</flux:select.option>
                        <flux:select.option value="male">Male</flux:select.option>
                        <flux:select.option value="female">Female</flux:select.option>
                    </flux:select>
                    <flux:error name="gender" />
                </flux:field>

                <flux:field>
                    <flux:label>Major</flux:label>
                    <flux:select wire:model="major_id" size="sm">
                        <flux:select.option value="">Select</flux:select.option>
                        @foreach ($majors as $major)
                            <flux:select.option value="{{ $major->id }}">{{ $major->name }}</flux:select.option>
                        @endforeach
                    </flux:select>
                    <flux:error name="major_id" />
                </flux:field>

                <flux:field>
                    <flux:label>Schedule</flux:label>
                    <flux:select wire:model="schedule_id" size="sm">
                        <flux:select.option value="">Select</flux:select.option>
                        @foreach ($schedules as $schedule)
                            <flux:select.option value="{{ $schedule->id }}">{{ $schedule->name }}</flux:select.option>
                        @endforeach
                    </flux:select>
                    <flux:error name="schedule_id" />
                </flux:field>


                 <flux:field>
                    <flux:label>Shift</flux:label>
                    <flux:select wire:model="shift_id" size="sm">
                        <flux:select.option value="">Select</flux:select.option>
                        @foreach ($shifts as $shift)
                            <flux:select.option value="{{ $shift->id }}">{{ $shift->name }}</flux:select.option>
                        @endforeach
                    </flux:select>
                    <flux:error name="shift_id" />
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

                <flux:input wire:model="phone"
                            label="Phone"
                            placeholder="123-456-7890" />

                <flux:field>
                    <flux:label>Faculty</flux:label>
                    <flux:select wire:model="faculty_id" size="sm">
                        <flux:select.option value="">Select</flux:select.option>
                        @foreach ($faculties as $faculty)
                            <flux:select.option value="{{ $faculty->id }}">{{ $faculty->name }}</flux:select.option>
                        @endforeach
                    </flux:select>
                    <flux:error name="faculty_id" />
                </flux:field>

                <flux:field>
                    <flux:label>Profile Photo</flux:label>
                    <div class="flex items-center gap-4">
                        @if ($photo)
                            <img src="{{ $photo->temporaryUrl() }}" class="w-16 h-16 rounded-lg object-cover ring-1 ring-zinc-200">
                        @else
                            <div class="w-16 h-16 rounded-lg bg-zinc-100 flex items-center justify-center ring-1 ring-zinc-200">
                                <flux:icon name="camera" class="w-6 h-6 text-zinc-400" />
                            </div>
                        @endif
                        <flux:input type="file" wire:model="photo" size="sm" />
                    </div>
                    <flux:error name="photo" />
                </flux:field>

            </div>

            {{-- Actions --}}
            <div class="flex justify-end gap-3 pt-4 border-t border-gray-100">
                <flux:button wire:click="$dispatch('closeModal')" variant="ghost">
                    Cancel
                </flux:button>

                <flux:button type="submit" variant="primary">
                    <span wire:loading.remove wire:target="save">Create Teacher</span>
                    <span wire:loading wire:target="save">Saving...</span>
                </flux:button>
            </div>

        </form>
    </div>
</div>
