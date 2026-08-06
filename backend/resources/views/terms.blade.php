<x-guest-layout>
    <div class="min-h-screen flex flex-col items-center px-4 py-12">
        <flux:brand logo="/img/logo.webp" name="SBKU" class="mb-6" />

        <div class="w-full sm:max-w-2xl">
            <flux:card>
                <div class="prose prose-zinc dark:prose-invert max-w-none">
                    {!! $terms !!}
                </div>
            </flux:card>
        </div>
    </div>
</x-guest-layout>
