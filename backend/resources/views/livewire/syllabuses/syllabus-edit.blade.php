<div class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-3xl max-h-[90vh] overflow-y-auto">

        {{-- Header --}}
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <flux:heading size="lg">Edit Syllabus Entry</flux:heading>
            <flux:button wire:click="closeModal"
                        variant="ghost"
                        size="sm"
                        icon="x-mark"
                        class="text-gray-400" />
        </div>

        {{-- Form --}}
        <form wire:submit.prevent="update" class="p-6 space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                
                <flux:field>
                    <flux:label>Faculty</flux:label>
                    <flux:select wire:model="faculty_id" placeholder="Select Faculty">
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

                <flux:input label="Schedule Info" wire:model="schedule_description" placeholder="e.g., Mon 07:30 - 10:30" />
            </div>

            <div class="flex justify-end gap-2 pt-4 border-t border-gray-100">
                <flux:button variant="ghost" wire:click="closeModal">Cancel</flux:button>
                <flux:button type="submit" variant="primary">
                    <span wire:loading.remove wire:target="update">Update Syllabus</span>
                    <span wire:loading wire:target="update">Saving...</span>
                </flux:button>
            </div>
        </form>
    </div>
</div>
