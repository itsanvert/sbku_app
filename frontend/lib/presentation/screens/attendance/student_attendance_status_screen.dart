import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';

/// Student Attendance Verification Status Screen
class StudentAttendanceStatusScreen extends StatefulWidget {
  const StudentAttendanceStatusScreen({super.key});

  @override
  State<StudentAttendanceStatusScreen> createState() =>
      _StudentAttendanceStatusScreenState();
}

class _StudentAttendanceStatusScreenState
    extends State<StudentAttendanceStatusScreen> {
  final AttendanceService _service = AttendanceService();

  List<Map<String, dynamic>> _records = [];
  Map<String, dynamic>? _summary;
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;

  int get _pendingCount => (_summary?['pending'] ?? 0) as int;
  int get _approvedCount => (_summary?['approved'] ?? 0) as int;
  int get _rejectedCount => (_summary?['rejected'] ?? 0) as int;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadHistory(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user == null) throw Exception('Not authenticated');

      final int sid = user.studentId ??
          (user.id is int ? user.id as int : int.parse(user.id.toString()));

      final result = await _service.getStudentHistory(sid);

      final attendances = result['attendances'];
      final data = (attendances?['data'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];

      if (mounted) {
        setState(() {
          _records = data;
          _summary = result['summary'] != null
              ? Map<String, dynamic>.from(result['summary'])
              : null;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Scaffold(
      appBar: AppBarWidget.simple(title: 'ស្ថានភាពវត្តមានរបស់ខ្ញុំ'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _error != null && _records.isEmpty
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: primary,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(primary)),
                      SliverToBoxAdapter(child: _buildStatsRow()),
                      if (_pendingCount > 0)
                        SliverToBoxAdapter(child: _buildPendingBanner()),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        sliver: _records.isEmpty
                            ? SliverFillRemaining(
                                child: Center(
                                  child: Text(
                                    'មិនមានប្រវត្តិវត្តមាន',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, i) => _buildRecordCard(_records[i]),
                                  childCount: _records.length,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ── Header gradient card ─────────────────────────────────────
  Widget _buildHeader(Color primary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFF8C00), const Color(0xFFFF6000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.orange.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.how_to_reg,
            color: isDark ? primary : Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ការផ្ទៀងផ្ទាត់វត្តមាន',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'មើលស្ថានភាពការចូលរួមរបស់អ្នក',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _miniStatCard(
              'រង់ចាំ', _pendingCount, Colors.orange, Icons.pending_actions),
          const SizedBox(width: 8),
          _miniStatCard(
              'អនុម័ត', _approvedCount, Colors.green, Icons.check_circle),
          const SizedBox(width: 8),
          _miniStatCard('បដិសេធ', _rejectedCount, Colors.red, Icons.cancel),
        ],
      ),
    );
  }

  Widget _miniStatCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  // ── Pending warning banner ───────────────────────────────────
  Widget _buildPendingBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.orange.withOpacity(0.4)
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$_pendingCount ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange),
                  ),
                  const TextSpan(
                    text: 'ការចូលរួមរបស់អ្នក កំពុងរង់ចាំការអនុម័ត'
                        'ពីគ្រូ។ ទំព័រនឹងធ្វើបច្ចុប្បន្នកម្មដោយស្វ័យប្រវត្ត។',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _LiveDot(),
        ],
      ),
    );
  }

  // ── Record card ──────────────────────────────────────────────
  Widget _buildRecordCard(Map<String, dynamic> r) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final verifyStatus = r['verify_status'] as String? ?? 'pending';
    final attendanceStatus = r['status'] as String? ?? 'N';
    final date = r['attendance_date']?.toString() ?? '';
    final checkIn = r['check_in_time'];
    final reason = r['reject_reason'];

    final vColor = _verifyColor(verifyStatus);
    final vIcon = _verifyIcon(verifyStatus);
    final vLabel = _verifyLabel(verifyStatus);

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dateChipBg = isDark ? const Color(0xFF334155) : Colors.grey.shade100;
    final greyText = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500;
    final bodyText = isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: vColor.withOpacity(isDark ? 0.35 : 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Date chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: dateChipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: greyText),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Verify status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: vColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(vIcon, size: 14, color: vColor),
                      const SizedBox(width: 4),
                      Text(
                        vLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: vColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (checkIn != null)
              Row(
                children: [
                  Icon(Icons.login, size: 14, color: greyText),
                  const SizedBox(width: 6),
                  Text('ចូល: $checkIn',
                      style: TextStyle(fontSize: 13, color: bodyText)),
                ],
              ),

            if (r['session']?['teacher']?['user']?['name'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: greyText),
                    const SizedBox(width: 6),
                    Text(
                      'គ្រូ: ${r['session']['teacher']['user']['name']}',
                      style: TextStyle(fontSize: 13, color: bodyText),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  attendanceStatus == 'Y'
                      ? Icons.check_circle_outline
                      : Icons.highlight_off,
                  size: 14,
                  color: attendanceStatus == 'Y' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  attendanceStatus == 'Y' ? 'មានវត្តមាន' : 'អវត្តមាន',
                  style: TextStyle(
                    fontSize: 13,
                    color: attendanceStatus == 'Y'
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (verifyStatus == 'rejected' &&
                reason != null &&
                reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.red.withOpacity(0.1)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(isDark ? 0.3 : 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14,
                        color: isDark ? Colors.red.shade300 : Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'មូលហេតុ: $reason',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.red.shade300 : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (verifyStatus == 'pending') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _LiveDot(size: 8),
                  const SizedBox(width: 6),
                  Text(
                    'រង់ចាំការអនុម័តពីគ្រូ...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_error ?? 'Unknown error', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHistory,
            child: const Text('ព្យាយាមម្ដងទៀត'),
          ),
        ],
      ),
    );
  }

  Color _verifyColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _verifyIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.remove_circle;
      default:
        return Icons.pending;
    }
  }

  String _verifyLabel(String status) {
    switch (status) {
      case 'approved':
        return 'បានអនុម័ត';
      case 'rejected':
        return 'បានបដិសេធ';
      default:
        return 'រង់ចាំ';
    }
  }
}

// ─── Animated live dot indicator ─────────────────────────────
class _LiveDot extends StatefulWidget {
  final double size;
  const _LiveDot({this.size = 10});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
