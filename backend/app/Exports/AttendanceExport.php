<?php

namespace App\Exports;

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Font;
use Illuminate\Support\Collection;

/**
 * AttendanceExport
 *
 * Generates a styled XLSX file using PhpSpreadsheet directly
 * (avoids the broken maatwebsite/excel v1 package).
 *
 * Columns exported:
 *   #, Date, Student Name, Student ID/Code, Faculty, Major,
 *   Year, Shift, Generation, Teacher, Status, Verified, Check-In Time, Notes
 */
class AttendanceExport
{
    protected $records;

    public function __construct($records)
    {
        // Accept Paginator, Collection, or plain array
        if (method_exists($records, 'getCollection')) {
            $this->records = $records->getCollection();
        } elseif ($records instanceof Collection) {
            $this->records = $records;
        } else {
            $this->records = collect($records);
        }
    }

    /**
     * Stream the XLSX file to the browser as a download.
     */
    public function download(string $filename = 'attendance-records.xlsx'): \Symfony\Component\HttpFoundation\StreamedResponse
    {
        $spreadsheet = $this->build();
        $writer      = new Xlsx($spreadsheet);

        return response()->streamDownload(function () use ($writer) {
            $writer->save('php://output');
        }, $filename, [
            'Content-Type'        => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
            'Cache-Control'       => 'max-age=0',
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal builder
    // ─────────────────────────────────────────────────────────────────────────

    private function build(): Spreadsheet
    {
        $spreadsheet = new Spreadsheet();
        $sheet       = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Attendance Records');

        // ── Document metadata ──────────────────────────────────────────────
        $spreadsheet->getProperties()
            ->setTitle('Attendance Records')
            ->setSubject('SBKU Attendance Export')
            ->setDescription('Exported on ' . now()->format('Y-m-d H:i:s'));

        // ── Title row ──────────────────────────────────────────────────────
        $sheet->mergeCells('A1:N1');
        $sheet->setCellValue('A1', 'SBKU — Attendance Records Report');
        $sheet->getStyle('A1')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 14, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1E40AF']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(28);

        // ── Subtitle / generation date ─────────────────────────────────────
        $sheet->mergeCells('A2:N2');
        $sheet->setCellValue('A2', 'Generated: ' . now()->format('D, d M Y  H:i'));
        $sheet->getStyle('A2')->applyFromArray([
            'font'      => ['italic' => true, 'size' => 10, 'color' => ['argb' => 'FF555555']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFDBEAFE']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
        ]);

        // ── Headers row ───────────────────────────────────────────────────
        $headers = [
            'A' => '#',
            'B' => 'Attendance Date',
            'C' => 'Student Name',
            'D' => 'Student Code',
            'E' => 'Faculty',
            'F' => 'Major',
            'G' => 'Year',
            'H' => 'Shift',
            'I' => 'Generation',
            'J' => 'Teacher',
            'K' => 'Status',
            'L' => 'Verified',
            'M' => 'Check-In Time',
            'N' => 'Notes',
        ];

        foreach ($headers as $col => $label) {
            $sheet->setCellValue("{$col}3", $label);
        }

        $sheet->getStyle('A3:N3')->applyFromArray([
            'font'      => ['bold' => true, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1D4ED8']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FFB0C4DE']]],
        ]);
        $sheet->getRowDimension(3)->setRowHeight(20);

        // ── Column widths ─────────────────────────────────────────────────
        $columnWidths = [
            'A' =>  5,  // #
            'B' => 16,  // Date
            'C' => 24,  // Student Name
            'D' => 15,  // Student Code
            'E' => 22,  // Faculty
            'F' => 22,  // Major
            'G' =>  8,  // Year
            'H' => 10,  // Shift
            'I' => 12,  // Generation
            'J' => 22,  // Teacher
            'K' => 12,  // Status
            'L' => 16,  // Verified
            'M' => 16,  // Check-In
            'N' => 28,  // Notes
        ];
        foreach ($columnWidths as $col => $width) {
            $sheet->getColumnDimension($col)->setWidth($width);
        }

        // ── Data rows ─────────────────────────────────────────────────────
        $row = 4;
        foreach ($this->records as $i => $record) {
            $student    = $record->student;
            $user       = $student?->user;
            $faculty    = $student?->faculty;
            $major      = $student?->major;
            $session    = $record->session;
            $teacher    = $session?->teacher?->user;

            // Status
            $status      = $record->status === 'Y' ? 'Present' : 'Absent';
            $verified    = ucfirst($record->verify_status ?? 'pending');
            $checkInTime = $record->check_in_time?->format('H:i:s') ?? '—';
            $date        = $record->attendance_date?->format('Y-m-d') ?? '—';

            $sheet->setCellValue("A{$row}", $i + 1);
            $sheet->setCellValue("B{$row}", $date);
            $sheet->setCellValue("C{$row}", $user?->name ?? 'Unknown');
            $sheet->setCellValue("D{$row}", $student?->student_code ?? $student?->id ?? '—');
            $sheet->setCellValue("E{$row}", $faculty?->name ?? $session?->faculty?->name ?? '—');
            $sheet->setCellValue("F{$row}", $major?->name  ?? $session?->major?->name  ?? '—');
            $sheet->setCellValue("G{$row}", $student?->year       ?? '—');
            $sheet->setCellValue("H{$row}", $student?->shift      ?? '—');
            $sheet->setCellValue("I{$row}", $student?->generation ?? '—');
            $sheet->setCellValue("J{$row}", $teacher?->name ?? '—');
            $sheet->setCellValue("K{$row}", $status);
            $sheet->setCellValue("L{$row}", $verified);
            $sheet->setCellValue("M{$row}", $checkInTime);
            $sheet->setCellValue("N{$row}", $record->noted ?? '');

            // Zebra striping
            $bgColor = ($i % 2 === 0) ? 'FFFAFAFA' : 'FFEFF6FF';
            $sheet->getStyle("A{$row}:N{$row}")->applyFromArray([
                'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => $bgColor]],
                'alignment' => ['vertical' => Alignment::VERTICAL_CENTER],
                'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FFD1D5DB']]],
            ]);

            // Status colour highlight
            $statusColor = $record->status === 'Y' ? 'FF16A34A' : 'FFDC2626';
            $sheet->getStyle("K{$row}")->getFont()->setColor(
                (new \PhpOffice\PhpSpreadsheet\Style\Color($statusColor))
            );
            $sheet->getStyle("K{$row}")->getFont()->setBold(true);

            // Verify status colour
            $verifyColor = match ($record->verify_status ?? 'pending') {
                'approved' => 'FF16A34A',
                'rejected' => 'FFDC2626',
                default    => 'FFD97706',  // orange for pending
            };
            $sheet->getStyle("L{$row}")->getFont()->setColor(
                (new \PhpOffice\PhpSpreadsheet\Style\Color($verifyColor))
            );

            // Center-align specific columns
            $sheet->getStyle("A{$row}:A{$row}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $sheet->getStyle("G{$row}:M{$row}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

            $sheet->getRowDimension($row)->setRowHeight(18);
            $row++;
        }

        // ── Summary row ───────────────────────────────────────────────────
        $totalRows     = $this->records->count();
        $presentCount  = $this->records->where('status', 'Y')->count();
        $absentCount   = $this->records->where('status', 'N')->count();
        $approvedCount = $this->records->where('verify_status', 'approved')->count();
        $pendingCount  = $this->records->where('verify_status', 'pending')->count();
        $rejectedCount = $this->records->where('verify_status', 'rejected')->count();
        $rate          = $totalRows > 0 ? round(($presentCount / $totalRows) * 100, 1) : 0;

        $summaryRow = $row + 1;
        $sheet->mergeCells("A{$summaryRow}:B{$summaryRow}");
        $sheet->setCellValue("A{$summaryRow}", 'SUMMARY');
        $sheet->mergeCells("C{$summaryRow}:D{$summaryRow}");
        $sheet->setCellValue("C{$summaryRow}", "Total: {$totalRows}");
        $sheet->mergeCells("E{$summaryRow}:F{$summaryRow}");
        $sheet->setCellValue("E{$summaryRow}", "Present: {$presentCount}  Absent: {$absentCount}  ({$rate}%)");
        $sheet->mergeCells("G{$summaryRow}:I{$summaryRow}");
        $sheet->setCellValue("G{$summaryRow}", "Approved: {$approvedCount}  Pending: {$pendingCount}  Rejected: {$rejectedCount}");

        $sheet->getStyle("A{$summaryRow}:N{$summaryRow}")->applyFromArray([
            'font'      => ['bold' => true, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1E40AF']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FF93C5FD']]],
        ]);
        $sheet->getRowDimension($summaryRow)->setRowHeight(22);

        // Freeze header rows
        $sheet->freezePane('A4');

        return $spreadsheet;
    }
}
