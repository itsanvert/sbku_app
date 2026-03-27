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
                <th>Date</th>
                <th>Student</th>
                <th>Session/Teacher</th>
                <th>Status</th>
                <th>Checked In At</th>
            </tr>
        </thead>
        <tbody>
            @foreach($records as $record)
                <tr>
                    <td>{{ $record->attendance_date?->format('Y-m-d') }}</td>
                    <td>{{ $record->student->user->name ?? 'Unknown Student' }}</td>
                    <td>{{ $record->session->teacher->user->name ?? 'Unknown Teacher' }}</td>
                    <td>{{ $record->status === 'Y' ? 'Present' :'Absent' }}</td>
                    <td>{{ $record->check_in_time ? $record->check_in_time->format('M d, H:i') : '—' }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
