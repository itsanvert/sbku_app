<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Attendance Report</title>
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
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Noto Sans Khmer', DejaVu Sans, sans-serif;
            font-size: 11px;
            color: #1a1a2e;
            background: #ffffff;
            line-height: 1.5;
        }

        /* ─── Page layout ─── */
        .page-wrapper {
            padding: 28px 32px 20px;
        }

        /* ─── Header / Branding ─── */
        .header {
            display: table;
            width: 100%;
            border-bottom: 3px solid #FF5E00;
            padding-bottom: 14px;
            margin-bottom: 18px;
        }

        .header-left {
            display: table-cell;
            vertical-align: middle;
            width: 80px;
        }

        .header-logo {
            width: 72px;
            height: 72px;
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
            width: 200px;
        }

        .meta-block {
            font-size: 10px;
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

        /* ─── Summary cards ─── */
        .summary-row {
            display: table;
            width: 100%;
            margin-bottom: 18px;
            border-spacing: 8px 0;
        }

        .summary-card {
            display: table-cell;
            width: 25%;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-top: 3px solid #aaa;
            border-radius: 6px;
            padding: 10px 14px;
            vertical-align: top;
        }

        .summary-card.card-total {
            border-top-color: #6366f1;
        }

        .summary-card.card-present {
            border-top-color: #22c55e;
        }

        .summary-card.card-permission {
            border-top-color: #f59e0b;
        }

        .summary-card.card-absent {
            border-top-color: #ef4444;
        }

        .card-label {
            font-size: 9.5px;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: #6b7280;
            font-weight: bold;
        }

        .card-value {
            font-size: 22px;
            font-weight: bold;
            color: #1a1a2e;
            margin-top: 4px;
        }

        .card-value.color-total {
            color: #6366f1;
        }

        .card-value.color-present {
            color: #22c55e;
        }

        .card-value.color-permission {
            color: #f59e0b;
        }

        .card-value.color-absent {
            color: #ef4444;
        }

        .card-rate {
            font-size: 9px;
            color: #9ca3af;
            margin-top: 2px;
        }

        /* ─── Table ─── */
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 10.5px;
        }

        thead tr {
            background: #1a1a2e;
            color: #fff;
        }

        thead th {
            padding: 9px 10px;
            text-align: left;
            font-weight: bold;
            letter-spacing: 0.3px;
            white-space: nowrap;
        }

        thead th:first-child {
            border-radius: 4px 0 0 0;
            width: 30px;
            text-align: center;
        }

        thead th:last-child {
            border-radius: 0 4px 0 0;
        }

        tbody tr {
            border-bottom: 1px solid #e5e7eb;
        }

        tbody tr:nth-child(even) {
            background: #f9fafb;
        }

        tbody tr:nth-child(odd) {
            background: #ffffff;
        }

        tbody td {
            padding: 8px 10px;
            vertical-align: middle;
            color: #374151;
        }

        tbody td:first-child {
            text-align: center;
            color: #9ca3af;
            font-size: 10px;
        }

        .cell-name {
            font-weight: 600;
            color: #111827;
            font-size: 11px;
        }

        .cell-sub {
            font-size: 9.5px;
            color: #9ca3af;
            margin-top: 1px;
        }

        /* ─── Status badges ─── */
        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 9.5px;
            font-weight: bold;
            letter-spacing: 0.3px;
        }

        .badge-present {
            background: #dcfce7;
            color: #15803d;
            border: 1px solid #bbf7d0;
        }

        .badge-permission {
            background: #fef3c7;
            color: #b45309;
            border: 1px solid #fde68a;
        }

        .badge-absent {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }

        /* ─── Verify status ─── */
        .verify-approved {
            color: #15803d;
            font-weight: bold;
        }

        .verify-rejected {
            color: #b91c1c;
            font-weight: bold;
        }

        .verify-pending {
            color: #b45309;
        }

        /* ─── Footer ─── */
        .footer {
            margin-top: 20px;
            border-top: 1px solid #e5e7eb;
            padding-top: 10px;
            display: table;
            width: 100%;
        }

        .footer-left {
            display: table-cell;
            font-size: 9px;
            color: #9ca3af;
            vertical-align: bottom;
        }

        .footer-right {
            display: table-cell;
            text-align: right;
            font-size: 9px;
            color: #9ca3af;
            vertical-align: bottom;
        }

        .signature-block {
            margin-top: 40px;
            display: table;
            width: 100%;
        }

        .signature-cell {
            display: table-cell;
            width: 33%;
            text-align: center;
            font-size: 10px;
            color: #374151;
        }

        .signature-line {
            border-top: 1px solid #374151;
            margin: 30px 20px 6px;
        }

        .signature-label {
            font-size: 9.5px;
            color: #6b7280;
        }
    </style>
