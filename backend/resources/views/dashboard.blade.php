<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Dashboard Overview') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8 space-y-6">
            
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Students Card -->
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-blue-500 hover:shadow-md transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-zinc-500 uppercase tracking-wider">Total Students</p>
                            <p class="text-3xl font-bold text-zinc-900 mt-2">{{ number_format($studentCount) }}</p>
                        </div>
                        <div class="p-3 bg-blue-50 text-blue-600 rounded-full">
                            <flux:icon name="academic-cap" variant="outline" class="w-8 h-8"/>
                        </div>
                    </div>
                </div>

                <!-- Teachers Card -->
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-indigo-500 hover:shadow-md transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-zinc-500 uppercase tracking-wider">Total Teachers</p>
                            <p class="text-3xl font-bold text-zinc-900 mt-2">{{ number_format($teacherCount) }}</p>
                        </div>
                        <div class="p-3 bg-indigo-50 text-indigo-600 rounded-full">
                            <flux:icon name="users" variant="outline" class="w-8 h-8"/>
                        </div>
                    </div>
                </div>

                <!-- Users Card -->
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-zinc-500 hover:shadow-md transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-zinc-500 uppercase tracking-wider">Total Users</p>
                            <p class="text-3xl font-bold text-zinc-900 mt-2">{{ number_format($userCount) }}</p>
                        </div>
                        <div class="p-3 bg-zinc-50 text-zinc-600 rounded-full">
                            <flux:icon name="user" variant="outline" class="w-8 h-8"/>
                        </div>
                    </div>
                </div>

                <!-- Total App Check-ins -->
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-green-500 hover:shadow-md transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-zinc-500 uppercase tracking-wider">App Check-ins</p>
                            <p class="text-3xl font-bold text-zinc-900 mt-2">{{ number_format($attendanceCount) }}</p>
                        </div>
                        <div class="p-3 bg-green-50 text-green-600 rounded-full">
                            <flux:icon name="check-circle" variant="outline" class="w-8 h-8"/>
                        </div>
                    </div>
                </div>

                <!-- Active Sessions -->
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-orange-500 hover:shadow-md transition">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-zinc-500 uppercase tracking-wider">Active Sessions</p>
                            <p class="text-3xl font-bold text-zinc-900 mt-2">{{ number_format($activeSessions) }}</p>
                        </div>
                        <div class="p-3 bg-orange-50 text-orange-600 rounded-full animate-pulse">
                            <flux:icon name="bolt" variant="solid" class="w-8 h-8"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
