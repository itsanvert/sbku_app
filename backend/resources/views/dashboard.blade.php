<x-app-layout>
    <x-slot name="header">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <h2 class="font-extrabold text-2xl text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-indigo-600 leading-tight">
                {{ __('Dashboard Overview') }}
            </h2>
            
            <!-- Quick Actions / Slide Bar Dropdown with Scale Animation -->
            <div class="flex items-center space-x-3">
                <div x-data="{ open: false }" class="relative">
                    <button @click="open = !open" @click.away="open = false" class="flex items-center px-4 py-2 bg-white rounded-full shadow-sm hover:shadow-md hover:scale-105 transition-all duration-300 text-sm font-medium text-gray-700 hover:text-blue-600 border border-gray-100">
                        <flux:icon name="sparkles" variant="solid" class="w-4 h-4 mr-2 text-yellow-500" />
                        Quick Actions
                        <flux:icon name="chevron-down" variant="solid" class="w-4 h-4 ml-2 transition-transform duration-300" x-bind:class="{ 'rotate-180': open }" />
                    </button>
                    <!-- Scale Drop box animation -->
                    <div x-show="open" 
                         x-transition:enter="transition ease-out duration-300"
                         x-transition:enter-start="opacity-0 scale-90 translate-y-[-10px]"
                         x-transition:enter-end="opacity-100 scale-100 translate-y-0"
                         x-transition:leave="transition ease-in duration-200"
                         x-transition:leave-start="opacity-100 scale-100 translate-y-0"
                         x-transition:leave-end="opacity-0 scale-90 translate-y-[-10px]"
                         class="absolute right-0 mt-3 w-56 bg-white rounded-xl shadow-2xl py-2 z-50 border border-gray-100" style="display: none;">
                        <a href="{{ route('students.index') }}" class="flex items-center px-4 py-2.5 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-700 transition-colors group">
                            <flux:icon name="academic-cap" variant="outline" class="w-4 h-4 mr-3 text-gray-400 group-hover:text-blue-500 transition-colors"/>
                            Manage Students
                        </a>
                        <a href="{{ route('teachers.index') }}" class="flex items-center px-4 py-2.5 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-700 transition-colors group">
                            <flux:icon name="users" variant="outline" class="w-4 h-4 mr-3 text-gray-400 group-hover:text-indigo-500 transition-colors"/>
                            Manage Teachers
                        </a>
                        <div class="border-t border-gray-100 my-1"></div>
                        <a href="{{ route('attendance.records.index') }}" class="flex items-center px-4 py-2.5 text-sm text-gray-700 hover:bg-green-50 hover:text-green-700 transition-colors group">
                            <flux:icon name="check-circle" variant="outline" class="w-4 h-4 mr-3 text-gray-400 group-hover:text-green-500 transition-colors"/>
                            View Attendances
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </x-slot>

    <div class="space-y-8">
            
            <!-- Features Cards with Hover Scale & Drop Shadow -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
                <!-- Students Card -->
                <div class="group bg-white rounded-2xl p-5 border border-gray-100 shadow-sm hover:shadow-2xl hover:-translate-y-1 hover:scale-[1.03] transition-all duration-300 relative overflow-hidden">
                    <div class="absolute -right-6 -top-6 bg-blue-50 w-24 h-24 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out opacity-60 z-0"></div>
                    <div class="relative z-10 flex flex-col h-full justify-between">
                        <div class="flex items-start justify-between">
                            <div class="p-2.5 bg-blue-100/50 text-blue-600 rounded-xl backdrop-blur-sm">
                                <flux:icon name="academic-cap" variant="outline" class="w-6 h-6"/>
                            </div>
                            <div x-data="{ dropdownOpen: false }" class="relative">
                                <button @click="dropdownOpen = !dropdownOpen" @click.away="dropdownOpen = false" class="text-gray-400 hover:text-blue-500 transition-colors bg-gray-50 hover:bg-blue-50 p-1.5 rounded-lg">
                                    <flux:icon name="ellipsis-vertical" variant="solid" class="w-5 h-5"/>
                                </button>
                                <div x-show="dropdownOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 scale-75" x-transition:enter-end="opacity-100 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 scale-100" x-transition:leave-end="opacity-0 scale-75" class="absolute right-0 mt-2 w-32 bg-white border border-gray-100 rounded-lg shadow-xl py-1 z-50 text-sm" style="display: none;">
                                    <a href="{{ route('students.index') }}" class="block px-4 py-2 text-gray-700 hover:bg-blue-50 hover:text-blue-600">View List</a>
                                </div>
                            </div>
                        </div>
                        <div class="mt-4">
                            <h3 class="text-3xl font-extrabold text-gray-900 tracking-tight">{{ number_format($studentCount ?? 0) }}</h3>
                            <p class="text-xs font-semibold text-gray-500 mt-1 uppercase tracking-wider">Total Students</p>
                        </div>
                    </div>
                </div>

                <!-- Teachers Card -->
                <div class="group bg-white rounded-2xl p-5 border border-gray-100 shadow-sm hover:shadow-2xl hover:-translate-y-1 hover:scale-[1.03] transition-all duration-300 relative overflow-hidden">
                    <div class="absolute -right-6 -top-6 bg-indigo-50 w-24 h-24 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out opacity-60 z-0"></div>
                    <div class="relative z-10 flex flex-col h-full justify-between">
                        <div class="flex items-start justify-between">
                            <div class="p-2.5 bg-indigo-100/50 text-indigo-600 rounded-xl backdrop-blur-sm">
                                <flux:icon name="users" variant="outline" class="w-6 h-6"/>
                            </div>
                            <div x-data="{ dropdownOpen: false }" class="relative">
                                <button @click="dropdownOpen = !dropdownOpen" @click.away="dropdownOpen = false" class="text-gray-400 hover:text-indigo-500 transition-colors bg-gray-50 hover:bg-indigo-50 p-1.5 rounded-lg">
                                    <flux:icon name="ellipsis-vertical" variant="solid" class="w-5 h-5"/>
                                </button>
                                <div x-show="dropdownOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 scale-75" x-transition:enter-end="opacity-100 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 scale-100" x-transition:leave-end="opacity-0 scale-75" class="absolute right-0 mt-2 w-32 bg-white border border-gray-100 rounded-lg shadow-xl py-1 z-50 text-sm" style="display: none;">
                                    <a href="{{ route('teachers.index') }}" class="block px-4 py-2 text-gray-700 hover:bg-indigo-50 hover:text-indigo-600">View List</a>
                                </div>
                            </div>
                        </div>
                        <div class="mt-4">
                            <h3 class="text-3xl font-extrabold text-gray-900 tracking-tight">{{ number_format($teacherCount ?? 0) }}</h3>
                            <p class="text-xs font-semibold text-gray-500 mt-1 uppercase tracking-wider">Total Teachers</p>
                        </div>
                    </div>
                </div>

                <!-- Users Card -->
                <div class="group bg-white rounded-2xl p-5 border border-gray-100 shadow-sm hover:shadow-2xl hover:-translate-y-1 hover:scale-[1.03] transition-all duration-300 relative overflow-hidden">
                    <div class="absolute -right-6 -top-6 bg-sky-50 w-24 h-24 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out opacity-60 z-0"></div>
                    <div class="relative z-10 flex flex-col h-full justify-between">
                        <div class="flex items-start justify-between">
                            <div class="p-2.5 bg-sky-100/50 text-sky-600 rounded-xl backdrop-blur-sm">
                                <flux:icon name="user" variant="outline" class="w-6 h-6"/>
                            </div>
                            <div x-data="{ dropdownOpen: false }" class="relative">
                                <button @click="dropdownOpen = !dropdownOpen" @click.away="dropdownOpen = false" class="text-gray-400 hover:text-sky-500 transition-colors bg-gray-50 hover:bg-sky-50 p-1.5 rounded-lg">
                                    <flux:icon name="ellipsis-vertical" variant="solid" class="w-5 h-5"/>
                                </button>
                                <div x-show="dropdownOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 scale-75" x-transition:enter-end="opacity-100 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 scale-100" x-transition:leave-end="opacity-0 scale-75" class="absolute right-0 mt-2 w-32 bg-white border border-gray-100 rounded-lg shadow-xl py-1 z-50 text-sm" style="display: none;">
                                    <a href="#" class="block px-4 py-2 text-gray-700 hover:bg-sky-50 hover:text-sky-600">Details</a>
                                </div>
                            </div>
                        </div>
                        <div class="mt-4">
                            <h3 class="text-3xl font-extrabold text-gray-900 tracking-tight">{{ number_format($userCount ?? 0) }}</h3>
                            <p class="text-xs font-semibold text-gray-500 mt-1 uppercase tracking-wider">Total Users</p>
                        </div>
                    </div>
                </div>

                <!-- Attendance Card -->
                <div class="group bg-white rounded-2xl p-5 border border-gray-100 shadow-sm hover:shadow-2xl hover:-translate-y-1 hover:scale-[1.03] transition-all duration-300 relative overflow-hidden">
                    <div class="absolute -right-6 -top-6 bg-emerald-50 w-24 h-24 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out opacity-60 z-0"></div>
                    <div class="relative z-10 flex flex-col h-full justify-between">
                        <div class="flex items-start justify-between">
                            <div class="p-2.5 bg-emerald-100/50 text-emerald-600 rounded-xl backdrop-blur-sm">
                                <flux:icon name="check-circle" variant="outline" class="w-6 h-6"/>
                            </div>
                            <div x-data="{ dropdownOpen: false }" class="relative">
                                <button @click="dropdownOpen = !dropdownOpen" @click.away="dropdownOpen = false" class="text-gray-400 hover:text-emerald-500 transition-colors bg-gray-50 hover:bg-emerald-50 p-1.5 rounded-lg">
                                    <flux:icon name="ellipsis-vertical" variant="solid" class="w-5 h-5"/>
                                </button>
                                <div x-show="dropdownOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 scale-75" x-transition:enter-end="opacity-100 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 scale-100" x-transition:leave-end="opacity-0 scale-75" class="absolute right-0 mt-2 w-32 bg-white border border-gray-100 rounded-lg shadow-xl py-1 z-50 text-sm" style="display: none;">
                                    <a href="{{ route('attendance.records.index') }}" class="block px-4 py-2 text-gray-700 hover:bg-emerald-50 hover:text-emerald-600">View Log</a>
                                </div>
                            </div>
                        </div>
                        <div class="mt-4">
                            <h3 class="text-3xl font-extrabold text-gray-900 tracking-tight">{{ number_format($attendanceCount ?? 0) }}</h3>
                            <p class="text-xs font-semibold text-gray-500 mt-1 uppercase tracking-wider">App Check-ins</p>
                        </div>
                    </div>
                </div>

                <!-- Active Sessions Card -->
                <div class="group bg-gradient-to-br from-orange-500 to-red-500 rounded-2xl p-5 shadow-lg hover:shadow-2xl hover:-translate-y-1 hover:scale-[1.03] transition-all duration-300 relative overflow-hidden text-white drop-shadow-md border border-orange-400">
                    <div class="absolute -right-6 -top-6 bg-white/20 w-32 h-32 rounded-full blur-xl group-hover:scale-150 transition-transform duration-700 ease-out opacity-60 z-0 animate-pulse"></div>
                    <div class="relative z-10 flex flex-col h-full justify-between">
                        <div class="flex items-start justify-between">
                            <div class="p-2.5 bg-white/20 text-white rounded-xl backdrop-blur-md shadow-inner">
                                <flux:icon name="bolt" variant="solid" class="w-6 h-6 animate-bounce"/>
                            </div>
                            <div x-data="{ dropdownOpen: false }" class="relative">
                                <button @click="dropdownOpen = !dropdownOpen" @click.away="dropdownOpen = false" class="text-white hover:text-orange-200 transition-colors bg-white/10 hover:bg-white/30 p-1.5 rounded-lg shadow-sm">
                                    <flux:icon name="ellipsis-vertical" variant="solid" class="w-5 h-5"/>
                                </button>
                                <div x-show="dropdownOpen" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 scale-75" x-transition:enter-end="opacity-100 scale-100" x-transition:leave="transition ease-in duration-150" x-transition:leave-start="opacity-100 scale-100" x-transition:leave-end="opacity-0 scale-75" class="absolute right-0 mt-2 w-32 bg-white border border-gray-100 rounded-lg shadow-xl py-1 z-50 text-sm text-gray-800" style="display: none;">
                                    <a href="#" class="block px-4 py-2 hover:bg-orange-50 hover:text-orange-600 transition-colors">Manage</a>
                                </div>
                            </div>
                        </div>
                        <div class="mt-4">
                            <h3 class="text-3xl font-extrabold tracking-tight drop-shadow-sm">{{ number_format($activeSessions ?? 0) }}</h3>
                            <p class="text-xs font-bold text-orange-100 mt-1 uppercase tracking-wider drop-shadow-sm">Active Sessions</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Section -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Daily Attendance Volume -->
                <div class="lg:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-lg transition-shadow duration-300">
                    <div class="flex justify-between items-center mb-6">
                        <div>
                            <h3 class="text-lg font-bold text-gray-900">Attendance Volume</h3>
                            <p class="text-sm text-gray-500">Daily check-ins (last 7 days)</p>
                        </div>
                    </div>
                    <div class="relative h-72 w-full">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <!-- Status Distribution -->
                <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-lg transition-shadow duration-300">
                    <div class="flex justify-between items-center mb-6">
                        <div>
                            <h3 class="text-lg font-bold text-gray-900">Status Analysis</h3>
                            <p class="text-sm text-gray-500">Overall check-in results</p>
                        </div>
                    </div>
                    <div class="relative h-72 w-full flex justify-center">
                        <canvas id="statusAnalysisChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Role Distribution & Summary Row -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                    <h3 class="text-lg font-bold text-gray-900 mb-6">User Role Distribution</h3>
                    <div class="relative h-56 w-full">
                        <canvas id="userRoleChart"></canvas>
                    </div>
                </div>

                <!-- Footer-style Summary Summary section -->
                <div class="bg-gradient-to-r from-gray-900 to-gray-800 rounded-2xl p-6 shadow-xl relative overflow-hidden flex flex-col md:flex-row items-center justify-between text-white border border-gray-700">
                    <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10"></div>
                    <div class="flex items-center space-x-5 mb-4 md:mb-0 relative z-10">
                        <div class="w-14 h-14 rounded-full bg-gradient-to-tr from-blue-500 to-purple-500 flex items-center justify-center shadow-lg border-2 border-white/20">
                            <flux:icon name="rocket-launch" variant="solid" class="w-7 h-7 text-white"/>
                        </div>
                        <div>
                            <h4 class="text-xl font-extrabold tracking-tight">System Status</h4>
                            <p class="text-sm font-medium text-gray-300 mt-1">Services active. Database synced.</p>
                        </div>
                    </div>
                    <button class="relative z-10 px-6 py-3 bg-white text-gray-900 rounded-xl font-bold shadow-lg hover:shadow-2xl hover:-translate-y-1 hover:bg-gray-50 transition-all duration-300 transform active:scale-95">
                        Generate Report
                    </button>
                </div>
            </div>
            
    @push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof Chart !== 'undefined') {
                
                // 1. Attendance Volume Chart (Line)
                const ctxAttendance = document.getElementById('attendanceChart');
                if (ctxAttendance) {
                    let grad = ctxAttendance.getContext('2d').createLinearGradient(0, 0, 0, 400);
                    grad.addColorStop(0, 'rgba(59, 130, 246, 0.5)'); 
                    grad.addColorStop(1, 'rgba(59, 130, 246, 0)');

                    new Chart(ctxAttendance, {
                        type: 'line',
                        data: {
                            labels: {!! json_encode($dates) !!},
                            datasets: [{
                                label: 'Check-ins',
                                data: {!! json_encode($counts) !!},
                                borderColor: '#3b82f6',
                                backgroundColor: grad,
                                borderWidth: 3,
                                fill: true,
                                tension: 0.4,
                                pointBackgroundColor: '#fff',
                                pointBorderWidth: 2,
                                pointRadius: 5
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: { legend: { display: false } },
                            scales: {
                                y: { beginAtZero: true, grid: { borderDash: [4, 4] } },
                                x: { grid: { display: false } }
                            }
                        }
                    });
                }

                // 2. Status Analysis Chart (Doughnut)
                const ctxStatus = document.getElementById('statusAnalysisChart');
                if (ctxStatus) {
                    new Chart(ctxStatus, {
                        type: 'doughnut',
                        data: {
                            labels: ['Present (Y)', 'Absent (N)', 'Permission (P)'],
                            datasets: [{
                                data: [{{ $presentCount }}, {{ $absentCount }}, {{ $permissionCount }}],
                                backgroundColor: ['#10b981', '#ef4444', '#f59e0b'], // emerald, red, amber
                                borderWidth: 0,
                                hoverOffset: 12
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '70%',
                            plugins: { legend: { position: 'bottom', labels: { boxWidth: 12, padding: 20, font: { weight: 'bold' } } } }
                        }
                    });
                }

                // 3. User Role Distribution Chart (Bar)
                const ctxRoles = document.getElementById('userRoleChart');
                if (ctxRoles) {
                    new Chart(ctxRoles, {
                        type: 'bar',
                        data: {
                            labels: ['Students', 'Teachers', 'Admin/Staff'],
                            datasets: [{
                                label: 'Users',
                                data: [{{ $studentCount }}, {{ $teacherCount }}, {{ max(0, $userCount - $studentCount - $teacherCount) }}],
                                backgroundColor: ['#3b82f6', '#6366f1', '#475569'], // blue, indigo, slate
                                borderRadius: 8,
                                barThickness: 40
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: { legend: { display: false } },
                            scales: {
                                y: { beginAtZero: true, grid: { display: false } },
                                x: { grid: { display: false } }
                            }
                        }
                    });
                }
            }
        });
    </script>
    @endpush
</x-app-layout>
