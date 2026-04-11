import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';

class TeacherActiveSessionsListScreen extends StatefulWidget {
  const TeacherActiveSessionsListScreen({super.key});

  @override
  State<TeacherActiveSessionsListScreen> createState() =>
      _TeacherActiveSessionsListScreenState();
}

class _TeacherActiveSessionsListScreenState
    extends State<TeacherActiveSessionsListScreen> {
  final AttendanceService _service = AttendanceService();
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _service.getActiveSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarWidget.simple(title: 'វេនកំពុងដំណើរការ'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            )
          : _sessions.isEmpty
              ? Center(
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
                )
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  color: theme.primaryColor,
                  child: ListView.builder(
                    itemCount: _sessions.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      final teacherName = session['teacher_name'] ??
                          session['teacher']?['user']?['name'] ??
                          'Teacher';
                      final facultyName = session['faculty']?['name'] ?? '';
                      final checkedIn = session['attendances_count'] ?? 0;
                      final startedAt = session['started_at'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(
                              isDark ? 0.15 : 0.1,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: isDark
                                  ? Colors.green.shade300
                                  : Colors.green[700],
                            ),
                          ),
                          title: Text(
                            teacherName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          subtitle: Text(
                            '$facultyName\n$checkedIn នាក់បានចូលរួម\nចាប់ផ្តើម: $startedAt',
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
                            ).then((_) => _loadSessions());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
