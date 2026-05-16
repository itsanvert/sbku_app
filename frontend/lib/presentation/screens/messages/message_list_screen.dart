import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/service/message_service.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/screens/attendance/qr_scan_attendance_screen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final MessageService _messageService = MessageService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBarWidget.simple(title: 'សារជូនដំណឹង'),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _messageService.listenToMessages(userId: user?.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            if (error.contains('permission-denied')) {
              return _buildPermissionError();
            }
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Error: $error', textAlign: TextAlign.center),
            ));
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('គ្មានសារថ្មីទេ',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: messages.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final msg = messages[index];
              return _buildMessageCard(msg);
            },
          );
        },
      ),
    );
  }

  Widget _buildPermissionError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person_outlined,
                size: 80, color: Colors.orange.withOpacity(0.5)),
            const SizedBox(height: 24),
            const Text(
              'រកមិនឃើញទិន្នន័យ ឬមិនមានការអនុញ្ញាត',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('ព្យាយាមម្ដងទៀត'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> msg) {
    final title = msg['title'] ?? 'No Title';
    final body = msg['body'] ?? '';
    final createdAt = msg['created_at'];
    final type = msg['type'] ?? 'info';
    final metadata = msg['metadata'] ?? {};

    DateTime? date;
    if (createdAt != null) {
      date = DateTime.tryParse(createdAt.toString());
    }

    final isAttendance =
        type == 'alert' && metadata['type'] == 'attendance_session_started';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: isAttendance ? Colors.blue.withOpacity(0.05) : null,
      child: InkWell(
        onTap: () => _showMessageDetail(msg),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(type, metadata),
                  color: _getTypeColor(type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (date != null)
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isAttendance) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ចុចដើម្បីចុះវត្តមាន',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDetail(Map<String, dynamic> msg) {
    final metadata = msg['metadata'] ?? {};
    final isAttendance = msg['type'] == 'alert' &&
        metadata['type'] == 'attendance_session_started';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                msg['title'] ?? 'No Title',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                msg['created_at'] != null
                    ? DateFormat('dd MMM yyyy, hh:mm a')
                        .format(DateTime.parse(msg['created_at']))
                    : '',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const Divider(height: 32),
              Text(
                msg['body'] ?? '',
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
              if (isAttendance) ...[
                const SizedBox(height: 24),
                _buildAttendanceDetails(metadata),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const QrScanAttendanceScreen()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('ចុះវត្តមានឥឡូវនេះ (Scan QR)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceDetails(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _detailRow(Icons.book, 'មុខវិជ្ជា', data['subject_name'] ?? '—'),
          _detailRow(Icons.school, 'ជំនាញ', data['major_name'] ?? '—'),
          _detailRow(Icons.schedule, 'វេន', data['shift_name'] ?? '—'),
          _detailRow(Icons.access_time, 'ម៉ោងសិក្សា', data['time_slot'] ?? '—'),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type, Map metadata) {
    if (type == 'alert' && metadata['type'] == 'attendance_session_started') {
      return Icons.notifications_active;
    }
    switch (type) {
      case 'announcement':
        return Icons.campaign;
      case 'private':
        return Icons.person;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'announcement':
        return Colors.purple;
      case 'private':
        return Colors.blue;
      case 'alert':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat('h:mm a').format(date);
    }
    return DateFormat('dd MMM').format(date);
  }
}
