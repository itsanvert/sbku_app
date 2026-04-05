<!DOCTYPE html>
<html>

<head>
    <title>Attendance Records</title>
    <style>
        body {
            font-family: sans-serif;
            font-size: 12px;
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th,
        td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }

        th {
            background-color: #f8f9fa;
            color: #333;
            font-weight: bold;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .summary {
            margin-bottom: 20px;
            padding: 15px;
            background: #fdfdfd;
            border: 1px solid #eee;
            border-radius: 8px;
        }

        .summary-item {
            display: inline-block;
            margin-right: 30px;
        }

        .summary-label {
            font-weight: bold;
            color: #666;
            margin-bottom: 5px;
            display: block;
        }

        .summary-value {
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }

        .status-y {
            color: #28a745;
            font-weight: bold;
        }

        .status-p {
            color: #fd7e14;
            font-weight: bold;
        }

        .status-n {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>

<body>
    <div class="header">
        <h2 style="color: #d35400; margin-bottom: 5px;">Attendance Records Report</h2>
        <p style="color: #7f8c8d; margin-top: 0;">Generated on: {{ now()->format('M d, Y H:i:s') }}</p>
    </div>

    <div class="summary">
        <div class="summary-item">
            <span class="summary-label">Total Students</span>
            <span class="summary-value">{{ count($records) }}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Present (Y)</span>
            <span class="summary-value" style="color: #28a745;">{{ $records->where('status', 'Y')->count() }}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Permission (P)</span>
            <span class="summary-value" style="color: #fd7e14;">{{ $records->where('status', 'P')->count() }}</span>
        </div>
        <div class="summary-item">
            <span class="summary-label">Absent (N)</span>
            <span class="summary-value" style="color: #dc3545;">{{ $records->where('status', 'N')->count() }}</span>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Date</th>
                <th>Student info</th>
                <th>Faculty / Major</th>
                <th>Class info</th>
                <th>Teacher</th>
                <th>Status</th>
                <th>Verify</th>
                <th>Time</th>
            </tr>
        </thead>
        <tbody>
            @foreach($records as $index => $record)
                <tr>
                    <td>{{ $index + 1 }}</td>
                    <td>{{ $record->attendance_date?->format('Y-m-d') }}</td>
                    <td>
                        <strong>{{ $record->student->user->name ?? '—' }}</strong><br>
                        <small>ID: {{ $record->student->student_code ?? '—' }}</small>
                    </td>
                    <td>
                        {{ $record->student->faculty->name ?? $record->session->faculty->name ?? '—' }}<br>
                        <small>{{ $record->student->major->name ?? $record->session->major->name ?? '—' }}</small>
                    </td>
                    <td>
                        Year: {{ $record->student->year ?? '—' }}<br>
                        Shift: {{ $record->student->shift->name ?? '—' }}
                    </td>
                    <td>{{ $record->session->teacher->user->name ?? '—' }}</td>
                    <td>
                        @if($record->status === 'Y')
                            <span class="status-y">Present</span>
                        @elseif($record->status === 'P')
                            <span class="status-p">Permission</span>
                        @else
                            <span class="status-n">Absent</span>
                        @endif
                    </td>
                    <td>{{ ucfirst($record->verify_status ?? 'pending') }}</td>
                    <td>{{ $record->check_in_time ? $record->check_in_time->format('H:i') : '—' }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>

</html>