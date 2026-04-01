import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Teacher Active Session Monitor — with anti-cheating approval checklist
/// ─────────────────────────────────────────────────────────────────────────────
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
    extends State<TeacherActiveSessionScreen>
    with SingleTickerProviderStateMixin {
  final AttendanceService _service = AttendanceService();

  // Data
  Map<String, dynamic>? _sessionData;
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _approved = [];
  List<Map<String, dynamic>> _rejected = [];

  // State
  bool _isLoading = true;
  bool _isEnding = false;
  Timer? _refreshTimer;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApprovals();
    // Auto-refresh every 6 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _loadApprovals(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Fetch approval list from backend
  Future<void> _loadApprovals({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final data = await _service.getApprovalList(widget.sessionId);
      if (!mounted) return;

      final attendances = data['attendances'] as Map<String, dynamic>? ?? {};

      setState(() {
        _sessionData = data['session'] as Map<String, dynamic>?;
        _pending = List<Map<String, dynamic>>.from(attendances['pending'] ?? []);
        _approved = List<Map<String, dynamic>>.from(attendances['approved'] ?? []);
        _rejected = List<Map<String, dynamic>>.from(attendances['rejected'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (!silent && mounted) setState(() => _isLoading = false);
    }
  }

  /// Approve a single student check-in
  Future<void> _approve(Map<String, dynamic> attendance) async {
    await _doVerify(attendance, 'approved', null);
  }

  /// Show reject dialog, then reject
  Future<void> _rejectWithReason(Map<String, dynamic> attendance) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Expanded(child: Text('បដិសេធការចូលរួម')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'សិស្ស: ${attendance['student_name']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'មូលហេតុ (ស្រេចចិត្ត)',
                hintText: 'ឧ. ចូលឈ្មោះជំនួស, ស្កេនទូរស័ព្ទអ្នកដទៃ...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('បដិសេធ'),
          ),
        ],
      ),
    );

    if (reason != null) {
      await _doVerify(attendance, 'rejected', reason.isEmpty ? null : reason);
    }
  }

  Future<void> _doVerify(
      Map<String, dynamic> attendance, String action, String? reason) async {
    final id = attendance['id'];
    if (id == null) return;

    // Optimistic update: remove from pending immediately
    setState(() {
      _pending.removeWhere((a) => a['id'] == id);
      if (action == 'approved') {
        _approved.insert(0, {...attendance, 'verify_status': 'approved'});
      } else {
        _rejected.insert(0, {
          ...attendance,
          'verify_status': 'rejected',
          'reject_reason': reason,
        });
      }
    });

    try {
      await _service.verifyAttendance(
        sessionId: widget.sessionId,
        attendanceId: id is int ? id : int.parse(id.toString()),
        action: action,
        reason: reason,
      );

      if (mounted) {
        final color = action == 'approved' ? Colors.green : Colors.red;
        final msg = action == 'approved'
            ? '✓ ${attendance['student_name']} ត្រូវបានអនុម័ត'
            : '✗ ${attendance['student_name']} ត្រូវបានបដិសេធ';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Rollback on failure
      await _loadApprovals(silent: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Approve all pending at once
  Future<void> _approveAll() async {
    if (_pending.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('អនុម័តទាំងអស់?'),
        content: Text(
            'អ្នករំពឹងអនុម័ត ${_pending.length} នាក់ ក្នុងពេលតែមួយ?\nការនេះមិនអាចត្រឡប់វិញបានទេ។'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('បោះបង់')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('អនុម័តទាំងអស់'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final pendingCopy = List<Map<String, dynamic>>.from(_pending);
    for (final a in pendingCopy) {
      await _doVerify(a, 'approved', null);
    }
  }

  Future<void> _endSession() async {
    final pendingCount = _pending.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('បិទវេនវត្តមាន?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pendingCount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'នៅមាន $pendingCount នាក់ ដែលមិនទាន់ត្រូវបានផ្ទៀងផ្ទាត់!\n'
                        'ពួកគេនឹងត្រូវចាត់ទុកជា "អវត្តមាន"។',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
              ),
            const Text(
                'សិស្សដែលមិនបានស្កេន QR នឹងត្រូវកត់ត្រាជា អវត្តមាន។'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('បោះបង់')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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
                'វេនបានបិទ។ វត្តមាន: ${result['total_present']} | អវត្តមាន: ${result['total_absent']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isEnding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'session_id': widget.sessionId,
      'qr_token': widget.qrToken,
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'វេនវត្តមានកំពុងដំណើរការ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_pending.isNotEmpty)
            TextButton.icon(
              onPressed: _approveAll,
              icon: const Icon(Icons.done_all, color: Colors.green, size: 18),
              label: const Text('អនុម័តទាំងអស់',
                  style: TextStyle(color: Colors.green, fontSize: 12)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadApprovals(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code, size: 16),
                      const SizedBox(width: 4),
                      const Text('QR', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'រង់ចាំ${_pending.isNotEmpty ? " (${_pending.length})" : ""}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.checklist, size: 16),
                      const SizedBox(width: 4),
                      const Text('លទ្ធផល', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQrTab(qrData),
                _buildPendingTab(),
                _buildResultsTab(),
              ],
            ),
      bottomNavigationBar: _buildEndSessionBar(),
    );
  }

  // ── Tab 1: QR Code ──────────────────────────────────────────
  Widget _buildQrTab(String qrData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              _statCard('រង់ចាំ', _pending.length, Colors.orange,
                  Icons.pending_actions),
              const SizedBox(width: 8),
              _statCard(
                  'អនុម័ត', _approved.length, Colors.green, Icons.check_circle),
              const SizedBox(width: 8),
              _statCard('បដិសេធ', _rejected.length, Colors.red, Icons.cancel),
            ],
          ),
          const SizedBox(height: 20),

          // QR Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'សូមឱ្យសិស្សស្កេន QR',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'បន្ទាប់ពីស្កេន សូមអនុម័តបញ្ជីខាងក្រោម',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.3), width: 2),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, size: 15, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'ចាប់ផ្តើម: ${_formatTime(_sessionData?['started_at'])}',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_pending.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'មាន ${_pending.length} នាក់ ដែលបានស្កេន QR ហើយ '
                      'រង់ចាំការអនុម័ត។ ចូលទៅ Tab "រង់ចាំ" ដើម្បីផ្ទៀងផ្ទាត់។',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.deepOrange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tab 2: Pending Approval Checklist ───────────────────────
  Widget _buildPendingTab() {
    if (_pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 72, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text(
              'គ្មានការចូលរួមដែលរង់ចាំ',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _approved.isEmpty && _rejected.isEmpty
                  ? 'រង់ចាំសិស្សស្កេន QR...'
                  : 'ទាំងអស់ត្រូវបានផ្ទៀងផ្ទាត់រួចហើយ ✓',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header action bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_pending.length} នាក់ ត្រូវការផ្ទៀងផ្ទាត់',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _approveAll,
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('អនុម័តទាំងអស់', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Pending list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _pending.length,
            itemBuilder: (context, index) {
              final a = _pending[index];
              return _buildPendingCard(a, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> a, int index) {
    final name = a['student_name'] ?? 'Unknown';
    final code = a['student_code'] ?? '';
    final checkIn = a['check_in_time'] ?? '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.orange.shade200, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (code.isNotEmpty)
                        Text(
                          'ID: $code',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                // Check-in time badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: Colors.blue.shade600),
                      const SizedBox(width: 4),
                      Text(
                        checkIn,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                // Reject
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectWithReason(a),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('បដិសេធ', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Approve
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(a),
                    icon: const Icon(Icons.check, size: 16),
                    label:
                        const Text('អនុម័ត', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 3: Results (Approved + Rejected) ────────────────────
  Widget _buildResultsTab() {
    if (_approved.isEmpty && _rejected.isEmpty) {
      return const Center(
        child: Text('មិនទាន់មានការផ្ទៀងផ្ទាត់',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (_approved.isNotEmpty) ...[
          _sectionHeader('អនុម័ត (${_approved.length})', Colors.green,
              Icons.check_circle),
          ..._approved.map((a) => _buildResultCard(a, 'approved')),
          const SizedBox(height: 8),
        ],
        if (_rejected.isNotEmpty) ...[
          _sectionHeader('បដិសេធ (${_rejected.length})', Colors.red,
              Icons.cancel),
          ..._rejected.map((a) => _buildResultCard(a, 'rejected')),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: color.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> a, String status) {
    final isApproved = status == 'approved';
    final color = isApproved ? Colors.green : Colors.red;
    final name = a['student_name'] ?? 'Unknown';
    final code = a['student_code'] ?? '';
    final reason = a['reject_reason'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                if (code.isNotEmpty)
                  Text('ID: $code',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                if (!isApproved && reason != null && reason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'មូលហេតុ: $reason',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.deepOrange),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isApproved ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 22,
          ),
        ],
      ),
    );
  }

  // ── Bottom End Session Bar ───────────────────────────────────
  Widget _buildEndSessionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_pending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'មាន ${_pending.length} នាក់ ដែលរង់ចាំ — '
                    'ពួកគេនឹងចាត់ទុកជា "អវត្តមាន" ប្រសិនបើបិទ',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.deepOrange),
                  ),
                ],
              ),
            ),
          ElevatedButton.icon(
            onPressed: _isEnding ? null : _endSession,
            icon: _isEnding
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.stop_circle_outlined),
            label: Text(_isEnding ? 'កំពុងបិទ...' : 'បិទវេនវត្តមាន'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────
  Widget _statCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
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
