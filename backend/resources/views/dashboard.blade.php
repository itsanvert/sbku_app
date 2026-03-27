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
                <!-- Line/Bar Chart -->
                <div class="lg:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-lg transition-shadow duration-300">
                    <div class="flex justify-between items-center mb-6">
                        <div>
                            <h3 class="text-lg font-bold text-gray-900">Attendance Activity</h3>
                            <p class="text-sm text-gray-500">Overview of recent check-ins</p>
                        </div>
                        <div class="flex space-x-2">
                            <span class="px-3 py-1 bg-blue-50 text-blue-600 border border-blue-100 rounded-full text-xs font-bold tracking-wide">Weekly</span>
                        </div>
                    </div>
                    <div class="relative h-72 w-full">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <!-- Doughnut Chart -->
                <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-lg transition-shadow duration-300">
                    <div class="flex justify-between items-center mb-6">
                        <div>
                            <h3 class="text-lg font-bold text-gray-900">User Distribution</h3>
                            <p class="text-sm text-gray-500">By account type</p>
                        </div>
                    </div>
                    <div class="relative h-56 w-full flex justify-center">
                        <canvas id="userRoleChart"></canvas>
                    </div>
                    <div class="mt-6 grid grid-cols-3 gap-2 text-center border-t border-gray-100 pt-5">
                        <div class="group hover:bg-blue-50 p-2 rounded-xl transition-colors cursor-default">
                            <p class="text-[10px] text-gray-500 font-bold tracking-widest uppercase mb-1">Students</p>
                            <p class="text-lg font-black text-gray-800 group-hover:text-blue-600 transition-colors">{{ number_format($studentCount ?? 0) }}</p>
                        </div>
                        <div class="group hover:bg-indigo-50 p-2 rounded-xl transition-colors cursor-default border-l border-r border-gray-100">
                            <p class="text-[10px] text-gray-500 font-bold tracking-widest uppercase mb-1">Teachers</p>
                            <p class="text-lg font-black text-gray-800 group-hover:text-indigo-600 transition-colors">{{ number_format($teacherCount ?? 0) }}</p>
                        </div>
                        <div class="group hover:bg-gray-100 p-2 rounded-xl transition-colors cursor-default">
                            <p class="text-[10px] text-gray-500 font-bold tracking-widest uppercase mb-1">Other</p>
                            <p class="text-lg font-black text-gray-800 transition-colors">{{ number_format(max(0, ($userCount ?? 0) - ($studentCount ?? 0) - ($teacherCount ?? 0))) }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer Action Panel -->
            <div class="bg-gradient-to-r from-gray-900 to-gray-800 rounded-2xl p-6 shadow-xl relative overflow-hidden flex flex-col md:flex-row items-center justify-between text-white border border-gray-700">
                <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10"></div>
                <div class="flex items-center space-x-5 mb-4 md:mb-0 relative z-10">
                    <div class="w-14 h-14 rounded-full bg-gradient-to-tr from-blue-500 to-purple-500 flex items-center justify-center shadow-lg border-2 border-white/20">
                        <flux:icon name="rocket-launch" variant="solid" class="w-7 h-7 text-white"/>
                    </div>
                    <div>
                        <h4 class="text-xl font-extrabold tracking-tight">System is running smoothly</h4>
                        <p class="text-sm font-medium text-gray-300 mt-1">All services are up and active. Check pending reports.</p>
                    </div>
                </div>
                <button class="relative z-10 px-6 py-3 bg-white text-gray-900 rounded-xl font-bold shadow-lg hover:shadow-2xl hover:-translate-y-1 hover:bg-gray-50 transition-all duration-300 transform active:scale-95">
                    Generate Report
                </button>
            </div>
            
    @push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof Chart !== 'undefined') {
                // Formatting data for visual appeal
                const ctxAttendance = document.getElementById('attendanceChart');
                if (ctxAttendance) {
                    // Create gradient for line chart
                    let gradient = ctxAttendance.getContext('2d').createLinearGradient(0, 0, 0, 400);
                    gradient.addColorStop(0, 'rgba(59, 130, 246, 0.4)'); // blue-500, semi-transparent
                    gradient.addColorStop(1, 'rgba(59, 130, 246, 0)'); // transparent

                    new Chart(ctxAttendance, {
                        type: 'line',
                        data: {
                            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                            datasets: [{
                                label: 'Successful Check-ins',
                                data: [120, 210, 160, 250, 210, 80, 40], // Dummy realistic data
                                borderColor: '#3b82f6', // blue-500
                                backgroundColor: gradient,
                                borderWidth: 3,
                                fill: true,
                                tension: 0.4, // Smooth curves
                                pointBackgroundColor: '#ffffff',
                                pointBorderColor: '#3b82f6',
                                pointBorderWidth: 2,
                                pointRadius: 4,
                                pointHoverRadius: 6,
                                pointHoverBorderWidth: 3,
                                pointHoverBackgroundColor: '#ffffff'
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { display: false },
                                tooltip: {
                                    backgroundColor: 'rgba(17, 24, 39, 0.95)', // gray-900
                                    padding: 12,
                                    titleFont: { size: 13, family: "'Inter', sans-serif", weight: '600' },
                                    bodyFont: { size: 14, family: "'Inter', sans-serif", weight: 'bold' },
                                    cornerRadius: 8,
                                    displayColors: false,
                                    callbacks: {
                                        label: function(context) {
                                            return context.parsed.y + ' check-ins';
                                        }
                                    }
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    grid: { borderDash: [4, 4], color: '#f3f4f6' }, // gray-100
                                    border: { display: false },
                                    ticks: { color: '#6b7280', font: { family: "'Inter', sans-serif" } }
                                },
                                x: {
                                    grid: { display: false },
                                    border: { display: false },
                                    ticks: { color: '#6b7280', font: { family: "'Inter', sans-serif" } }
                                }
                            },
                            interaction: { mode: 'index', intersect: false }
                        }
                    });
                }

                // Setup User Roles Doughnut Chart
                const ctxRoles = document.getElementById('userRoleChart');
                if (ctxRoles) {
                    const studentCount = {{ $studentCount ?? 0 }};
                    const teacherCount = {{ $teacherCount ?? 0 }};
                    const otherCount = Math.max(0, {{ ($userCount ?? 0) - ($studentCount ?? 0) - ($teacherCount ?? 0) }});
                    
                    // Fallback so the chart isn't empty if the DB is blank
                    const data = (studentCount + teacherCount + otherCount) === 0 ? [50, 20, 5] : [studentCount, teacherCount, otherCount];

                    new Chart(ctxRoles, {
                        type: 'doughnut',
                        data: {
                            labels: ['Students', 'Teachers', 'Other Users'],
                            datasets: [{
                                data: data,
                                backgroundColor: [
                                    '#3b82f6', // blue-500
                                    '#6366f1', // indigo-500
                                    '#cbd5e1'  // slate-300
                                ],
                                hoverBackgroundColor: [
                                    '#2563eb', // blue-600
                                    '#4f46e5', // indigo-600
                                    '#94a3b8'  // slate-400
                                ],
                                borderWidth: 0,
                                hoverOffset: 6
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '75%', // Modern thin ring
                            plugins: {
                                legend: { display: false },
                                tooltip: {
                                    backgroundColor: 'rgba(17, 24, 39, 0.95)',
                                    padding: 12,
                                    cornerRadius: 8,
                                    titleFont: { family: "'Inter', sans-serif", size: 13 },
                                    bodyFont: { family: "'Inter', sans-serif", weight: 'bold', size: 14 }
                                }
                            },
                            animation: { animateScale: true, animateRotate: true }
                        }
                    });
                }
            }
        });
    </script>
    @endpush
</x-app-layout>
