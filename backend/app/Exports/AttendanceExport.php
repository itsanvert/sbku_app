<?php

namespace App\Exports;

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Color;
use Illuminate\Support\Collection;

/**
 * AttendanceExport
 *
 * Generates a styled XLSX file using PhpSpreadsheet directly.
 * Visual design mirrors the PDF attendance report template.
 *
 * Columns exported:
 *   #, Date, Student Name / ID, Faculty / Major,
 *   Year & Shift, Teacher, Status, Verified, Check-In Time, Notes
 */
class AttendanceExport
{
    protected Collection $records;
    protected string     $reportedBy;
    protected string     $filterInfo;

    public function __construct($records, string $reportedBy = 'System', string $filterInfo = 'All records')
    {
        // Accept Paginator, Collection, or plain array
        if (method_exists($records, 'getCollection')) {
            $this->records = $records->getCollection();
        } elseif ($records instanceof Collection) {
            $this->records = $records;
        } else {
            $this->records = collect($records);
        }

        $this->reportedBy = $reportedBy;
        $this->filterInfo = $filterInfo;
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
            ->setCreator($this->reportedBy)
            ->setDescription('Exported on ' . now()->format('Y-m-d H:i:s'));

        // ═══════════════════════════════════════════════════════════════════
        // ROW 1 — University branding title (navy #1a1a2e, like PDF header)
        // ═══════════════════════════════════════════════════════════════════
        $sheet->mergeCells('A1:J1');
        $sheet->setCellValue('A1', 'SBKU — Attendance Records Report');
        $sheet->getStyle('A1')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 14, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1a1a2e']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(32);

        // ═══════════════════════════════════════════════════════════════════
        // ROW 2 — Orange reporter banner (mirrors PDF reporter-banner)
        // ═══════════════════════════════════════════════════════════════════
        $sheet->mergeCells('A2:J2');
        $reporterText = 'Reported by: ' . $this->reportedBy
            . '    |    Filter: ' . $this->filterInfo
            . '    |    Total Records: ' . $this->records->count()
            . '    |    Generated: ' . now()->format('d M Y, H:i');
        $sheet->setCellValue('A2', $reporterText);
        $sheet->getStyle('A2')->applyFromArray([
            'font'      => ['italic' => true, 'size' => 9, 'color' => ['argb' => 'FF7C2D00']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFFFF8F4']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_LEFT, 'indent' => 2],
            'borders'   => [
                'left'   => ['borderStyle' => Border::BORDER_MEDIUM, 'color' => ['argb' => 'FFFF5E00']],
                'bottom' => ['borderStyle' => Border::BORDER_THIN,   'color' => ['argb' => 'FFFFD5B8']],
            ],
        ]);
        $sheet->getRowDimension(2)->setRowHeight(18);

        // ═══════════════════════════════════════════════════════════════════
        // ROW 3 — Summary KPI strip (matches PDF summary cards)
        // ═══════════════════════════════════════════════════════════════════
        $total      = $this->records->count();
        $present    = $this->records->where('status', 'Y')->count();
        $permission = $this->records->where('status', 'P')->count();
        $absent     = $this->records->where('status', 'N')->count();
        $rate       = $total > 0 ? round(($present / $total) * 100, 1) : 0;

        $sheet->mergeCells('A3:B3');
        $sheet->setCellValue('A3', "Total: {$total}");
        $sheet->getStyle('A3:B3')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 10, 'color' => ['argb' => 'FF6366F1']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFF5F3FF']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['top' => ['borderStyle' => Border::BORDER_MEDIUM, 'color' => ['argb' => 'FF6366F1']]],
        ]);

