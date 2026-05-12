import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:intl/intl.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TeacherActiveSessionsListScreen extends StatefulWidget {
  const TeacherActiveSessionsListScreen({super.key});

  @override
  State<TeacherActiveSessionsListScreen> createState() =>
      _TeacherActiveSessionsListScreenState();
}

class _TeacherActiveSessionsListScreenState
    extends State<TeacherActiveSessionsListScreen> {
  final AttendanceService _service = AttendanceService();

  // ── Database Source ────────────────────────────────────────────────────────
  // We use the REST API (MySQL) first as requested. The Firestore stream 
  // is available for real-time migration later.
  Future<List<Map<String, dynamic>>>? _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshSessions();
  }

  void _refreshSessions() {
    // Access teacherId from Provider
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final teacherId = auth.user?.teacherId;
    
    if (teacherId != null) {
      setState(() {
        _sessionsFuture = _service.getActiveSessions(teacherId: teacherId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarWidget.simple(title: 'វេនកំពុងដំណើរការ'),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshSessions();
          await _sessionsFuture;
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            // ── Loading ─────────────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              );
            }

            // ── Error ───────────────────────────────────────────────
            if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48,
                            color: isDark
                                ? Colors.redAccent.shade100
                                : Colors.red[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to load sessions (MySQL)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(snapshot.error.toString(), 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final sessions = snapshot.data ?? [];

            // ── Empty ───────────────────────────────────────────────
            if (sessions.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: isDark
                              ? const Color(0xFF475569)
                              : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'មិនមានវេនកំពុងដំណើរការ',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // ── Session List ────────────────────────────────────────
            return ListView.builder(
              itemCount: sessions.length,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final teacherName = session['teacher_name'] ??
                    session['teacher']?['user']?['name'] ??
                    'Teacher';
                final facultyName = session['faculty']?['name'] ?? '';
                final checkedIn = session['attendances_count'] ?? 0;
                final startedAt = session['started_at'] ?? '';
                final isActive = session['is_active'] == true || session['is_active'] == 1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive
                          ? Colors.green.withValues(
                              alpha: isDark ? 0.15 : 0.1,
                            )
                          : Colors.grey.withValues(
                              alpha: isDark ? 0.15 : 0.1,
                            ),
                      child: Icon(
                        isActive ? Icons.check_circle : Icons.pause_circle,
                        color: isActive
                            ? (isDark
                                ? Colors.green.shade300
                                : Colors.green[700])
                            : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey[600]),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacherName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.green.shade300
                                        : Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '$facultyName • ${_formatDate(startedAt)}\n$checkedIn នាក់បានចូលរួម\nម៉ោងចាប់ផ្តើម: ${_formatTime(startedAt)}',
                      style: TextStyle(
                        height: 1.5,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherActiveSessionScreen(
                            sessionId: session['id'],
                            qrToken: session['qr_token'] ?? '',
                          ),
                        ),
                      ).then((_) => _refreshSessions());
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '--:--';
    try {
      if (dateTimeStr.length <= 8 && dateTimeStr.contains(':')) {
        final now = DateTime.now();
        final datePrefix = DateFormat('yyyy-MM-dd').format(now);
        dateTimeStr = '$datePrefix $dateTimeStr';
      }
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return dateTimeStr ?? '--:--';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
