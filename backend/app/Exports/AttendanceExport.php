<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithHeadings;

class AttendanceExport implements FromCollection, WithMapping, WithHeadings
{
    protected $records;

    public function __construct($records)
    {
        $this->records = $records;
    }

    public function collection()
    {
        return $this->records->getCollection();
    }

    public function headings(): array
    {
        return [
            'Attendance Date',
            'Student Name',
            'Session/Teacher',
            'Status',
            'Checked In Time',
        ];
    }

    public function map($record): array
    {
        return [
            $record->attendance_date?->format('Y-m-d'),
            $record->student->user->name ?? 'Unknown Student',
            $record->session->teacher->user->name ?? 'Unknown Teacher',
            $record->status === 'Y' ? 'Present' : ($record->status === 'N' ? 'Absent' : 'Late'),
            $record->check_in_time ? $record->check_in_time->format('H:i:s') : '—',
        ];
    }
}
