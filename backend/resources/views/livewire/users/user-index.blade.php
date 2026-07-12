<div>
    <x-slot name="header">
        <flux:heading size="xl">User Management</flux:heading>
        <flux:subheading>Manage team members, roles, and account access</flux:subheading>
    </x-slot>

    <div class="space-y-4">

            {{-- Flash Message --}}
            @if (session()->has('message'))
                <flux:callout variant="success" icon="check-circle" dismissible>
                    {{ session('message') }}
                </flux:callout>
            @endif

            <div class="bg-white dark:bg-[#1e293b] rounded-xl border border-gray-200 dark:border-[rgba(255,255,255,0.08)] shadow-sm overflow-hidden">

                {{-- Toolbar --}}
                <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)]">
                    <div class="flex items-center gap-2">
                        <flux:input
                            wire:model.live.debounce.300ms="search"
                            icon="magnifying-glass"
                            placeholder="Search users…"
                            size="sm"
                            class="w-52"
                        />

                        <flux:select wire:model.live="role" size="sm" class="w-40">
                            <flux:select.option value="">All Roles</flux:select.option>
                            <flux:select.option value="super_admin">Super Admin</flux:select.option>
                            <flux:select.option value="admin">Admin</flux:select.option>
                            <flux:select.option value="teacher">Teacher</flux:select.option>
                            <flux:select.option value="student">Student</flux:select.option>
                        </flux:select>

                        @if(count($selected) > 0)
                            <flux:button wire:click="confirmBulkDelete"  size="sm" >
                                Delete ({{ count($selected) }})
                            </flux:button>
                        @endif
                    </div>

                    <flux:button wire:click="openCreateModal"  size="sm">
                        Add User
                    </flux:button>
                </div>

                {{-- Table --}}
                <flux:table :paginate="$this->users">
                    <table class="w-full text-sm text-left">
                        <colgroup>
                            <col class="w-10">
                            <col class="w-12">
                            <col class="w-56">
                            <col>
                            <col class="w-24">
                            <col class="w-32">
                            <col class="w-36">
                        </colgroup>
                        <thead>
                            <tr class="border-b border-gray-200 dark:border-[rgba(255,255,255,0.08)] bg-gray-50 dark:bg-[#1e293b]">
                                <th class="px-4 py-3">
                                    <flux:checkbox wire:model.live="selectAll" />
                                </th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 cursor-pointer hover:text-gray-600 dark:hover:text-gray-300 select-none" wire:click="sort('id')">#</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 cursor-pointer hover:text-gray-600 dark:hover:text-gray-300 select-none" wire:click="sort('name')">Name</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 cursor-pointer hover:text-gray-600 dark:hover:text-gray-300 select-none" wire:click="sort('email')">Email</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 cursor-pointer hover:text-gray-600 dark:hover:text-gray-300 select-none" wire:click="sort('role')">Role</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500 cursor-pointer hover:text-gray-600 dark:hover:text-gray-300 select-none" wire:click="sort('created_at')">Joined</th>
                                <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-gray-400 dark:text-gray-500">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-[#374151]">
                            @forelse ($this->users as $user)
                                <tr class="hover:bg-gray-50/70 dark:hover:bg-[#263548]/50 transition-colors duration-100">

                                    <td class="px-4 py-3">
                                        <flux:checkbox wire:model.live="selected" value="{{ $user->id }}" />
                                    </td>

                                    <td class="px-4 py-3 tabular-nums text-xs text-gray-400 dark:text-gray-500">
                                        {{ $user->id }}
                                    </td>

                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-2.5">
                                            <img
                                                class="h-7 w-7 rounded-lg object-cover ring-1 ring-gray-200 dark:ring-[#374151] shrink-0"
                                                src="{{ $user->profile_photo_url }}"
                                                alt="{{ $user->name }}"
                                            />
                                            <span class="font-medium text-gray-900 dark:text-gray-50 truncate">{{ $user->name }}</span>
                                        </div>
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
                                        {{ $user->email }}
                                    </td>

                                    <td class="px-4 py-3">
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
                                    </td>

                                    <td class="px-4 py-3 text-sm text-gray-400 dark:text-gray-500">
                                        {{ $user->created_at?->format('M j, Y') ?? '—' }}
                                    </td>

                                    <td class="px-4 py-3">
                                    <div class="flex items-center gap-1.5">
                                        <flux:button wire:click="openEditModal('{{ $user->id }}')" size="sm" variant="ghost" >Edit</flux:button>
                                        <flux:button wire:click="confirmDelete('{{ $user->id }}')" size="sm" variant="danger" >Delete</flux:button>
                                    </div>
                                    </td>

                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="px-4 py-14 text-center">
                                        <div class="flex flex-col items-center gap-1.5 text-gray-400 dark:text-gray-500">
                                            <flux:icon name="users" class="w-6 h-6 mb-0.5" />
                                            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">No users found</p>
                                            <p class="text-xs">Try adjusting your search or filters</p>
                                        </div>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </flux:table>

            </div>

    </div>

    {{-- Create Modal --}}
    @if ($showCreateModal)
        <livewire:users.user-create :key="'create'" />
    @endif

    {{-- Edit Modal --}}
    @if ($showEditModal && $editUserId)
        <livewire:users.user-edit :userId="$editUserId" :key="'edit-'.$editUserId" />
    @endif

    {{-- Delete Confirm Modal --}}
    <div>
        <flux:modal name="confirm-delete" class="min-w-[22rem] space-y-6">
            <div>
                <flux:heading size="lg">Delete this user?</flux:heading>
                <flux:subheading>This action cannot be undone. The user will be permanently removed.</flux:subheading>
            </div>
            <div class="flex justify-end gap-2">
                <flux:modal.close>
                    <flux:button variant="ghost">Cancel</flux:button>
                </flux:modal.close>
               <flux:button
                    wire:click="deleteUser"
                    size="sm"
                    variant="danger"
                >Delete</flux:button>
            </div>
        </flux:modal>

        {{-- Bulk Delete Confirm Modal --}}
        <flux:modal name="confirm-bulk-delete" class="min-w-[22rem] space-y-6">
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
        </flux:modal>
    </div>

</div>
