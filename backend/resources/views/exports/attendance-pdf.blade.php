<!DOCTYPE html>
<html>
<head>
    <title>Attendance Records</title>
    <style>
        body { font-family: sans-serif; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .header { text-align: center; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h2>Attendance Records Report</h2>
        <p>Generated on: {{ now()->format('M d, Y H:i') }}</p>
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
                        Shift: {{ $record->student->shift ?? '—' }}
                    </td>
                    <td>{{ $record->session->teacher->user->name ?? '—' }}</td>
                    <td style="color: {{ $record->status === 'Y' ? 'green' : 'red' }}; font-weight: bold;">
                        {{ $record->status === 'Y' ? 'Present' : 'Absent' }}
                    </td>
                    <td>{{ ucfirst($record->verify_status ?? 'pending') }}</td>
                    <td>{{ $record->check_in_time ? $record->check_in_time->format('H:i') : '—' }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
