import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TeacherActiveSessionScreen extends StatefulWidget {
  final int sessionId;
  final String qrToken;

  const TeacherActiveSessionScreen({
    super.key,
    required this.sessionId,
    required this.qrToken,
  });

  @override
  State<TeacherActiveSessionScreen> createState() =>
      _TeacherActiveSessionScreenState();
}

class _TeacherActiveSessionScreenState
    extends State<TeacherActiveSessionScreen> {
  final AttendanceService _service = AttendanceService();
  Map<String, dynamic>? _sessionData;
  List<Map<String, dynamic>> _checkedInStudents = [];
  bool _isLoading = true;
  bool _isEnding = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSession();
    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadSession(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSession({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final data = await _service.getSession(widget.sessionId);
      final attendances = (data['attendances'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];

      if (mounted) {
        setState(() {
          _sessionData = data;
          _checkedInStudents = attendances
              .where((a) => a['status'] == 'Y')
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _endSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('បិទវេនវត្តមាន?'),
        content: const Text(
            'សិស្សដែលមិនបានស្កេន QR នឹងត្រូវកត់ត្រាជាអវត្តមាន។'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('បោះបង់')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('បិទវេន',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isEnding = true);

    try {
      final result = await _service.endSession(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'វេនបានបិទ។ មានវត្តមាន: ${result['total_present']} | អវត្តមាន: ${result['total_absent']}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isEnding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate QR data for students to scan
    final qrData = jsonEncode({
      'session_id': widget.sessionId,
      'qr_token': widget.qrToken,
    });

    return Scaffold(
      appBar: AppBarWidget(title: 'វេនវត្តមានកំពុងដំណើរការ'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // QR Code card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'សូមឱ្យសិស្សស្កេន QR កូដនេះ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'ចាប់ផ្តើម: ${_formatTime(_sessionData?['started_at'])}',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Checked-in count
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'សិស្សបានចុះវត្តមាន: ${_checkedInStudents.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Checked-in student list
                  Expanded(
                    child: _checkedInStudents.isEmpty
                        ? const Center(
                            child: Text('មិនទាន់មានសិស្សចុះវត្តមាន',
                                style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.builder(
                            itemCount: _checkedInStudents.length,
                            itemBuilder: (context, index) {
                              final a = _checkedInStudents[index];
                              final student = a['student'];
                              final name = student?['user']?['name'] ??
                                  student?['name'] ??
                                  a['student_name'] ??
                                  'Student';
                              final checkIn = a['check_in_time'] ?? '';

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                    style:
                                        TextStyle(color: Colors.green[700]),
                                  ),
                                ),
                                title: Text(name),
                                subtitle: Text('ចូល: $checkIn',
                                    style: const TextStyle(fontSize: 12)),
                                trailing: const Icon(Icons.check,
                                    color: Colors.green),
                              );
                            },
                          ),
                  ),

                  // End session button
                  ElevatedButton(
                    onPressed: _isEnding ? null : _endSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isEnding
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text(
                            'បិទវេនវត្តមាន',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '--:--';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTimeStr;
    }
  }
}
