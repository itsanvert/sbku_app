import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';

class QrScanAttendanceScreen extends StatefulWidget {
  const QrScanAttendanceScreen({super.key});

  @override
  State<QrScanAttendanceScreen> createState() => _QrScanAttendanceScreenState();
}

class _QrScanAttendanceScreenState extends State<QrScanAttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _resultMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    try {
      final qrData = jsonDecode(rawValue);
      final sessionId = qrData['session_id'];
      final qrToken = qrData['qr_token'];

      if (sessionId == null || qrToken == null) {
        throw Exception('QR code មិនត្រឹមត្រូវ');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user == null) {
        throw Exception('សូមចូលគណនីជាមុន');
      }

      final studentId = user.id;

      final result = await _attendanceService.checkInWithQr(
        sessionId: sessionId is int ? sessionId : int.parse(sessionId.toString()),
        studentId: studentId is int ? studentId : int.parse(studentId.toString()),
        qrToken: qrToken.toString(),
      );

      setState(() {
        _resultMessage = result['message'] ?? 'ចុះវត្តមានជោគជ័យ!';
        _isSuccess = true;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _resultMessage = e.toString().replaceAll('Exception: ', '');
        _isSuccess = false;
        _isProcessing = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _resultMessage = null;
      _isSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'ស្កេន QR កូដ'),
      body: _hasScanned ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ដាក់ QR កូដនៅក្នុងប្រអប់ដើម្បីស្កេន',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'កំពុងចុះវត្តមាន...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSuccess ? Icons.check_circle : Icons.error,
              size: 100,
              color: _isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              _isSuccess ? 'ជោគជ័យ!' : 'មានបញ្ហា',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isSuccess ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _resultMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (_isSuccess)
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check),
                label: const Text('រួចរាល់'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: _resetScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('ស្កេនម្ដងទៀត'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ថយក្រោយ'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
