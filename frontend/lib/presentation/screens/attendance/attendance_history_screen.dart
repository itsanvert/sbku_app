import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/service/auth_service.dart';
import 'package:sbku_app/presentation/screens/attendance/request_permission_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sbku_app/service/api_service.dart';
import 'package:sbku_app/core/constants/app_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Teacher Attendance History Screen
// ─────────────────────────────────────────────────────────────────────────────
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AttendanceService _service = AttendanceService();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({bool loadMore = false}) async {
    if (loadMore) {
      _page++;
    } else {
      _page = 1;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getAttendances(page: _page);
      final data = (result['data'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];

      if (!mounted) return;
      setState(() {
        if (loadMore) {
          _records.addAll(data);
        } else {
          _records = data;
        }
        _hasMore = (_page < (result['last_page'] ?? 1));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(title: 'ប្រវត្តិវត្តមាន'),
      body: _isLoading && _records.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null && _records.isEmpty
              ? _buildError()
              : _records.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _loadHistory, child: const Text('ព្យាយាមម្ដងទៀត')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF475569)
                  : Colors.grey[400]),
          const SizedBox(height: 16),
          Text('', style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          )),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () => _loadHistory(),
      child: ListView.builder(
        itemCount: _records.length + (_hasMore ? 1 : 0),
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          if (index >= _records.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final record = _records[index];
          final isPresent = record['status'] == 'Y';
          final date = record['attendance_date'] ?? '';
          final studentName =
              record['student_name'] ?? record['student']?['name'] ?? 'Unknown';
          final checkIn = record['check_in_time'];
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final avatarUrl = record['student']?['avatar_url'] ??
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(studentName)}&background=6366f1&color=ffffff';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPresent
                    ? Colors.green.withOpacity(isDark ? 0.15 : 0.08)
                    : Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                backgroundImage: NetworkImage(avatarUrl),
              ),
              title: Text(studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${_formatDate(date)}${checkIn != null ? " • ${_formatTime(checkIn)}" : ""}',
                style: TextStyle(
                  color: isDark ? Colors.blue.shade400 : Colors.blue.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPresent ? 'មានវត្តមាន' : 'អវត្តមាន',
                  style: TextStyle(
                    color: isPresent ? Colors.green.shade600 : Colors.red.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
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

// ─────────────────────────────────────────────────────────────────────────────
// Attendance Report Screen (Daily / Monthly / Yearly)
// ─────────────────────────────────────────────────────────────────────────────
class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AttendanceService _service = AttendanceService();

  // Daily
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _dailyData;
  bool _dailyLoading = false;

  // Monthly
  int _selectedMonth = DateTime.now().month;
  int _selectedMonthYear = DateTime.now().year;
  Map<String, dynamic>? _monthlyData;
  bool _monthlyLoading = false;

  // Yearly
  int _selectedYear = DateTime.now().year;
  Map<String, dynamic>? _yearlyData;
  bool _yearlyLoading = false;

  bool _isLoadingExport = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDailyReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Daily Report ──────────────────────────────────────────────
  Future<void> _loadDailyReport() async {
    setState(() => _dailyLoading = true);
    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final data = await _service.getDailyReport(dateStr);
      if (!mounted) return;
      setState(() {
        _dailyData = data;
        _dailyLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _dailyLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadDailyReport();
    }
  }

  // ── Monthly Report ────────────────────────────────────────────
  Future<void> _loadMonthlyReport() async {
    setState(() => _monthlyLoading = true);
    try {
      final data =
          await _service.getMonthlyReport(_selectedMonth, _selectedMonthYear);
      if (!mounted) return;
      setState(() {
        _monthlyData = data;
        _monthlyLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _monthlyLoading = false);
    }
  }

  // ── Yearly Report ─────────────────────────────────────────────
  Future<void> _loadYearlyReport() async {
    setState(() => _yearlyLoading = true);
    try {
      final data = await _service.getYearlyReport(_selectedYear);
      if (!mounted) return;
      setState(() {
        _yearlyData = data;
        _yearlyLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _yearlyLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'របាយការណ៍វត្តមាន',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            if (index == 0) _loadDailyReport();
            if (index == 1) _loadMonthlyReport();
            if (index == 2) _loadYearlyReport();
          },
          tabs: const [
            Tab(text: 'ប្រចាំថ្ងៃ'),
            Tab(text: 'ប្រចាំខែ'),
            Tab(text: 'ប្រចាំឆ្នាំ'),
          ],
        ),
        actions: [
          if (_isLoadingExport)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_for_offline_rounded, size: 28),
              tooltip: 'ទាញយករបាយការណ៍',
              onPressed: () {
                final currentTab = _tabController.index;
                final type = currentTab == 0
                    ? 'daily'
                    : (currentTab == 1 ? 'monthly' : 'yearly');
                _showExportOptions(context, type);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildMonthlyTab(),
          _buildYearlyTab(),
        ],
      ),
    );
  }

  // ── Daily Tab ─────────────────────────────────────────────────
  Widget _buildDailyTab() {
    return Column(
      children: [
        // Date picker
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.orange),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.orange),
              ],
            ),
          ),
        ),
        if (_dailyLoading)
          const Expanded(
              child: Center(child: CircularProgressIndicator()))
        else if (_dailyData != null) ...[
          // Summary cards
          _buildSummaryCards(_dailyData!['summary']),
          const SizedBox(height: 12),
          // Student list
          Expanded(
            child: _buildRecordsList(
                List<Map<String, dynamic>>.from(_dailyData!['records'] ?? [])),
          ),
        ] else
          const Expanded(child: Center(child: Text('សូមជ្រើសរើសកាលបរិច្ឆេទ'))),
      ],
    );
  }

  // ── Monthly Tab ───────────────────────────────────────────────
  Widget _buildMonthlyTab() {
    return Column(
      children: [
        // Month/Year picker
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                          value: i + 1, child: Text('ខែ ${i + 1}'))),
                  onChanged: (v) {
                    setState(() => _selectedMonth = v!);
                    _loadMonthlyReport();
                  },
                  decoration: InputDecoration(
                    labelText: 'ខែ',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedMonthYear,
                  items: List.generate(
                      7,
                      (i) => DropdownMenuItem(
                          value: 2020 + i, child: Text('${2020 + i}'))),
                  onChanged: (v) {
                    setState(() => _selectedMonthYear = v!);
                    _loadMonthlyReport();
                  },
                  decoration: InputDecoration(
                    labelText: 'ឆ្នាំ',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_monthlyLoading)
          const Expanded(
              child: Center(child: CircularProgressIndicator()))
        else if (_monthlyData != null)
          Expanded(
            child: _buildStudentSummaryList(List<Map<String, dynamic>>.from(
                _monthlyData!['students'] ?? [])),
          )
        else
          const Expanded(child: Center(child: Text('សូមជ្រើសរើសខែ និងឆ្នាំ'))),
      ],
    );
  }

  // ── Yearly Tab ────────────────────────────────────────────────
  Widget _buildYearlyTab() {
    return Column(
      children: [
        // Year picker
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedYear,
            items: List.generate(
                7,
                (i) => DropdownMenuItem(
                    value: 2020 + i, child: Text('${2020 + i}'))),
            onChanged: (v) {
              setState(() => _selectedYear = v!);
              _loadYearlyReport();
            },
            decoration: InputDecoration(
              labelText: 'ឆ្នាំ',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        if (_yearlyLoading)
          const Expanded(
              child: Center(child: CircularProgressIndicator()))
        else if (_yearlyData != null) ...[
          // Monthly breakdown chart substitute
          if (_yearlyData!['monthly_breakdown'] != null)
            _buildMonthlyBreakdown(List<Map<String, dynamic>>.from(
                _yearlyData!['monthly_breakdown'])),
          Expanded(
            child: _buildStudentSummaryList(List<Map<String, dynamic>>.from(
                _yearlyData!['students'] ?? [])),
          ),
        ] else
          const Expanded(child: Center(child: Text('សូមជ្រើសរើសឆ្នាំ'))),
      ],
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────
  Widget _buildSummaryCards(Map<String, dynamic>? summary) {
    if (summary == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _summaryCard('សរុប', '${summary['total'] ?? 0}', Colors.blue),
          const SizedBox(width: 8),
          _summaryCard(
              'មានវត្តមាន', '${summary['present'] ?? 0}', Colors.green),
          const SizedBox(width: 8),
          _summaryCard('អវត្តមាន', '${summary['absent'] ?? 0}', Colors.red),
          const SizedBox(width: 8),
          _summaryCard(
              '%', '${summary['present_percentage'] ?? 0}%', Colors.orange),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return const Center(child: Text('គ្មានទិន្នន័យ'));
    }

    return ListView.builder(
      itemCount: records.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final r = records[index];
        final isPresent = r['status'] == 'Y';
        final name = r['student_name'] ??
            r['student']?['name'] ??
            r['student']?['user']?['name'] ??
            'Unknown';

        final avatarUrl = r['student']?['avatar_url'] ??
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=6366f1&color=ffffff';

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPresent ? Colors.green[50] : Colors.red[50],
              backgroundImage: NetworkImage(avatarUrl),
            ),
            title:
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: r['check_in_time'] != null
                ? Text('ចូល: ${_formatTime(r['check_in_time'])}',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.bold,
                    ))
                : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPresent ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPresent ? 'Y' : 'N',
                style: TextStyle(
                  color: isPresent ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentSummaryList(List<Map<String, dynamic>> students) {
    if (students.isEmpty) {
      return const Center(child: Text('គ្មានទិន្នន័យ'));
    }

    return ListView.builder(
      itemCount: students.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final s = students[index];
        final name = s['student_name']?.toString() ?? 'Unknown';
        final present = s['present_days'] ?? 0;
        final absent = s['absent_days'] ?? 0;
        final total = s['total_days'] ?? 0;
        final rate = s['attendance_rate'] ?? 0;

                final avatarUrl = s['avatar_url'] ??
                    (s['profile_image_path'] != null
                        ? AppConfig.storageUrl(s['profile_image_path'] as String)
                        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=6366f1&color=ffffff');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.orange[50],
                              backgroundImage: NetworkImage(avatarUrl),
                            ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _rateColor(rate).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$rate%',
                        style: TextStyle(
                          color: _rateColor(rate),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat('សរុប', '$total', Colors.blue),
                    const SizedBox(width: 16),
                    _miniStat('ចូល', '$present', Colors.green),
                    const SizedBox(width: 16),
                    _miniStat('អវត្តមាន', '$absent', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyBreakdown(List<Map<String, dynamic>> breakdown) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: breakdown.length,
        itemBuilder: (context, index) {
          final m = breakdown[index];
          final month = m['month'];
          final present = _toNum(m['present']);
          final total = _toNum(m['total']);
          final rate = total > 0 ? ((present / total) * 100).round() : 0;

          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _rateColor(rate).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rateColor(rate).withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ខែ$month',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('$rate%',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _rateColor(rate))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  /// Safely convert a dynamic JSON value (may be String, int, double, or null)
  /// to a [num] so arithmetic operators work without crashing.
  num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  Color _rateColor(dynamic rate) {
    final r = rate is num ? rate.toDouble() : 0.0;
    if (r >= 80) return Colors.green;
    if (r >= 60) return Colors.orange;
    return Colors.red;
  }

  // ── Export Logic & UI Enhancements ───────────────────────────
  
  void _showExportOptions(BuildContext context, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.file_download_outlined, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ទាញយករបាយការណ៍',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'សូមជ្រើសរើសប្រភេទឯកសារ',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildExportOptionTile(
              context,
              title: 'PDF Document',
              subtitle: 'ល្អសម្រាប់ការបោះពុម្ព និងចែករំលែក',
              icon: Icons.picture_as_pdf_rounded,
              color: Colors.redAccent,
              onPressed: () {
                Navigator.pop(context);
                _handleExport(type, 'pdf');
              },
            ),
            const SizedBox(height: 12),
            _buildExportOptionTile(
              context,
              title: 'Excel Spreadsheet',
              subtitle: 'ល្អសម្រាប់ការវិភាគទិន្នន័យ',
              icon: Icons.table_view_rounded,
              color: Colors.green,
              onPressed: () {
                Navigator.pop(context);
                _handleExport(type, 'excel');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(String type, String format) async {
    setState(() => _isLoadingExport = true);
    try {
      http.Response response;
      String fileName = 'attendance_${type}_report';
      
      if (type == 'daily') {
        final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
        response = format == 'pdf' 
          ? await _service.exportPdf(date: dateStr)
          : await _service.exportExcel(date: dateStr);
        fileName += '_$dateStr';
      } else if (type == 'monthly') {
        response = format == 'pdf'
          ? await _service.exportPdf(month: _selectedMonth, year: _selectedMonthYear)
          : await _service.exportExcel(month: _selectedMonth, year: _selectedMonthYear);
        fileName += '_${_selectedMonthYear}_$_selectedMonth';
      } else {
        response = format == 'pdf'
          ? await _service.exportPdf(year: _selectedYear)
          : await _service.exportExcel(year: _selectedYear);
        fileName += '_$_selectedYear';
      }

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final extension = format == 'pdf' ? 'pdf' : 'xlsx';
        
        final directory = await getTemporaryDirectory();
        
        final filePath = '${directory.path}/$fileName.$extension';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        // Trigger system share dialog
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'របាយការណ៍វត្តមាន${format == 'pdf' ? ' (PDF)' : ' (Excel)'}',
        );
      } else {
        throw Exception('Export failed status: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingExport = false);
    }
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

// ─────────────────────────────────────────────────────────────────────────────
// Student Attendance History Screen
// ─────────────────────────────────────────────────────────────────────────────
class StudentAttendanceHistoryScreen extends StatefulWidget {
  const StudentAttendanceHistoryScreen({super.key});

  @override
  State<StudentAttendanceHistoryScreen> createState() =>
      _StudentAttendanceHistoryScreenState();
}

class _StudentAttendanceHistoryScreenState
    extends State<StudentAttendanceHistoryScreen> {
  final AttendanceService _service = AttendanceService();
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;

  String? _studentId;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({bool loadMore = false}) async {
    if (loadMore) {
      _page++;
    } else {
      _page = 1;
    }

    if (_studentId == null) {
      final user = await AuthService().getCurrentUser();
      if (user != null && user.studentId != null) {
        _studentId = user.studentId;
      }
    }

    if (_studentId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _service.getStudentHistory(_studentId!, page: _page);
      final attendances = result['attendances'];
      final data = (attendances?['data'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];

      setState(() {
        _summary = result['summary'] != null
            ? Map<String, dynamic>.from(result['summary'])
            : null;
        if (loadMore) {
          _records.addAll(data);
        } else {
          _records = data;
        }
        _hasMore = _page < (attendances?['last_page'] ?? 1);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(title: 'ប្រវត្តិវត្តមានរបស់ខ្ញុំ'),
      body: _isLoading && _records.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : RefreshIndicator(
              onRefresh: () => _loadHistory(),
              child: Column(
                children: [
                  // Stats card
                  if (_summary != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.orange[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statColumn('សរុប', '${_summary!['total'] ?? 0}',
                              Colors.white),
                          _statColumn('មាន', '${_summary!['present'] ?? 0}',
                              Colors.white),
                          _statColumn('អវត្តមាន', '${_summary!['absent'] ?? 0}',
                              Colors.white),
                          _statColumn(
                              'ភាគរយ',
                              '${_summary!['attendance_rate'] ?? 0}%',
                              Colors.white),
                        ],
                      ),
                    ),
                  // Records list
                  Expanded(
                    child: _records.isEmpty
                        ? const Center(child: Text('មិនមានប្រវត្តិវត្តមាន'))
                        : ListView.builder(
                            itemCount: _records.length + (_hasMore ? 1 : 0),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              if (index >= _records.length) {
                                _loadHistory(loadMore: true);
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                        color: Colors.orange),
                                  ),
                                );
                              }

                                final r = _records[index];
                                final status = r['status'];
                                final isPresent = status == 'Y';
                                final isPermission = status == 'P';
                                
                                String statusText = 'អវត្តមាន';
                                Color statusColor = Colors.red;
                                IconData statusIcon = Icons.close;
                                
                                if (isPresent) {
                                  statusText = 'មានវត្តមាន';
                                  statusColor = Colors.green;
                                  statusIcon = Icons.check;
                                } else if (isPermission) {
                                  statusText = 'ច្បាប់';
                                  statusColor = Colors.orange;
                                  statusIcon = Icons.list_alt;
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor.withOpacity(0.1),
                                      child: Icon(statusIcon, color: statusColor),
                                    ),
                                    title: Text(
                                      _formatDate(r['attendance_date']),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: isPermission 
                                      ? Text('មូលហេតុ: ${r['permission_reason'] ?? '—'}', 
                                          maxLines: 1, overflow: TextOverflow.ellipsis)
                                      : (r['check_in_time'] != null
                                          ? Text('ចូល: ${_formatTime(r['check_in_time'])}')
                                          : null),
                                    trailing: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RequestPermissionScreen()),
          );
          if (result == true) {
            _loadHistory();
          }
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ស្នើសុំច្បាប់', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.9))),
      ],
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
