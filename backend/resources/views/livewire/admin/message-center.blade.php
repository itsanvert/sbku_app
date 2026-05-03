<div>
    <x-slot name="header">
        <flux:heading size="xl">Message Center</flux:heading>
        <flux:subheading>Manage announcements and push notifications</flux:subheading>
    </x-slot>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        {{-- Send Message Form --}}
        <div class="md:col-span-1">
            <div class="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm space-y-6">
                <flux:heading size="lg">Compose Message</flux:heading>

                <form wire:submit.prevent="sendMessage" class="space-y-4">
                    <flux:input wire:model="title" label="Title" placeholder="Enter message title..." />
                    
                    <flux:textarea wire:model="body" label="Body" placeholder="Enter message content..." rows="5" />

                    <flux:field>
                        <flux:label>Type</flux:label>
                        <flux:select wire:model="type">
                            <flux:select.option value="announcement">Announcement</flux:select.option>
                            <flux:select.option value="private">Private Message</flux:select.option>
                            <flux:select.option value="alert">Alert</flux:select.option>
                        </flux:select>
                    </flux:field>

                    <flux:field>
                        <flux:label>Receiver (Optional)</flux:label>
                        <flux:select wire:model="receiver_id" placeholder="Broadcast to All">
                            <flux:select.option value="">All Users (Broadcast)</flux:select.option>
                            @foreach($users as $user)
                                <flux:select.option value="{{ $user->id }}">{{ $user->name }} ({{ $user->role }})</flux:select.option>
                            @endforeach
                        </flux:select>
                        <flux:description>Leave empty to send to everyone via FCM topic.</flux:description>
                    </flux:field>

                    <flux:checkbox wire:model="send_push" label="Send Push Notification" />

                    <div class="pt-2">
                        <flux:button type="submit" variant="primary" class="w-full">
                            Send Message
                        </flux:button>
                    </div>
                </form>

                @if (session()->has('message'))
                    <flux:callout variant="success" class="mt-4">
                        {{ session('message') }}
                    </flux:callout>
                @endif
            </div>
        </div>

        {{-- Message History --}}
        <div class="md:col-span-2">
            <div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">
                <div class="px-6 py-4 border-b border-zinc-200">
                    <flux:heading size="lg">Message History</flux:heading>
                </div>

                <flux:table :paginate="$messages">
                    <flux:table.columns>
                        <flux:table.column>Sent At</flux:table.column>
                        <flux:table.column>Target</flux:table.column>
                        <flux:table.column>Title</flux:table.column>
                        <flux:table.column>Type</flux:table.column>
                    </flux:table.columns>

                    <flux:table.rows>
                        @foreach($messages as $msg)
                            <flux:table.row>
                                <flux:table.cell class="whitespace-nowrap">
                                    {{ $msg->created_at->format('M d, H:i') }}
                                </flux:table.cell>
                                <flux:table.cell>
                                    @if($msg->receiver_id)
                                        <span class="font-medium">{{ $msg->receiver->name ?? 'User' }}</span>
                                    @else
                                        <span class="text-blue-600 font-bold">Broadcast</span>
                                    @endif
                                </flux:table.cell>
                                <flux:table.cell class="max-w-xs truncate">
                                    <span class="font-medium text-zinc-900">{{ $msg->title }}</span>
                                    <p class="text-xs text-zinc-500 truncate">{{ $msg->body }}</p>
                                </flux:table.cell>
                                <flux:table.cell>
                                    <flux:badge size="sm" :variant="$msg->type === 'alert' ? 'danger' : 'neutral'">
                                        {{ ucfirst($msg->type) }}
                                    </flux:badge>
                                </flux:table.cell>
                            </flux:table.row>
                        @endforeach
                    </flux:table.rows>
                </flux:table>
            </div>
        </div>
    </div>
</div>
