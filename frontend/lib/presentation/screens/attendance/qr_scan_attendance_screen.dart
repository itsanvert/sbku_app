import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/screens/attendance/student_attendance_status_screen.dart';

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
  String _verifyStatus = 'pending'; // pending | approved | rejected

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
        // Read verify_status from the attendance record
        _verifyStatus =
            result['attendance']?['verify_status']?.toString() ?? 'pending';
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
    // Determine verify status display
    final isApproved = _verifyStatus == 'approved';
    final isPending = _verifyStatus == 'pending';

    Color statusColor = isPending
        ? Colors.orange
        : (isApproved ? Colors.green : Colors.red);
    IconData statusIcon = isPending
        ? Icons.pending_actions
        : (isApproved ? Icons.verified : Icons.cancel);
    String statusLabel = isPending
        ? 'រង់ចាំការអនុម័ត'
        : (isApproved ? 'បានអនុម័ត' : 'បានបដិសេធ');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main result icon
            Icon(
              _isSuccess ? Icons.check_circle : Icons.error,
              size: 90,
              color: _isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _isSuccess ? 'ជោគជ័យ!' : 'មានបញ្ហា',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isSuccess ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _resultMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            // Verify status badge (only on success)
            if (_isSuccess) ...[  
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'គ្រូនឹងអនុម័ត ឬ បដិសេធ ការចូលរួមរបស់អ្នក',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
            ],

            const SizedBox(height: 32),

            if (_isSuccess) ...[  
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check),
                label: const Text('រួចរាល់'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentAttendanceStatusScreen(),
                  ),
                ),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('មើលស្ថានភាពវត្តមានរបស់ខ្ញុំ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _resetScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('ស្កេនម្ដងទៀត'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