        $sheet->mergeCells('C3:D3');
        $sheet->setCellValue('C3', "Present: {$present} ({$rate}%)");
        $sheet->getStyle('C3:D3')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 10, 'color' => ['argb' => 'FF15803D']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFF0FDF4']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['top' => ['borderStyle' => Border::BORDER_MEDIUM, 'color' => ['argb' => 'FF22C55E']]],
        ]);

        $sheet->mergeCells('E3:G3');
        $sheet->setCellValue('E3', "Permission: {$permission}");
        $sheet->getStyle('E3:G3')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 10, 'color' => ['argb' => 'FFB45309']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFFEFCE8']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['top' => ['borderStyle' => Border::BORDER_MEDIUM, 'color' => ['argb' => 'FFF59E0B']]],
        ]);

        $sheet->mergeCells('H3:J3');
        $absentPct = $total > 0 ? round(($absent / $total) * 100, 1) : 0;
        $sheet->setCellValue('H3', "Absent: {$absent} ({$absentPct}%)");
        $sheet->getStyle('H3:J3')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 10, 'color' => ['argb' => 'FFB91C1C']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFFEF2F2']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['top' => ['borderStyle' => Border::BORDER_MEDIUM, 'color' => ['argb' => 'FFEF4444']]],
        ]);

        $sheet->getRowDimension(3)->setRowHeight(22);

        // ═══════════════════════════════════════════════════════════════════
        // ROW 4 — Column headers (navy, like PDF thead)
        // ═══════════════════════════════════════════════════════════════════
        $headers = [
            'A' => '#',
            'B' => 'Date',
            'C' => 'Student',
            'D' => 'Faculty / Major',
            'E' => 'Year & Shift',
            'F' => 'Teacher',
            'G' => 'Status',
            'H' => 'Verify',
            'I' => 'Check-in',
            'J' => 'Notes',
        ];

        foreach ($headers as $col => $label) {
            $sheet->setCellValue("{$col}4", $label);
        }

        $sheet->getStyle('A4:J4')->applyFromArray([
            'font'      => ['bold' => true, 'size' => 10, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1a1a2e']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FF374151']]],
        ]);
        $sheet->getRowDimension(4)->setRowHeight(22);

        // ── Column widths ─────────────────────────────────────────────────
        $columnWidths = [
            'A' =>  5,   // #
            'B' => 13,   // Date
            'C' => 30,   // Student
            'D' => 30,   // Faculty / Major
            'E' => 18,   // Year & Shift
            'F' => 24,   // Teacher
            'G' => 13,   // Status
            'H' => 13,   // Verify
            'I' => 11,   // Check-in
            'J' => 28,   // Notes
        ];
        foreach ($columnWidths as $col => $width) {
            $sheet->getColumnDimension($col)->setWidth($width);
        }

        // ═══════════════════════════════════════════════════════════════════
        // DATA ROWS — starting at row 5
        // ═══════════════════════════════════════════════════════════════════
        $row = 5;
        foreach ($this->records as $i => $record) {
            $student  = $record->student;
            $user     = $student?->user;
            $faculty  = $student?->faculty;
            $major    = $student?->major;
            $session  = $record->session;
            $teacher  = $session?->teacher?->user;

            $statusRaw   = $record->status ?? 'N';
            $statusLabel = match ($statusRaw) {
                'Y'     => 'Present',
                'P'     => 'Permission',
                default => 'Absent',
            };
            $verified    = ucfirst($record->verify_status ?? 'pending');
            $checkInTime = $record->check_in_time?->format('H:i') ?? '—';
            $date        = $record->attendance_date?->format('d M Y') ?? '—';

            // ── Cell values ───────────────────────────────────────────────
            $sheet->setCellValue("A{$row}", $i + 1);
            $sheet->setCellValue("B{$row}", $date);

            $studentInfo = ($user?->name ?? 'Unknown') . "\nID: " . ($student?->student_code ?? '—');
            $sheet->setCellValue("C{$row}", $studentInfo);
            $sheet->getStyle("C{$row}")->getAlignment()->setWrapText(true);

            $facName = $faculty?->name ?? $session?->faculty?->name ?? '—';
            $majName = $major?->name   ?? $session?->major?->name   ?? '—';
            $sheet->setCellValue("D{$row}", $facName . "\n" . $majName);
            $sheet->getStyle("D{$row}")->getAlignment()->setWrapText(true);

            $classInfo = 'Year: ' . ($student?->year ?? '—') . "\nShift: " . ($student?->shift?->name ?? '—');
            $sheet->setCellValue("E{$row}", $classInfo);
            $sheet->getStyle("E{$row}")->getAlignment()->setWrapText(true);

            $sheet->setCellValue("F{$row}", $teacher?->name ?? '—');
            $sheet->setCellValue("G{$row}", $statusLabel);
            $sheet->setCellValue("H{$row}", $verified);
            $sheet->setCellValue("I{$row}", $checkInTime);
            $sheet->setCellValue("J{$row}", $record->noted ?? '');

            // ── Zebra striping ────────────────────────────────────────────
            $bgColor = ($i % 2 === 0) ? 'FFFFFFFF' : 'FFF9FAFB';
            $sheet->getStyle("A{$row}:J{$row}")->applyFromArray([
                'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => $bgColor]],
                'alignment' => ['vertical' => Alignment::VERTICAL_CENTER],
                'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FFE5E7EB']]],
                'font'      => ['size' => 10, 'color' => ['argb' => 'FF374151']],
            ]);

            // ── Status badge color ────────────────────────────────────────
            $statusColor = match ($statusRaw) {
                'Y'     => 'FF15803D',
                'P'     => 'FFB45309',
                default => 'FFB91C1C',
            };
            $sheet->getStyle("G{$row}")->getFont()->setColor(new Color($statusColor));
            $sheet->getStyle("G{$row}")->getFont()->setBold(true);

            // ── Verify badge color ────────────────────────────────────────
            $verifyColor = match ($record->verify_status ?? 'pending') {
                'approved' => 'FF15803D',
                'rejected' => 'FFB91C1C',
                default    => 'FFB45309',
            };
            $sheet->getStyle("H{$row}")->getFont()->setColor(new Color($verifyColor));

            // ── Alignment ─────────────────────────────────────────────────
            $sheet->getStyle("A{$row}")->getAlignment()
                ->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $sheet->getStyle("G{$row}:I{$row}")->getAlignment()
                ->setHorizontal(Alignment::HORIZONTAL_CENTER);

            $sheet->getRowDimension($row)->setRowHeight(36);
            $row++;
        }

        // ═══════════════════════════════════════════════════════════════════
        // FOOTER ROW — approved / pending / rejected counts (navy, like PDF)
        // ═══════════════════════════════════════════════════════════════════
        $approvedCount = $this->records->where('verify_status', 'approved')->count();
        $pendingCount  = $this->records->where('verify_status', 'pending')->count();
        $rejectedCount = $this->records->where('verify_status', 'rejected')->count();

        $footerRow = $row + 1;

        $sheet->mergeCells("A{$footerRow}:B{$footerRow}");
        $sheet->setCellValue("A{$footerRow}", 'SUMMARY');

        $sheet->mergeCells("C{$footerRow}:D{$footerRow}");
        $sheet->setCellValue("C{$footerRow}", "Records: {$total}  |  Rate: {$rate}%");

        $sheet->mergeCells("E{$footerRow}:G{$footerRow}");
        $sheet->setCellValue("E{$footerRow}", "Present: {$present}  |  Permission: {$permission}  |  Absent: {$absent}");

        $sheet->mergeCells("H{$footerRow}:J{$footerRow}");
        $sheet->setCellValue("H{$footerRow}", "Appr: {$approvedCount}  /  Pend: {$pendingCount}  /  Rej: {$rejectedCount}");

        $sheet->getStyle("A{$footerRow}:J{$footerRow}")->applyFromArray([
            'font'      => ['bold' => true, 'size' => 10, 'color' => ['argb' => 'FFFFFFFF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1a1a2e']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
            'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['argb' => 'FF374151']]],
        ]);
        $sheet->getRowDimension($footerRow)->setRowHeight(22);

        // ── Generated-by credit row ────────────────────────────────────────
        $creditRow = $footerRow + 1;
        $sheet->mergeCells("A{$creditRow}:J{$creditRow}");
        $sheet->setCellValue("A{$creditRow}",
            'SBKU Attendance Management System  —  Reported by: ' . $this->reportedBy
            . '  —  ' . now()->format('d M Y, H:i:s')
        );
        $sheet->getStyle("A{$creditRow}:J{$creditRow}")->applyFromArray([
            'font'      => ['italic' => true, 'size' => 8, 'color' => ['argb' => 'FF9CA3AF']],
            'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFF9FAFB']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            'borders'   => ['bottom' => ['borderStyle' => Border::BORDER_MEDIUM, 'color' => ['argb' => 'FFFF5E00']]],
        ]);
        $sheet->getRowDimension($creditRow)->setRowHeight(16);

        // Freeze header + summary rows so data scrolls underneath
        $sheet->freezePane('A5');

        return $spreadsheet;
    }
}
