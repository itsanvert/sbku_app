<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>SBKU Dashboard Report</title>
    <style>
        /* ─── Khmer Font Registration ─── */
        @font-face {
            font-family: 'Noto Sans Khmer';
            src: url('{{ public_path("fonts/NotoSansKhmer-Regular.ttf") }}') format('truetype');
            font-weight: normal;
            font-style: normal;
        }
        @font-face {
            font-family: 'Noto Sans Khmer';
            src: url('{{ public_path("fonts/NotoSansKhmer-Bold.ttf") }}') format('truetype');
            font-weight: bold;
            font-style: normal;
        }
        @font-face {
            font-family: 'Noto Sans Khmer';
            src: url('{{ public_path("fonts/NotoSansKhmer-Light.ttf") }}') format('truetype');
            font-weight: 300;
            font-style: normal;
        }

        /* ─── Base ─── */
        @page {
            size: A4 portrait;
            margin: 0;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }

        body {
            font-family: 'Noto Sans Khmer', DejaVu Sans, sans-serif;
            font-size: 11px;
            color: #1a1a2e;
            background: #ffffff;
            line-height: 1.5;
        }

        .page-wrapper {
            padding: 26px 30px 18px;
        }

        /* ─── Header / Branding ─── */
        .header {
            display: table;
            width: 100%;
            border-bottom: 3px solid #FF5E00;
            padding-bottom: 12px;
            margin-bottom: 16px;
        }

        .header-left {
            display: table-cell;
            vertical-align: middle;
            width: 64px;
        }

        .header-logo {
            width: 58px;
            height: 58px;
            object-fit: contain;
            border-radius: 6px;
        }

        .header-center {
            display: table-cell;
            vertical-align: middle;
            padding-left: 14px;
        }

        .university-name {
            font-size: 15px;
            font-weight: bold;
            color: #FF5E00;
            letter-spacing: 0.4px;
        }

        .university-sub {
            font-size: 10px;
            color: #555;
            margin-top: 2px;
        }

        .report-title {
            font-size: 13px;
            font-weight: bold;
            color: #1a1a2e;
            margin-top: 6px;
            padding-top: 6px;
            border-top: 1px dashed #ddd;
        }

        .header-right {
            display: table-cell;
            vertical-align: middle;
            text-align: right;
            white-space: nowrap;
            width: 190px;
        }

        .meta-block {
            font-size: 9.5px;
            color: #555;
            line-height: 1.7;
        }

        .meta-block strong {
            color: #1a1a2e;
        }

        /* ─── Reporter banner ─── */
        .reporter-banner {
            background: #fff8f4;
            border: 1px solid #FFD5B8;
            border-left: 4px solid #FF5E00;
            border-radius: 4px;
            padding: 8px 14px;
            margin-bottom: 16px;
            font-size: 10.5px;
            color: #444;
        }

        .reporter-banner strong {
            color: #FF5E00;
        }

        /* ─── KPI cards ─── */
        .kpi-row {
            display: table;
            width: 100%;
            margin-bottom: 18px;
            border-spacing: 7px 0;
            margin-left: -7px;
            margin-right: -7px;
        }

        .kpi-card {
            display: table-cell;
            width: 20%;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-top: 3px solid #6366f1;
            border-radius: 6px;
            padding: 9px 12px;
            vertical-align: top;
        }

        .kpi-card.kpi-teachers { border-top-color: #8b5cf6; }
        .kpi-card.kpi-users { border-top-color: #3b82f6; }
        .kpi-card.kpi-checkins { border-top-color: #22c55e; }
        .kpi-card.kpi-sessions { border-top-color: #f59e0b; }

        .kpi-label {
            font-size: 8.5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #6b7280;
            font-weight: bold;
        }

        .kpi-value {
            font-size: 20px;
            font-weight: bold;
            color: #1a1a2e;
            margin-top: 3px;
        }

        .kpi-sub {
            font-size: 8.5px;
            color: #9ca3af;
            margin-top: 1px;
        }

        /* ─── Section titles ─── */
        .section-title {
            font-size: 12px;
            font-weight: bold;
            color: #1a1a2e;
            margin: 20px 0 10px;
            padding-bottom: 5px;
            border-bottom: 2px solid #1a1a2e;
        }

        .section-title .period {
            font-size: 9.5px;
            font-weight: normal;
            color: #6b7280;
        }

        /* ─── Summary cards (status) ─── */
        .summary-row {
            display: table;
            width: 100%;
            margin-bottom: 6px;
            border-spacing: 8px 0;
            margin-left: -8px;
            margin-right: -8px;
        }

        .summary-card {
            display: table-cell;
            width: 25%;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-top: 3px solid #aaa;
            border-radius: 6px;
            padding: 9px 14px;
            vertical-align: top;
        }

        .summary-card.card-present { border-top-color: #22c55e; }
        .summary-card.card-permission { border-top-color: #f59e0b; }
        .summary-card.card-absent { border-top-color: #ef4444; }

        .card-label {
            font-size: 9px;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: #6b7280;
            font-weight: bold;
        }

        .card-value {
            font-size: 20px;
            font-weight: bold;
            color: #1a1a2e;
            margin-top: 3px;
        }

        .card-value.color-present { color: #22c55e; }
        .card-value.color-permission { color: #f59e0b; }
        .card-value.color-absent { color: #ef4444; }

        .card-rate {
            font-size: 8.5px;
            color: #9ca3af;
            margin-top: 2px;
        }

        /* ─── Table ─── */
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 10px;
        }

        thead tr {
            background: #1a1a2e;
            color: #fff;
        }

        thead th {
            padding: 8px 10px;
            text-align: left;
            font-weight: bold;
            letter-spacing: 0.3px;
            white-space: nowrap;
        }

        thead th:first-child {
            border-radius: 4px 0 0 0;
        }

        thead th:last-child {
            border-radius: 0 4px 0 0;
        }

        tbody td {
            padding: 8px 10px;
            border-bottom: 1px solid #e5e7eb;
        }

        tbody tr:nth-child(even) {
            background: #f9fafb;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        .text-center { text-align: center; }
        .text-right { text-align: right; }

        .status-y { color: #15803d; font-weight: bold; }
        .status-n { color: #b91c1c; font-weight: bold; }
        .status-p { color: #b45309; font-weight: bold; }

        .total-row td {
            background: #fff8f4 !important;
            border-top: 2px solid #FF5E00;
            font-weight: bold;
            color: #1a1a2e;
        }

        /* ─── Distribution bars ─── */
        .bar-row {
            margin-bottom: 8px;
        }

        .bar-label {
            font-size: 10px;
            color: #374151;
            margin-bottom: 2px;
        }

        .bar-track {
            background: #f1f5f9;
            border-radius: 4px;
            height: 12px;
            overflow: hidden;
        }

        .bar-fill {
            height: 12px;
            border-radius: 4px;
        }

        .bar-fill.students { background: #3b82f6; }
        .bar-fill.teachers { background: #8b5cf6; }
        .bar-fill.admins { background: #a1a1aa; }
        .bar-fill.present { background: #22c55e; }
        .bar-fill.absent { background: #ef4444; }
        .bar-fill.permission { background: #f59e0b; }

        .bar-value {
            font-size: 9.5px;
            color: #6b7280;
            margin-top: 1px;
        }

        /* ─── Footer ─── */
        .footer {
            margin-top: 30px;
            border-top: 2px solid #FF5E00;
            padding-top: 8px;
            font-size: 8.5px;
            color: #9ca3af;
            text-align: center;
        }
    </style>
</head>

<body>
    <div class="page-wrapper">

        @php
            $totalStatus = $stats['presentCount'] + $stats['absentCount'] + $stats['permissionCount'];
            $presentPct = $totalStatus > 0 ? round($stats['presentCount'] / $totalStatus * 100, 1) : 0;
            $absentPct = $totalStatus > 0 ? round($stats['absentCount'] / $totalStatus * 100, 1) : 0;
            $permissionPct = $totalStatus > 0 ? round($stats['permissionCount'] / $totalStatus * 100, 1) : 0;

            $adminCount = max(0, $stats['userCount'] - $stats['studentCount'] - $stats['teacherCount']);
            $userTotal = $stats['userCount'];
        @endphp

        {{-- ═══ HEADER / BRANDING ═══ --}}
        <div class="header">
            <div class="header-left">
                <img class="header-logo" src="{{ public_path('img/logo.jpg') }}" alt="University Logo">
            </div>

            <div class="header-center">
                <div class="university-name">SBKU</div>
                <div class="university-sub">Saint Barnabas Khmer University</div>
                <div class="report-title">Dashboard Summary Report</div>
            </div>

            <div class="header-right">
                <div class="meta-block">
                    <strong>Generated By:</strong><br>
                    {{ $generatedBy ?? 'System' }}<br><br>
                    <strong>Generated At:</strong><br>
                    {{ ($generatedAt ?? now())->format('d M Y, H:i') }}<br><br>
                    <strong>Period:</strong><br>
                    Last 7 days
                </div>
            </div>
        </div>

        {{-- ═══ REPORTED BY BANNER ═══ --}}
        <div class="reporter-banner">
            &nbsp;Period:
            &nbsp;<strong>{{ $stats['dates'][0] ?? '' }} – {{ $stats['dates'][6] ?? now()->format('M d (D)') }}</strong>
            &nbsp;&nbsp;|&nbsp;&nbsp; <strong>Total Check-ins (7 days):</strong> {{ $totalStatus }}
            &nbsp;&nbsp;|&nbsp;&nbsp; <strong>Attendance Rate:</strong> {{ $presentPct }}%
        </div>

        {{-- ═══ KPI CARDS ═══ --}}
        <div class="kpi-row">
            <div class="kpi-card">
                <div class="kpi-label">Students</div>
                <div class="kpi-value">{{ number_format($stats['studentCount']) }}</div>
                <div class="kpi-sub">Enrolled</div>
            </div>
            <div class="kpi-card kpi-teachers">
                <div class="kpi-label">Teachers</div>
                <div class="kpi-value">{{ number_format($stats['teacherCount']) }}</div>
                <div class="kpi-sub">Active staff</div>
            </div>
            <div class="kpi-card kpi-users">
                <div class="kpi-label">Users</div>
                <div class="kpi-value">{{ number_format($stats['userCount']) }}</div>
                <div class="kpi-sub">Total accounts</div>
            </div>
            <div class="kpi-card kpi-checkins">
                <div class="kpi-label">Check-ins</div>
                <div class="kpi-value">{{ number_format($stats['attendanceCount']) }}</div>
                <div class="kpi-sub">All-time records</div>
            </div>
            <div class="kpi-card kpi-sessions">
                <div class="kpi-label">Active Sessions</div>
                <div class="kpi-value">{{ number_format($stats['activeSessions']) }}</div>
                <div class="kpi-sub">Currently running</div>
            </div>
        </div>

        {{-- ═══ STATUS BREAKDOWN ═══ --}}
        <div class="section-title">Check-in Status Breakdown <span class="period">(last 7 days)</span></div>
        <div class="summary-row">
            <div class="summary-card card-present">
                <div class="card-label">Present</div>
                <div class="card-value color-present">{{ $stats['presentCount'] }}</div>
                <div class="card-rate">{{ $presentPct }}% of check-ins</div>
            </div>
            <div class="summary-card card-permission">
                <div class="card-label">Permission</div>
                <div class="card-value color-permission">{{ $stats['permissionCount'] }}</div>
                <div class="card-rate">{{ $permissionPct }}% of check-ins</div>
            </div>
            <div class="summary-card card-absent">
                <div class="card-label">Absent</div>
                <div class="card-value color-absent">{{ $stats['absentCount'] }}</div>
                <div class="card-rate">{{ $absentPct }}% of check-ins</div>
            </div>
            <div class="summary-card">
                <div class="card-label">Total</div>
                <div class="card-value">{{ $totalStatus }}</div>
                <div class="card-rate">Records in period</div>
            </div>
        </div>

        {{-- Status bars --}}
        <div class="bar-row">
            <div class="bar-label">Present &mdash; {{ $stats['presentCount'] }} ({{ $presentPct }}%)</div>
            <div class="bar-track"><div class="bar-fill present" style="width: {{ $presentPct }}%"></div></div>
        </div>
        <div class="bar-row">
            <div class="bar-label">Permission &mdash; {{ $stats['permissionCount'] }} ({{ $permissionPct }}%)</div>
            <div class="bar-track"><div class="bar-fill permission" style="width: {{ $permissionPct }}%"></div></div>
        </div>
        <div class="bar-row">
            <div class="bar-label">Absent &mdash; {{ $stats['absentCount'] }} ({{ $absentPct }}%)</div>
            <div class="bar-track"><div class="bar-fill absent" style="width: {{ $absentPct }}%"></div></div>
        </div>

        {{-- ═══ DAILY OVERVIEW ═══ --}}
        <div class="section-title">Daily Attendance Overview <span class="period">(last 7 days)</span></div>
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th class="text-center">Present</th>
                    <th class="text-center">Permission</th>
                    <th class="text-center">Absent</th>
                    <th class="text-center">Total Check-ins</th>
                </tr>
            </thead>
            <tbody>
                @foreach($stats['dailyStats'] as $day)
                    <tr>
                        <td>{{ $day['date'] }}</td>
                        <td class="text-center status-y">{{ $day['present'] }}</td>
                        <td class="text-center status-p">{{ $day['permission'] }}</td>
                        <td class="text-center status-n">{{ $day['absent'] }}</td>
                        <td class="text-center"><strong>{{ $day['total'] }}</strong></td>
                    </tr>
                @endforeach
                <tr class="total-row">
                    <td>Total</td>
                    <td class="text-center">{{ $stats['presentCount'] }}</td>
                    <td class="text-center">{{ $stats['permissionCount'] }}</td>
                    <td class="text-center">{{ $stats['absentCount'] }}</td>
                    <td class="text-center">{{ $totalStatus }}</td>
                </tr>
            </tbody>
        </table>

        {{-- ═══ USER DISTRIBUTION ═══ --}}
        <div class="section-title">User Distribution</div>
        <div class="bar-row">
            <div class="bar-label">Students &mdash; {{ $stats['studentCount'] }}
                <span class="bar-value">({{ $userTotal > 0 ? round($stats['studentCount'] / $userTotal * 100, 1) : 0 }}%)</span>
            </div>
            <div class="bar-track"><div class="bar-fill students" style="width: {{ $userTotal > 0 ? round($stats['studentCount'] / $userTotal * 100) : 0 }}%"></div></div>
        </div>
        <div class="bar-row">
            <div class="bar-label">Teachers &mdash; {{ $stats['teacherCount'] }}
                <span class="bar-value">({{ $userTotal > 0 ? round($stats['teacherCount'] / $userTotal * 100, 1) : 0 }}%)</span>
            </div>
            <div class="bar-track"><div class="bar-fill teachers" style="width: {{ $userTotal > 0 ? round($stats['teacherCount'] / $userTotal * 100) : 0 }}%"></div></div>
        </div>
        <div class="bar-row">
            <div class="bar-label">Admin &mdash; {{ $adminCount }}
                <span class="bar-value">({{ $userTotal > 0 ? round($adminCount / $userTotal * 100, 1) : 0 }}%)</span>
            </div>
            <div class="bar-track"><div class="bar-fill admins" style="width: {{ $userTotal > 0 ? round($adminCount / $userTotal * 100) : 0 }}%"></div></div>
        </div>

        <div class="footer">
            SBKU Attendance Management System &mdash; Dashboard Summary Report &mdash; Generated {{ now()->format('d M Y, H:i:s') }}
        </div>
    </div>
</body>

</html>
