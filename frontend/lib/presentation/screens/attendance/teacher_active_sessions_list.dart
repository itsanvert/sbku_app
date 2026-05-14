import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:intl/intl.dart';

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
  // We use both Firestore (for real-time) and MySQL (for reliable fallback).
  Stream<List<Map<String, dynamic>>>? _sessionsStream;
  List<Map<String, dynamic>>? _localSessions;
  bool _isInitialSyncing = true;
  bool _useCloud = false; // Default to Local first as requested

  @override
  void initState() {
    super.initState();
    _initialSync();
  }

  Future<void> _initialSync() async {
    setState(() => _isInitialSyncing = true);
    
    // 1. Setup Firestore stream regardless of mode (so it's ready)
    _setupStream();
    
    // 2. Fetch from local MySQL
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.user;
      final teacherId = user?.teacherId;
      final role = user?.role?.toLowerCase() ?? '';

      if (teacherId != null || role == 'admin' || role == 'super_admin') {
        final filterId = (role == 'admin' || role == 'super_admin') ? null : teacherId;
        final data = await _service.getActiveSessions(teacherId: filterId);
        setState(() {
          _localSessions = data;
          _isInitialSyncing = false;
        });
      }
    } catch (e) {
      debugPrint('Initial MySQL fetch failed: $e');
      setState(() => _isInitialSyncing = false);
    }
  }

  void _toggleSource() {
    setState(() {
      _useCloud = !_useCloud;
    });
  }

  void _setupStream() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final teacherId = user?.teacherId;
    final role = user?.role?.toLowerCase() ?? '';

    if (teacherId != null || role == 'admin' || role == 'super_admin') {
      setState(() {
        // If admin, pass null to see ALL active sessions in Firestore
        final filterId = (role == 'admin' || role == 'super_admin') ? null : teacherId;
        _sessionsStream = _service.listenToActiveSessions(teacherId: filterId);
      });
    }
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return '--:--';
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return dateStr.toString();
    }
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('EEE, dd MMM').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('វេនកំពុងដំណើរការ'),
        actions: [
          // Source Toggle Indicator
          GestureDetector(
            onTap: _toggleSource,
            child: StreamBuilder(
              stream: _sessionsStream,
              builder: (context, snapshot) {
                bool isCloudActive = _useCloud;
                bool hasCloudData = snapshot.hasData && !snapshot.hasError;
                
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCloudActive 
                        ? (hasCloudData ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1))
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCloudActive 
                          ? (hasCloudData ? Colors.green : Colors.orange)
                          : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCloudActive ? Icons.cloud_done : Icons.storage,
                        size: 14,
                        color: isCloudActive 
                            ? (hasCloudData ? Colors.green : Colors.orange)
                            : Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isCloudActive ? 'Cloud' : 'Local',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCloudActive 
                              ? (hasCloudData ? Colors.green : Colors.orange)
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Manual refresh from MySQL (REST API)
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final teacherId = auth.user?.teacherId;
          if (teacherId != null) {
            await _service.getActiveSessions(teacherId: teacherId);
          }
          // Also restart the Firestore stream
          _initialSync();
        },
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _sessionsStream,
          builder: (context, snapshot) {
            // Determine which data to show: Firestore (Real-time) vs Local (MySQL Fallback)
            List<Map<String, dynamic>> rawList = [];
            bool isRealtime = false;
            
            if (_useCloud) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                rawList = snapshot.data!;
                isRealtime = true;
              } else {
                rawList = []; 
              }
            } else {
              rawList = _localSessions ?? [];
              isRealtime = false;
            }

            // ── Loading ─────────────────────────────────────────────
            if (_useCloud && snapshot.connectionState == ConnectionState.waiting && rawList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ── Error ───────────────────────────────────────────────
            if (_useCloud && snapshot.hasError && rawList.isEmpty) {
              final errorMsg = snapshot.error.toString();
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off,
                            size: 48,
                            color: isDark ? Colors.redAccent.shade100 : Colors.red[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'មិនអាចភ្ជាប់ទៅកាន់សេវាកម្មបានទេ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Local error: ${_localSessions == null ? "Fetch failed" : "No sessions found"}\nCloud: $errorMsg',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: theme.hintColor),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _initialSync,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('ព្យាយាមម្តងទៀត'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final now = DateTime.now();

            // Filter only sessions that are active AND not expired
            final sessions = rawList.where((s) {
              final isActive = s['is_active'] == true || s['is_active'] == 1 || s['is_active'] == '1';
              if (!isActive) return false;

              // Check expiration if available
              final expiresAtStr = s['expires_at'];
              if (expiresAtStr != null && expiresAtStr.toString().isNotEmpty) {
                try {
                  final expiresAt = DateTime.parse(expiresAtStr.toString());
                  if (expiresAt.isBefore(now)) return false;
                } catch (_) {}
              }
              return true;
            }).toList();

            // Sort by started_at descending (newest first)
            sessions.sort((a, b) {
              final aTime = DateTime.tryParse(a['started_at']?.toString() ?? '') ?? DateTime(2000);
              final bTime = DateTime.tryParse(b['started_at']?.toString() ?? '') ?? DateTime(2000);
              return bTime.compareTo(aTime);
            });

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
                final isActive =
                    session['is_active'] == true || session['is_active'] == 1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive
                          ? Colors.green.withOpacity(isDark ? 0.15 : 0.1)
                          : Colors.grey.withOpacity(isDark ? 0.15 : 0.1),
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
                              color: Colors.green.withOpacity(0.15),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$facultyName • ${_formatDate(startedAt)}\n$checkedIn នាក់បានចូលរួម\nម៉ោងចាប់ផ្តើម: ${_formatTime(startedAt)}',
                          style: TextStyle(
                            height: 1.5,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (session['_source'] == 'firestore' || isRealtime)
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (session['_source'] == 'firestore' || isRealtime) ? 'Live Cloud' : 'Local System',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: (session['_source'] == 'firestore' || isRealtime)
                                  ? Colors.blue.shade300
                                  : Colors.orange.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherActiveSessionScreen(
                            sessionId: session['id'].toString(),
                            qrToken: session['qr_token'] ?? '',
                          ),
                        ),
                      );
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
}
