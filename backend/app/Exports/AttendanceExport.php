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
        $sheet->mergeCells('A1:J1');
        $sheet->setCellValue('A1', 'SBKU — Attendance Records Report');
        $sheet->getStyle('A1')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 14, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1E40AF']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(28);

        // ── Subtitle / generation date ─────────────────────────────────────
        $sheet->mergeCells('A2:J2');
        $sheet->setCellValue('A2', 'Generated: ' . now()->format('D, d M Y  H:i'));
        $sheet->getStyle('A2')->applyFromArray([
            'font'      => ['italic' => true, 'size' => 10, 'color' => ['argb' => 'FF555555']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFDBEAFE']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
        ]);

        // ── Headers row ───────────────────────────────────────────────────
        $headers = [
            'A' => '#',
            'B' => 'Date',
            'C' => 'Student info',
            'D' => 'Faculty / Major',
            'E' => 'Class info',
            'F' => 'Teacher',
            'G' => 'Status',
            'H' => 'Verify',
            'I' => 'Time',
            'J' => 'Notes',
        ];

        foreach ($headers as $col => $label) {
            $sheet->setCellValue("{$col}3", $label);
        }

        $sheet->getStyle('A3:J3')->applyFromArray([
            'font'      => ['bold' => true, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1D4ED8']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FFB0C4DE']]],
        ]);
        $sheet->getRowDimension(3)->setRowHeight(20);

        // ── Column widths ─────────────────────────────────────────────────
        $columnWidths = [
            'A' =>  5,  // #
            'B' => 12,  // Date
            'C' => 28,  // Student Name
            'D' => 28,  // Faculty / Major
            'E' => 18,  // Class info
            'F' => 22,  // Teacher
            'G' => 12,  // Status
            'H' => 12,  // Verify
            'I' => 10,  // Time
            'J' => 28,  // Notes
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
            
            // Student Info
            $studentInfo = ($user?->name ?? 'Unknown') . "\nID: " . ($student?->student_code ?? '—');
            $sheet->setCellValue("C{$row}", $studentInfo);
            $sheet->getStyle("C{$row}")->getAlignment()->setWrapText(true);

            // Faculty / Major
            $facName = $faculty?->name ?? $session?->faculty?->name ?? '—';
            $majName = $major?->name   ?? $session?->major?->name   ?? '—';
            $facMaj  = $facName . "\n" . $majName;
            $sheet->setCellValue("D{$row}", $facMaj);
            $sheet->getStyle("D{$row}")->getAlignment()->setWrapText(true);

            // Class info
            $classInfo = "Year: " . ($student?->year ?? '—') . "\nShift: " . ($student?->shift->name ?? '—');
            $sheet->setCellValue("E{$row}", $classInfo);
            $sheet->getStyle("E{$row}")->getAlignment()->setWrapText(true);

            $sheet->setCellValue("F{$row}", $teacher?->name ?? '—');
            $sheet->setCellValue("G{$row}", $status);
            $sheet->setCellValue("H{$row}", $verified);
            $sheet->setCellValue("I{$row}", $checkInTime);
            $sheet->setCellValue("J{$row}", $record->noted ?? '');

            // Zebra striping
            $bgColor = ($i % 2 === 0) ? 'FFFAFAFA' : 'FFEFF6FF';
            $sheet->getStyle("A{$row}:J{$row}")->applyFromArray([
                'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => $bgColor]],
                'alignment' => ['vertical' => Alignment::VERTICAL_CENTER],
                'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FFD1D5DB']]],
            ]);

            // Status colour highlight
            $statusColor = $record->status === 'Y' ? 'FF16A34A' : 'FFDC2626';
            $sheet->getStyle("G{$row}")->getFont()->setColor(
                (new \PhpOffice\PhpSpreadsheet\Style\Color($statusColor))
            );
            $sheet->getStyle("G{$row}")->getFont()->setBold(true);

            // Verify status colour
            $verifyColor = match ($record->verify_status ?? 'pending') {
                'approved' => 'FF16A34A',
                'rejected' => 'FFDC2626',
                default    => 'FFD97706',  // orange for pending
            };
            $sheet->getStyle("H{$row}")->getFont()->setColor(
                (new \PhpOffice\PhpSpreadsheet\Style\Color($verifyColor))
            );

            // Center-align specific columns
            $sheet->getStyle("A{$row}:A{$row}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $sheet->getStyle("G{$row}:I{$row}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

            $sheet->getRowDimension($row)->setRowHeight(36); // Taller for multiline
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
        $sheet->setCellValue("C{$summaryRow}", "Total Records: {$totalRows}");
        
        $sheet->mergeCells("E{$summaryRow}:G{$summaryRow}");
        $sheet->setCellValue("E{$summaryRow}", "Present: {$presentCount} | Absent: {$absentCount} | Rate: {$rate}%");
        
        $sheet->mergeCells("H{$summaryRow}:J{$summaryRow}");
        $sheet->setCellValue("H{$summaryRow}", "Appr: {$approvedCount} / Pend: {$pendingCount} / Rej: {$rejectedCount}");

        $sheet->getStyle("A{$summaryRow}:J{$summaryRow}")->applyFromArray([
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
