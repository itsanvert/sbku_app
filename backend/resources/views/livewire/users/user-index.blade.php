<div>
    <x-slot name="header">
        <flux:heading size="xl">Users</flux:heading>
        <flux:subheading>Manage system users, roles, and account access.</flux:subheading>
    </x-slot>

    <div class="space-y-4">

        {{-- Flash Message --}}
        @if (session()->has('message'))
            <flux:callout variant="success" icon="check-circle" dismissible>
                {{ session('message') }}
            </flux:callout>
        @endif

        <flux:card>
            {{-- Toolbar --}}
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                <div class="flex flex-wrap items-center gap-2">
                    <flux:input wire:model.live.debounce.300ms="search" icon="magnifying-glass"
                        placeholder="Search users…" size="sm" class="w-56" />
                    <flux:select wire:model.live="role" size="sm" class="w-40">
                        <flux:select.option value="">All Roles</flux:select.option>
                        <flux:select.option value="super_admin">Super Admin</flux:select.option>
                        <flux:select.option value="admin">Admin</flux:select.option>
                        <flux:select.option value="teacher">Teacher</flux:select.option>
                        <flux:select.option value="student">Student</flux:select.option>
                    </flux:select>
                    @if(count($selected) > 0)
                        <flux:button wire:click="confirmBulkDelete" size="sm" variant="danger" icon="trash">
                            Delete ({{ count($selected) }})
                        </flux:button>
                    @endif
                </div>
                <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus">Add User</flux:button>
            </div>

            <flux:table :paginate="$this->users">
                <flux:table.columns>
                    <flux:table.column>
                        <flux:checkbox wire:model.live="selectAll" />
                    </flux:table.column>
                    <flux:table.column wire:click="sort('id')">#</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'name'" :direction="$sortDirection" wire:click="sort('name')">Name</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'email'" :direction="$sortDirection" wire:click="sort('email')">Email</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'role'" :direction="$sortDirection" wire:click="sort('role')">Role</flux:table.column>
                    <flux:table.column :sortable="true" :sorted="$sortBy === 'created_at'" :direction="$sortDirection" wire:click="sort('created_at')">Joined</flux:table.column>
                    <flux:table.column align="end">Actions</flux:table.column>
                </flux:table.columns>

                <flux:table.rows>
                    @forelse ($this->users as $user)
                        <flux:table.row :key="$user->id">
                            <flux:table.cell>
                                <flux:checkbox wire:model.live="selected" value="{{ $user->id }}" />
                            </flux:table.cell>
                            <flux:table.cell class="tabular-nums text-xs text-zinc-400 dark:text-zinc-500">{{ $user->id }}</flux:table.cell>
                            <flux:table.cell variant="strong">
                                <div class="flex items-center gap-3">
                                    <img class="w-8 h-8 rounded-full object-cover"
                                        src="{{ $user->profile_photo_url }}"
                                        alt="{{ $user->name }}" />
                                    <div class="min-w-0">
                                        <div class="truncate">{{ $user->name }}</div>
                                        @if($user->role === 'super_admin')
                                            <div class="text-xs text-zinc-400 dark:text-zinc-500">Full system access</div>
                                        @endif
                                    </div>
                                </div>
                            </flux:table.cell>
                            <flux:table.cell>
                                <span class="inline-flex items-center gap-1.5">
                                    <flux:icon name="envelope" class="w-3.5 h-3.5 text-zinc-300 dark:text-zinc-600" />
                                    {{ $user->email }}
                                </span>
                            </flux:table.cell>
                            <flux:table.cell>
                                @if($user->role === 'super_admin')
                                    <flux:badge color="red" variant="solid" size="sm">Super Admin</flux:badge>
                                @elseif($user->role === 'admin')
                                    <flux:badge color="orange" size="sm">Admin</flux:badge>
                                @elseif($user->role === 'teacher')
                                    <flux:badge color="green" size="sm">Teacher</flux:badge>
                                @elseif($user->role === 'student')
                                    <flux:badge color="yellow" size="sm">Student</flux:badge>
                                @else
                                    <flux:badge color="blue" size="sm">{{ ucfirst($user->role ?? 'User') }}</flux:badge>
                                @endif
                            </flux:table.cell>
                            <flux:table.cell class="text-zinc-400 dark:text-zinc-500">
                                <span class="inline-flex items-center gap-1.5">
                                    <flux:icon name="calendar" class="w-3.5 h-3.5 text-zinc-300 dark:text-zinc-600" />
                                    {{ $user->created_at?->format('M j, Y') ?? '—' }}
                                </span>
                            </flux:table.cell>
                            <flux:table.cell align="end">
                                <div class="flex justify-end gap-1.5">
                                    <flux:button wire:click="openEditModal('{{ $user->id }}')" size="sm" variant="ghost" icon="pencil-square">Edit</flux:button>
                                    <flux:button wire:click="confirmDelete('{{ $user->id }}')" size="sm" variant="danger" icon="trash">Delete</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @empty
                        <flux:table.row>
                            <flux:table.cell colspan="7">
                                <div class="flex flex-col items-center justify-center gap-2 py-12 text-center">
                                    <flux:icon name="users" class="w-10 h-10 text-zinc-300 dark:text-zinc-600" />
                                    <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">No users found</p>
                                    <p class="text-xs text-zinc-400 dark:text-zinc-500">Try adjusting your search or create a new user.</p>
                                    <flux:button wire:click="openCreateModal" size="sm" variant="primary" icon="plus" class="mt-2">Add User</flux:button>
                                </div>
                            </flux:table.cell>
                        </flux:table.row>
                    @endforelse
                </flux:table.rows>
            </flux:table>
        </flux:card>

    </div>

    {{-- Create Modal --}}
    <flux:modal name="create-user" wire:model="showCreateModal">
        @if ($showCreateModal)
            <livewire:users.user-create :key="'create'" />
        @endif
    </flux:modal>

    {{-- Edit Modal --}}
    <flux:modal name="edit-user" wire:model="showEditModal">
        @if ($showEditModal && $editUserId)
            <livewire:users.user-edit :userId="$editUserId" :key="'edit-'.$editUserId" />
        @endif
    </flux:modal>

    {{-- Delete Confirm Modal --}}
    <flux:modal name="confirm-delete">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Delete this user?</flux:heading>
                <flux:subheading>This action cannot be undone. The user will be permanently removed.</flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteUser" size="sm" variant="danger">Delete</flux:button>
            </div>
        </div>
    </flux:modal>

    {{-- Bulk Delete Confirm Modal --}}
    <flux:modal name="confirm-bulk-delete">
        <div class="space-y-6">
            <div>
                <flux:heading size="lg">Delete selected users?</flux:heading>
                <flux:subheading>This action cannot be undone. All selected users will be permanently removed.</flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
                <flux:button wire:click="deleteSelected" variant="danger" icon="trash">Delete Selected</flux:button>
            </div>
        </div>
    </flux:modal>
</div>
