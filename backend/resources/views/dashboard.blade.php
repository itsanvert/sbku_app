<x-app-layout>
    <div class="space-y-6">
        {{-- HEADER --}}
        <div class="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-8">
            <div>
                <flux:subheading>{{ now()->format('l, F j, Y') }}</flux:subheading>
                <flux:heading size="xl">Dashboard</flux:heading>
                <p class="text-sm text-zinc-500 mt-1">Monitor university activities, analytics, and system performance.</p>
            </div>
            <div class="flex items-center gap-3">
                <flux:button variant="primary" icon="plus" href="{{ route('teachers.index') }}">
                    Add Teacher
                </flux:button>
                <flux:button variant="outline" icon="arrow-down-tray">
                    Export
                </flux:button>
            </div>
        </div>

        {{-- STAT CARDS --}}
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">

            <flux:card class="!p-5">
                <div class="flex items-center justify-between mb-3">
                    <div class="p-2 rounded-lg bg-zinc-100 dark:bg-white/10 text-zinc-600 dark:text-zinc-300">
                        <flux:icon name="academic-cap" class="w-5 h-5" />
                    </div>
                    <flux:badge color="green" size="sm">+12%</flux:badge>
                </div>
                <div class="text-3xl font-bold text-zinc-900 dark:text-white tracking-tight">{{ number_format($studentCount ?? 0) }}</div>
                <div class="text-xs text-zinc-500 mt-1 font-medium uppercase tracking-wider">Students</div>
            </flux:card>

            <flux:card class="!p-5">
                <div class="flex items-center justify-between mb-3">
                    <div class="p-2 rounded-lg bg-zinc-100 dark:bg-white/10 text-zinc-600 dark:text-zinc-300">
                        <flux:icon name="users" class="w-5 h-5" />
                    </div>
                    <flux:badge color="zinc" size="sm">Active</flux:badge>
                </div>
                <div class="text-3xl font-bold text-zinc-900 dark:text-white tracking-tight">{{ number_format($teacherCount ?? 0) }}</div>
                <div class="text-xs text-zinc-500 mt-1 font-medium uppercase tracking-wider">Teachers</div>
            </flux:card>

            <flux:card class="!p-5">
                <div class="flex items-center justify-between mb-3">
                    <div class="p-2 rounded-lg bg-zinc-100 dark:bg-white/10 text-zinc-600 dark:text-zinc-300">
                        <flux:icon name="user-group" class="w-5 h-5" />
                    </div>
                    <flux:badge color="zinc" size="sm">Total</flux:badge>
                </div>
                <div class="text-3xl font-bold text-zinc-900 dark:text-white tracking-tight">{{ number_format($userCount ?? 0) }}</div>
                <div class="text-xs text-zinc-500 mt-1 font-medium uppercase tracking-wider">Users</div>
            </flux:card>

            <flux:card class="!p-5">
                <div class="flex items-center justify-between mb-3">
                    <div class="p-2 rounded-lg bg-zinc-100 dark:bg-white/10 text-zinc-600 dark:text-zinc-300">
                        <flux:icon name="check-circle" class="w-5 h-5" />
                    </div>
                    <flux:badge color="green" size="sm">Live</flux:badge>
                </div>
                <div class="text-3xl font-bold text-zinc-900 dark:text-white tracking-tight">{{ number_format($attendanceCount ?? 0) }}</div>
                <div class="text-xs text-zinc-500 mt-1 font-medium uppercase tracking-wider">Check-ins</div>
            </flux:card>

            <flux:card class="!p-5">
                <div class="flex items-center justify-between mb-3">
                    <div class="p-2 rounded-lg bg-zinc-100 dark:bg-white/10 text-zinc-600 dark:text-zinc-300">
                        <flux:icon name="bolt" class="w-5 h-5" />
                    </div>
                    <div class="flex items-center gap-1.5">
                        <span class="relative flex h-2 w-2">
                            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                            <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                        </span>
                        <flux:badge color="green" size="sm">Online</flux:badge>
                    </div>
                </div>
                <div class="text-3xl font-bold text-zinc-900 dark:text-white tracking-tight">{{ number_format($activeSessions ?? 0) }}</div>
                <div class="text-xs text-zinc-500 mt-1 font-medium uppercase tracking-wider">Active Sessions</div>
            </flux:card>
        </div>

        {{-- CHARTS ROW --}}
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">

            <flux:card class="lg:col-span-2">
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <flux:heading size="lg">Attendance Overview</flux:heading>
                        <flux:subheading>Daily check-ins over the last 7 days</flux:subheading>
                    </div>
                </div>
                <div class="relative h-72 w-full">
                    <canvas id="attendanceChart"></canvas>
                </div>
            </flux:card>

            <flux:card>
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <flux:heading size="lg">Status Breakdown</flux:heading>
                        <flux:subheading>Overall check-in results</flux:subheading>
                    </div>
                </div>
                <div class="relative h-52 w-full flex justify-center">
                    <canvas id="statusAnalysisChart"></canvas>
                </div>
                <div class="flex justify-center gap-6 mt-4">
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-[#10b981]"></span>
                        <span class="text-xs text-zinc-600 dark:text-zinc-400">Present</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-[#ef4444]"></span>
                        <span class="text-xs text-zinc-600 dark:text-zinc-400">Absent</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full bg-[#f59e0b]"></span>
                        <span class="text-xs text-zinc-600 dark:text-zinc-400">Permission</span>
                    </div>
                </div>
            </flux:card>
        </div>

        {{-- BOTTOM ROW: Role Distribution + System Status --}}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">

            <flux:card>
                <flux:heading size="lg" class="mb-4">User Distribution</flux:heading>
                <div class="relative h-56 w-full">
                    <canvas id="userRoleChart"></canvas>
                </div>
            </flux:card>

            <flux:card class="flex flex-col justify-between">
                <div>
                    <flux:heading size="lg" class="mb-1">System Status</flux:heading>
                    <flux:subheading>All services operational. Database synced.</flux:subheading>
                </div>
                <div class="flex items-center gap-4 mt-6">
                    <div class="flex items-center gap-2">
                        <span class="relative flex h-2.5 w-2.5">
                            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                            <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
                        </span>
                        <span class="text-sm text-zinc-600 dark:text-zinc-400">All systems go</span>
                    </div>
                    <div class="flex-1"></div>
                    <flux:button variant="primary">Generate Report</flux:button>
                </div>
            </flux:card>
        </div>
    </div>

    @push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof Chart === 'undefined') return;

            const isDark = document.documentElement.classList.contains('dark');
            const gridColor = isDark ? 'rgba(255,255,255,0.06)' : '#e5e7eb';
            const labelColor = isDark ? '#71717a' : '#a1a1aa';
            const cardBg = isDark ? '#1e293b' : '#ffffff';
            const primary = '#3b82f6';

            Chart.defaults.color = labelColor;
            Chart.defaults.borderColor = gridColor;
            Chart.defaults.font.family = "'Inter', ui-sans-serif, system-ui, sans-serif";

            const ctxAttendance = document.getElementById('attendanceChart');
            if (ctxAttendance) {
                const ctx = ctxAttendance.getContext('2d');
                const gradient = ctx.createLinearGradient(0, 0, 0, 350);
                gradient.addColorStop(0, 'rgba(59, 130, 246, 0.2)');
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
                                backgroundColor: isDark ? '#18181b' : '#ffffff',
                                titleColor: isDark ? '#f4f4f5' : '#18181b',
                                bodyColor: isDark ? '#a1a1aa' : '#71717a',
                                borderColor: isDark ? 'rgba(255,255,255,0.1)' : '#e4e4e7',
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
                            borderColor: isDark ? '#18181b' : '#ffffff',
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
                            ctx.fillStyle = isDark ? '#f4f4f5' : '#18181b';
                            ctx.font = 'bold 28px ui-sans-serif, system-ui, sans-serif';
                            ctx.fillText(presentPct + '%', centerX, centerY - 8);
                            ctx.fillStyle = isDark ? '#a1a1aa' : '#a1a1aa';
                            ctx.font = '500 11px ui-sans-serif, system-ui, sans-serif';
                            ctx.fillText('PRESENT', centerX, centerY + 16);
                            ctx.restore();
                        }
                    }]
                });
            }

            const ctxRoles = document.getElementById('userRoleChart');
            if (ctxRoles) {
                new Chart(ctxRoles, {
                    type: 'bar',
                    data: {
                        labels: ['Students', 'Teachers', 'Admin'],
                        datasets: [{
                            label: 'Users',
                            data: [{{ $studentCount ?? 0 }}, {{ $teacherCount ?? 0 }}, {{ max(0, ($userCount ?? 0) - ($studentCount ?? 0) - ($teacherCount ?? 0)) }}],
                            backgroundColor: ['#3b82f6', '#8b5cf6', '#a1a1aa'],
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
