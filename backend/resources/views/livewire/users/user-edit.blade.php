<div class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm flex items-center justify-center z-50 transition-opacity p-4">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-lg overflow-hidden" @click.outside="$wire.dispatch('closeModal')">
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <flux:heading size="lg">Edit User</flux:heading>
            <flux:button wire:click="$dispatch('closeModal')" variant="ghost" size="sm" icon="x-mark" class="text-gray-400" />
        </div>

        <form wire:submit="save" class="p-6 space-y-5">
            <flux:input wire:model="name" label="Full Name" placeholder="e.g. Jane Doe" />

            <flux:input wire:model="email" type="email" label="Email Address" placeholder="jane@example.com" />

            <flux:input wire:model="password" type="password" label="Password" placeholder="Minimum 8 characters" />

            <flux:select wire:model="role" label="Role Assignment">
                <flux:select.option value="">-- Select Role --</flux:select.option>
                <flux:select.option value="admin">Administrator (Full Access)</flux:select.option>
                <flux:select.option value="user">Standard User</flux:select.option>
            </flux:select>

            <div class="flex items-center justify-end gap-3 pt-4 mt-6 border-t border-gray-100">
                <flux:button wire:click="$dispatch('closeModal')" variant="ghost">Cancel</flux:button>
                <flux:button type="submit" variant="primary">
                    <span wire:loading.remove wire:target="save">Create</span>
                    <span wire:loading wire:target="save">Saving...</span>
                </flux:button>
            </div>
        </form>
    </div>
</div>
