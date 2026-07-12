<x-app-layout>
    <div class="p-6 lg:p-8 max-w-[1600px] mx-auto">

        {{-- HEADER --}}
        <div class="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-8 animate-fade-up">
            <div>
                <p class="text-sm text-[#64748b] font-medium mb-1">{{ now()->format('l, F j, Y') }}</p>
                <h1 class="text-3xl font-bold text-gray-900 dark:text-[#f8fafc] tracking-tight">
                    Welcome back, {{ auth()->user()->name }}
                </h1>
                <p class="text-[#94a3b8] dark:text-[#64748b] mt-1">Here's what's happening at your school today.</p>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('teachers.index') }}" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#3b82f6] hover:bg-[#2563eb] text-white text-sm font-semibold transition-all duration-200 shadow-lg shadow-blue-500/20 hover:shadow-blue-500/30 hover:-translate-y-0.5 active:scale-95">
                    <flux:icon name="plus" class="w-4 h-4"/>
                    Add Teacher
                </a>
                <button class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white dark:bg-[rgba(30,41,59,0.85)] border border-gray-200 dark:border-[rgba(255,255,255,0.08)] text-gray-700 dark:text-[#cbd5e1] text-sm font-medium transition-all duration-200 hover:border-gray-300 dark:hover:border-[rgba(255,255,255,0.15)] hover:shadow-md active:scale-95">
                    <flux:icon name="arrow-down-tray" class="w-4 h-4"/>
                    Export
                </button>
            </div>
        </div>

        {{-- STAT CARDS --}}
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 mb-8">

            <div class="stat-card p-5 animate-fade-up delay-100">
                <div class="flex items-center justify-between mb-4">
                    <div class="p-2.5 rounded-xl bg-blue-500/10 text-[#3b82f6]">
                        <flux:icon name="academic-cap" class="w-5 h-5"/>
                    </div>
                    <span class="text-xs font-semibold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full">+12%</span>
                </div>
                <div class="text-3xl font-bold text-[#f8fafc] tracking-tight">{{ number_format($studentCount ?? 0) }}</div>
                <div class="text-xs text-[#64748b] mt-1 font-medium uppercase tracking-wider">Students</div>
                <div class="mt-3 h-1 bg-[rgba(59,130,246,0.1)] rounded-full overflow-hidden">
                    <div class="h-full bg-[#3b82f6] rounded-full" style="width: {{ min(($studentCount ?? 0) / max(($studentCount ?? 0) + ($teacherCount ?? 0) + 1, 1) * 100, 100) }}%"></div>
                </div>
            </div>

            <div class="stat-card p-5 animate-fade-up delay-200">
                <div class="flex items-center justify-between mb-4">
                    <div class="p-2.5 rounded-xl bg-violet-500/10 text-[#8b5cf6]">
                        <flux:icon name="users" class="w-5 h-5"/>
                    </div>
                    <span class="text-xs font-semibold text-[#64748b] bg-[rgba(100,116,139,0.1)] px-2 py-0.5 rounded-full">Active</span>
                </div>
                <div class="text-3xl font-bold text-[#f8fafc] tracking-tight">{{ number_format($teacherCount ?? 0) }}</div>
                <div class="text-xs text-[#64748b] mt-1 font-medium uppercase tracking-wider">Teachers</div>
                <div class="mt-3 h-1 bg-[rgba(139,92,246,0.1)] rounded-full overflow-hidden">
                    <div class="h-full bg-[#8b5cf6] rounded-full" style="width: {{ min(($teacherCount ?? 0) / max(($studentCount ?? 0) + ($teacherCount ?? 0) + 1, 1) * 100, 100) }}%"></div>
                </div>
            </div>

            <div class="stat-card p-5 animate-fade-up delay-300">
                <div class="flex items-center justify-between mb-4">
                    <div class="p-2.5 rounded-xl bg-cyan-500/10 text-[#06b6d4]">
                        <flux:icon name="user-group" class="w-5 h-5"/>
                    </div>
                    <span class="text-xs font-semibold text-[#64748b] bg-[rgba(100,116,139,0.1)] px-2 py-0.5 rounded-full">Total</span>
                </div>
                <div class="text-3xl font-bold text-[#f8fafc] tracking-tight">{{ number_format($userCount ?? 0) }}</div>
                <div class="text-xs text-[#64748b] mt-1 font-medium uppercase tracking-wider">Users</div>
                <div class="mt-3 h-1 bg-[rgba(6,182,212,0.1)] rounded-full overflow-hidden">
                    <div class="h-full bg-[#06b6d4] rounded-full" style="width: 100%"></div>
                </div>
            </div>

            <div class="stat-card p-5 animate-fade-up delay-400">
                <div class="flex items-center justify-between mb-4">
                    <div class="p-2.5 rounded-xl bg-emerald-500/10 text-[#10b981]">
                        <flux:icon name="check-circle" class="w-5 h-5"/>
                    </div>
                    <span class="text-xs font-semibold text-emerald-500 bg-emerald-500/10 px-2 py-0.5 rounded-full">Live</span>
                </div>
                <div class="text-3xl font-bold text-[#f8fafc] tracking-tight">{{ number_format($attendanceCount ?? 0) }}</div>
                <div class="text-xs text-[#64748b] mt-1 font-medium uppercase tracking-wider">Check-ins</div>
                <div class="mt-3 h-1 bg-[rgba(16,185,129,0.1)] rounded-full overflow-hidden">
                    <div class="h-full bg-[#10b981] rounded-full" style="width: {{ min(($attendanceCount ?? 0) / max(($studentCount ?? 0) * 7, 1) * 100, 100) }}%"></div>
                </div>
            </div>

            <div class="stat-card p-5 animate-fade-up delay-500 relative overflow-hidden">
                <div class="absolute inset-0 bg-gradient-to-br from-[#3b82f6]/5 to-[#8b5cf6]/5"></div>
                <div class="relative z-10">
                    <div class="flex items-center justify-between mb-4">
                        <div class="p-2.5 rounded-xl bg-[#3b82f6]/10 text-[#3b82f6]">
                            <flux:icon name="bolt" class="w-5 h-5"/>
                        </div>
                        <div class="flex items-center gap-1.5">
                            <span class="relative flex h-2 w-2">
                                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                                <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                            </span>
                            <span class="text-xs font-semibold text-emerald-500">Online</span>
                        </div>
                    </div>
                    <div class="text-3xl font-bold text-[#f8fafc] tracking-tight">{{ number_format($activeSessions ?? 0) }}</div>
                    <div class="text-xs text-[#64748b] mt-1 font-medium uppercase tracking-wider">Active Sessions</div>
                </div>
            </div>
        </div>

        {{-- CHARTS ROW --}}
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-8">

            <div class="lg:col-span-2 glass-card-static p-6 animate-fade-up" style="animation-delay: 0.3s;">
                <div class="flex items-center justify-between mb-6">
                    <div>
                        <h3 class="text-lg font-bold text-[#f8fafc]">Attendance Overview</h3>
                        <p class="text-sm text-[#64748b] mt-0.5">Daily check-ins over the last 7 days</p>
                    </div>
                </div>
                <div class="relative h-72 w-full">
                    <canvas id="attendanceChart"></canvas>
                </div>
            </div>

            <div class="glass-card-static p-6 animate-fade-up" style="animation-delay: 0.4s;">
                <div class="flex items-center justify-between mb-6">
                    <div>
                        <h3 class="text-lg font-bold text-[#f8fafc]">Status Breakdown</h3>
                        <p class="text-sm text-[#64748b] mt-0.5">Overall check-in results</p>
                    </div>
                </div>
                <div class="relative h-52 w-full flex justify-center">
                    <canvas id="statusAnalysisChart"></canvas>
                </div>
                <div class="flex justify-center gap-6 mt-4">
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-[#10b981]"></span>
                        <span class="text-xs text-[#94a3b8]">Present</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-[#ef4444]"></span>
                        <span class="text-xs text-[#94a3b8]">Absent</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-[#f59e0b]"></span>
                        <span class="text-xs text-[#94a3b8]">Permission</span>
                    </div>
                </div>
            </div>
        </div>

        {{-- BOTTOM ROW: Role Distribution + System Status --}}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">

            <div class="glass-card-static p-6 animate-fade-up" style="animation-delay: 0.5s;">
                <h3 class="text-lg font-bold text-[#f8fafc] mb-6">User Distribution</h3>
                <div class="relative h-56 w-full">
                    <canvas id="userRoleChart"></canvas>
                </div>
            </div>

            <div class="glass-card-static p-6 animate-fade-up relative overflow-hidden" style="animation-delay: 0.6s;">
                <div class="absolute inset-0 bg-gradient-to-br from-[#3b82f6]/5 via-transparent to-[#8b5cf6]/5"></div>
                <div class="relative z-10 flex flex-col h-full justify-between">
                    <div>
                        <h3 class="text-lg font-bold text-[#f8fafc] mb-2">System Status</h3>
                        <p class="text-sm text-[#64748b]">All services operational. Database synced.</p>
                    </div>
                    <div class="flex items-center gap-4 mt-6">
                        <div class="flex items-center gap-2">
                            <span class="relative flex h-2.5 w-2.5">
                                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                                <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
                            </span>
                            <span class="text-sm text-[#94a3b8]">All systems go</span>
                        </div>
                        <div class="flex-1"></div>
                        <button class="px-5 py-2.5 rounded-xl bg-[#3b82f6] hover:bg-[#2563eb] text-white text-sm font-semibold transition-all duration-200 shadow-lg shadow-blue-500/20 hover:shadow-blue-500/30 active:scale-95">
                            Generate Report
                        </button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    @push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof Chart === 'undefined') return;

            const isDark = document.documentElement.classList.contains('dark');
            const gridColor = isDark ? 'rgba(255,255,255,0.06)' : '#e5e7eb';
            const labelColor = isDark ? '#64748b' : '#9ca3af';
            const cardBg = isDark ? '#1e293b' : '#ffffff';
            const primary = '#3b82f6';

            Chart.defaults.color = labelColor;
            Chart.defaults.borderColor = gridColor;
            Chart.defaults.font.family = "'Inter', ui-sans-serif, system-ui, sans-serif";

            // Attendance Volume Chart
            const ctxAttendance = document.getElementById('attendanceChart');
            if (ctxAttendance) {
                const ctx = ctxAttendance.getContext('2d');
                const gradient = ctx.createLinearGradient(0, 0, 0, 350);
                gradient.addColorStop(0, 'rgba(59, 130, 246, 0.25)');
                gradient.addColorStop(1, 'rgba(59, 130, 246, 0)');

                new Chart(ctxAttendance, {
                    type: 'line',
                    data: {
                        labels: {!! json_encode($dates) !!},
                        datasets: [{
                            label: 'Check-ins',
                            data: {!! json_encode($counts) !!},
                            borderColor: primary,
                            backgroundColor: gradient,
                            borderWidth: 2.5,
                            fill: true,
                            tension: 0.4,
                            pointBackgroundColor: primary,
                            pointBorderColor: isDark ? '#1e293b' : '#ffffff',
                            pointBorderWidth: 2,
                            pointRadius: 0,
                            pointHoverRadius: 6,
                            pointHoverBackgroundColor: primary,
                            pointHoverBorderColor: '#ffffff',
                            pointHoverBorderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        interaction: { intersect: false, mode: 'index' },
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: isDark ? '#1e293b' : '#ffffff',
                                titleColor: isDark ? '#f8fafc' : '#111827',
                                bodyColor: isDark ? '#94a3b8' : '#6b7280',
                                borderColor: isDark ? 'rgba(255,255,255,0.1)' : '#e5e7eb',
                                borderWidth: 1,
                                padding: 12,
                                cornerRadius: 10,
                                displayColors: false,
                                titleFont: { weight: 'bold' }
                            }
                        },
                        scales: {
                            y: { beginAtZero: true, grid: { color: gridColor, drawBorder: false }, ticks: { color: labelColor, padding: 8 } },
                            x: { grid: { display: false }, ticks: { color: labelColor, padding: 8 } }
                        }
                    }
                });
            }

            // Status Doughnut Chart
            const ctxStatus = document.getElementById('statusAnalysisChart');
            if (ctxStatus) {
                const total = {{ ($presentCount ?? 0) + ($absentCount ?? 0) + ($permissionCount ?? 0) }};
                const presentPct = total > 0 ? Math.round(($presentCount ?? 0) / total * 100) : 0;

                new Chart(ctxStatus, {
                    type: 'doughnut',
                    data: {
                        labels: ['Present', 'Absent', 'Permission'],
                        datasets: [{
                            data: [{{ $presentCount ?? 0 }}, {{ $absentCount ?? 0 }}, {{ $permissionCount ?? 0 }}],
                            backgroundColor: ['#10b981', '#ef4444', '#f59e0b'],
                            borderColor: isDark ? '#1e293b' : '#ffffff',
                            borderWidth: 4,
                            hoverOffset: 8,
                            borderRadius: 4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '72%',
                        plugins: { legend: { display: false } }
                    },
                    plugins: [{
                        id: 'centerText',
                        afterDraw: function(chart) {
                            const { ctx, chartArea } = chart;
                            const centerX = (chartArea.left + chartArea.right) / 2;
                            const centerY = (chartArea.top + chartArea.bottom) / 2;
                            ctx.save();
                            ctx.textAlign = 'center';
                            ctx.textBaseline = 'middle';
                            ctx.fillStyle = isDark ? '#f8fafc' : '#111827';
                            ctx.font = 'bold 28px ui-sans-serif, system-ui, sans-serif';
                            ctx.fillText(presentPct + '%', centerX, centerY - 8);
                            ctx.fillStyle = isDark ? '#64748b' : '#9ca3af';
                            ctx.font = '500 11px ui-sans-serif, system-ui, sans-serif';
                            ctx.fillText('PRESENT', centerX, centerY + 16);
                            ctx.restore();
                        }
                    }]
                });
            }

            // User Role Bar Chart
            const ctxRoles = document.getElementById('userRoleChart');
            if (ctxRoles) {
                new Chart(ctxRoles, {
                    type: 'bar',
                    data: {
                        labels: ['Students', 'Teachers', 'Admin'],
                        datasets: [{
                            label: 'Users',
                            data: [{{ $studentCount ?? 0 }}, {{ $teacherCount ?? 0 }}, {{ max(0, ($userCount ?? 0) - ($studentCount ?? 0) - ($teacherCount ?? 0)) }}],
                            backgroundColor: ['#3b82f6', '#8b5cf6', '#64748b'],
                            borderRadius: 8,
                            barThickness: 36
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        scales: {
                            y: { beginAtZero: true, grid: { color: gridColor, drawBorder: false }, ticks: { color: labelColor, padding: 8 } },
                            x: { grid: { display: false }, ticks: { color: labelColor } }
                        }
                    }
                });
            }
        });
    </script>
    @endpush
</x-app-layout>
