<div class="space-y-6">
    <div>
        <flux:heading size="lg">Edit User</flux:heading>
        <flux:subheading>Update account details and role</flux:subheading>
    </div>

    <form wire:submit="save" class="space-y-5">
        <flux:input wire:model="name" label="Name" placeholder="e.g. Jane Doe" />
        <flux:input wire:model="email" type="email" label="Email Address" placeholder="jane@example.com" />
        <flux:input wire:model="password" type="password" label="Password" placeholder="Leave blank to keep current" />

        <flux:select wire:model="role" label="Role Assignment">
            <flux:select.option value="">-- Select Role --</flux:select.option>
            <flux:select.option value="super_admin">Super Admin (Full Access)</flux:select.option>
            <flux:select.option value="admin">Admin (Staff)</flux:select.option>
            <flux:select.option value="student">Student</flux:select.option>
            <flux:select.option value="teacher">Teacher</flux:select.option>
        </flux:select>

        <div class="flex items-center justify-end gap-3 pt-4 mt-6 border-t border-zinc-200 dark:border-white/10">
            <flux:button wire:click="$dispatch('closeModal')" variant="ghost">Cancel</flux:button>
            <flux:button type="submit" variant="primary">
                <span wire:loading.remove wire:target="save">Update User</span>
                <span wire:loading wire:target="save">Saving...</span>
            </flux:button>
        </div>
    </form>
</div>
