<?php

namespace App\Services;

use Barryvdh\DomPDF\Facade\Pdf;

class PdfRenderer
{
    /**
     * Render a Blade view to a PDF binary string.
     *
     * Prefers headless Chrome so Khmer (and other complex-script) text is
     * rendered with proper glyph shaping and vowel stacking, which DomPDF
     * cannot do. Falls back to DomPDF when no Chrome/Edge binary is found.
     */
    public static function render(string $view, array $data = [], string $paper = 'a4', string $orientation = 'landscape'): string
    {
        $html = view($view, $data)->render();

        $chrome = static::findChrome();
        if ($chrome !== null) {
            $pdf = static::renderWithChrome($chrome, $html);
            if ($pdf !== null) {
                return $pdf;
            }
        }

        return static::renderWithDomPdf($html, $paper, $orientation);
    }

    protected static function findChrome(): ?string
    {
        if ($env = getenv('CHROME_BIN')) {
            return is_file($env) ? $env : null;
        }

        $candidates = [
            'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
            'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
            getenv('LOCALAPPDATA').'\\Google\\Chrome\\Application\\chrome.exe',
            'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
            'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
            '/usr/bin/google-chrome',
            '/usr/bin/google-chrome-stable',
            '/usr/bin/chromium',
            '/usr/bin/chromium-browser',
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
            '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge',
        ];

        foreach ($candidates as $candidate) {
            if (is_file($candidate)) {
                return $candidate;
            }
        }

        return null;
    }

    protected static function renderWithChrome(string $chrome, string $html): ?string
    {
        $tmp = sys_get_temp_dir();
        $htmlFile = $tmp.DIRECTORY_SEPARATOR.'sbku_pdf_'.uniqid().'.html';
        $pdfFile = $tmp.DIRECTORY_SEPARATOR.'sbku_pdf_'.uniqid().'.pdf';
        $profile = $tmp.DIRECTORY_SEPARATOR.'sbku_chrome_'.uniqid();

        try {
            file_put_contents($htmlFile, static::toFileUrls($html));

            $args = [
                escapeshellarg($chrome),
                '--headless=new',
                '--disable-gpu',
                '--no-sandbox',
                '--disable-dev-shm-usage',
                '--run-all-compositor-stages-before-draw',
                '--virtual-time-budget=10000',
                '--print-to-pdf-no-header',
                '--user-data-dir='.escapeshellarg($profile),
                '--print-to-pdf='.escapeshellarg($pdfFile),
                escapeshellarg('file:///'.str_replace('\\', '/', $htmlFile)),
            ];

            $nullDevice = DIRECTORY_SEPARATOR === '\\' ? 'NUL' : '/dev/null';
            $process = proc_open(implode(' ', $args), [
                1 => ['file', $nullDevice, 'w'],
                2 => ['file', $nullDevice, 'w'],
            ], $pipes);
            if (! is_resource($process)) {
                return null;
            }

            $exitCode = proc_close($process);

            if ($exitCode !== 0 || ! is_file($pdfFile)) {
                return null;
            }

            return file_get_contents($pdfFile);
        } catch (\Throwable $e) {
            \Log::warning('Chrome PDF render failed: '.$e->getMessage());

            return null;
        } finally {
            @unlink($htmlFile);
            @unlink($pdfFile);
            static::removeDirectory($profile);
        }
    }

    protected static function renderWithDomPdf(string $html, string $paper, string $orientation): string
    {
        $pdf = Pdf::loadHTML($html);
        $pdf->setPaper($paper, $orientation);

        return $pdf->output();
    }

    /**
     * Convert absolute filesystem paths (e.g. from public_path()) into
     * file:/// URLs so Chrome can resolve fonts and images from disk.
     */
    protected static function toFileUrls(string $html): string
    {
        return preg_replace_callback(
            '~(?<![A-Za-z0-9/:\\\\])[A-Za-z]:[\\\\/][^"\')<\s]+~',
            fn ($m) => 'file:///'.str_replace('\\', '/', $m[0]),
            $html
        );
    }

    protected static function removeDirectory(string $dir): void
    {
        if (! is_dir($dir)) {
            return;
        }

        $items = new \FilesystemIterator($dir, \FilesystemIterator::SKIP_DOTS);
        foreach ($items as $item) {
            $item->isDir() ? static::removeDirectory($item->getPathname()) : @unlink($item->getPathname());
        }

        @rmdir($dir);
    }
}