</head>

<body>
    <div class="page-wrapper">

        {{-- ═══ HEADER / BRANDING ═══ --}}
        <div class="header">
            <div class="header-left">
                <img class="header-logo" src="{{ public_path('img/logo.jpg') }}" alt="University Logo">
            </div>

            <div class="header-center">
                <div class="university-name">SBKU</div>
                <div class="report-title"> Attendance Records Report</div>
            </div>

            <div class="header-right">
                <div class="meta-block">
                    <strong>Report Date:</strong><br>
                    {{ now()->format('d M Y') }}<br>
                    {{ now()->format('H:i') }}<br><br>
                    <strong>Academic Year:</strong><br>
                    {{ now()->format('Y') }}–{{ now()->addYear()->format('Y') }}
                </div>
            </div>
        </div>

        {{-- ═══ REPORTED BY BANNER ═══ --}}
        <div class="reporter-banner">
            &nbsp;Reported by:
            &nbsp;<strong>{{ $reportedBy ?? ($records->first()?->session?->teacher?->user?->name ?? 'System') }}</strong>
            @if(isset($filterInfo))
                &nbsp;&nbsp;|&nbsp;&nbsp; <strong>Filter:</strong> {{ $filterInfo }}
            @endif
            &nbsp;&nbsp;|&nbsp;&nbsp; <strong>Total Records:</strong> {{ count($records) }}
        </div>

        {{-- ═══ SUMMARY CARDS ═══ --}}
        @php
            $total = count($records);
            $present = $records->where('status', 'Y')->count();
            $permission = $records->where('status', 'P')->count();
            $absent = $records->where('status', 'N')->count();
            $rate = $total > 0 ? round(($present / $total) * 100, 1) : 0;
        @endphp

        <div class="summary-row">
            <div class="summary-card card-total">
                <div class="card-label">Total Students</div>
                <div class="card-value color-total">{{ $total }}</div>
                <div class="card-rate">All attendance records</div>
            </div>
            <div class="summary-card card-present">
                <div class="card-label">Present</div>
                <div class="card-value color-present">{{ $present }}</div>
                <div class="card-rate">{{ $rate }}% attendance rate</div>
            </div>
            <div class="summary-card card-permission">
                <div class="card-label">Permission</div>
                <div class="card-value color-permission">{{ $permission }}</div>
                <div class="card-rate">With approved reason</div>
            </div>
            <div class="summary-card card-absent">
                <div class="card-label">Absent</div>
                <div class="card-value color-absent">{{ $absent }}</div>
                <div class="card-rate">{{ $total > 0 ? round(($absent / $total) * 100, 1) : 0 }}% of total</div>
            </div>
        </div>

        {{-- ═══ ATTENDANCE TABLE ═══ --}}
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Date</th>
                    <th>Student</th>
                    <th>Faculty / Major</th>
                    <th>Year &amp; Shift</th>
                    <th>Teacher</th>
                    <th>Status</th>
                    <th>Verify</th>
                    <th>Check-in</th>
                </tr>
            </thead>
            <tbody>
                @foreach($records as $index => $record)
                    <tr>
                        {{-- Row number --}}
                        <td>{{ $index + 1 }}</td>

                        {{-- Date --}}
                        <td>
                            <span class="cell-name">{{ $record->attendance_date?->format('d M Y') }}</span>
                            <div class="cell-sub">{{ $record->attendance_date?->format('D') }}</div>
                        </td>

                        {{-- Student info --}}
                        <td>
                            <span class="cell-name">{{ $record->student->user->name ?? '—' }}</span>
                            <div class="cell-sub">ID: {{ $record->student->student_code ?? '—' }}</div>
                        </td>

                        {{-- Faculty / Major --}}
                        <td>
                            <span class="cell-name">
                                {{ $record->student->faculty->name ?? $record->session?->faculty?->name ?? '—' }}
                            </span>
                            <div class="cell-sub">
                                {{ $record->student->major->name ?? $record->session?->major?->name ?? '—' }}
                            </div>
                        </td>

                        {{-- Year & Shift --}}
                        <td>
                            <span class="cell-name">Year {{ $record->student->year ?? '—' }}</span>
                            <div class="cell-sub">{{ $record->student->shift->name ?? '—' }}</div>
                        </td>

                        {{-- Teacher --}}
                        <td>{{ $record->session?->teacher?->user?->name ?? '—' }}</td>

                        {{-- Status badge --}}
                        <td>
                            @if($record->status === 'Y')
                                <span class="badge badge-present">Present</span>
                            @elseif($record->status === 'P')
                                <span class="badge badge-permission">Permission</span>
                            @else
                                <span class="badge badge-absent">Absent</span>
                            @endif
                        </td>

                        {{-- Verify status --}}
                        <td>
                            @php $vs = strtolower($record->verify_status ?? 'pending'); @endphp
                            <span class="verify-{{ $vs }}">{{ ucfirst($vs) }}</span>
                        </td>

                        {{-- Check-in time --}}
                        <td>
                            @php
                                $ct = $record->check_in_time;
                                $checkInDisplay = '—';
                                if ($ct instanceof \Carbon\Carbon) {
                                    $checkInDisplay = $ct->format('H:i');
                                } elseif (is_string($ct) && $ct !== '') {
                                    $checkInDisplay = substr($ct, 0, 5);
                                } elseif (is_numeric($ct)) {
                                    $checkInDisplay = \Carbon\Carbon::createFromTimestamp($ct)->format('H:i');
                                }
                            @endphp
                            {{ $checkInDisplay }}
                        </td>
                    </tr>
                @endforeach

                @if($records->isEmpty())
                    <tr>
                        <td colspan="9" style="text-align:center; padding: 20px; color: #9ca3af;">
                            No attendance records found.
                        </td>
                    </tr>
                @endif
            </tbody>
        </table>

        {{-- ═══ SIGNATURE BLOCK ═══ --}}
        <div class="signature-block">
            <div class="signature-cell">
                <div class="signature-line"></div>
                <div>Reported by</div>
                <div class="signature-label">{{ $reportedBy ?? 'Teacher' }}</div>
            </div>
            <div class="signature-cell">
                <div class="signature-line"></div>
                <div>Checked by</div>
                <div class="signature-label">Head of Department</div>
            </div>
            <div class="signature-cell">
                <div class="signature-line"></div>
                <div>Approved by</div>
                <div class="signature-label">Dean / Director</div>
            </div>
        </div>

        {{-- ═══ FOOTER ═══ --}}
        <div class="footer">
            <div style="border-bottom: 2px solid #FF5E00; margin-bottom: 8px;"></div>
            <div style="display: table; width: 100%;">
                <div class="footer-left">
                    <strong>SBKU (Samdech Preah Mahasangrajah Bour Kry University)</strong> &mdash; Attendance Management System<br>
                    <span style="font-size: 8px; color: #aaa;">This document is auto-generated and valid without a handwritten signature.</span>
                </div>
                <div class="footer-right">
                    Generated on: {{ now()->format('d M Y, H:i:s') }}<br>
                    <strong>Report ID: {{ strtoupper(uniqid('SRU-')) }}</strong>
                </div>
            </div>
        </div>

    </div>
</body>

</html>
