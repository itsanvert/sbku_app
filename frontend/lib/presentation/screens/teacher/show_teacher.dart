import 'package:flutter/material.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/service/teacher_service.dart';

class ShowTeacherScreen extends StatefulWidget {
  final String teacherId;

  const ShowTeacherScreen({super.key, required this.teacherId});

  @override
  State<ShowTeacherScreen> createState() => _ShowTeacherScreenState();
}

class _ShowTeacherScreenState extends State<ShowTeacherScreen> {
  final TeacherService _service = TeacherService();
  late final Future<Teacher> _teacherFuture;

  static const _primary = Color(0xFFFF5722);

  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    _teacherFuture = _service.getTeacher(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDarkMode(context) ? const Color(0xFF121212) : Colors.white,
      body: FutureBuilder<Teacher>(
        future: _teacherFuture,
        builder: (context, snapshot) {
          // ── Loading ──────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ── Error ────────────────────────────────────────────────
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              backgroundColor:
                  _isDarkMode(context) ? const Color(0xFF121212) : Colors.white,
              appBar: AppBar(backgroundColor: _primary),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 60,
                        color: _isDarkMode(context)
                            ? Colors.grey[600]
                            : Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.hasError
                          ? 'Error: ${snapshot.error}'
                          : 'រកមិនឃើញគ្រូ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _isDarkMode(context)
                              ? Colors.grey[400]
                              : Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ត្រឡប់ក្រោយ'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Data ─────────────────────────────────────────────────
          final Teacher t = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // ── Hero AppBar ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: _primary,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        // Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                (t.avatarUrl != null && t.avatarUrl!.isNotEmpty)
                                    ? NetworkImage(t.avatarUrl!)
                                    : NetworkImage(
                                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(t.name)}&background=FF5722&color=ffffff&size=128&bold=true',
                                      ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Text(
                          t.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t.email ?? '—',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: const Text('ព័ត៌មានគ្រូ',
                    style: TextStyle(color: Colors.white)),
              ),

              // ── Body ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('ព័ត៌មានទូទៅ', context),
                      const SizedBox(height: 8),
                      _card([
                        _infoRow(
                            Icons.badge_outlined, 'ឈ្មោះពេញ', t.name, context),
                        _infoRow(
                            Icons.wc,
                            'ភេទ',
                            t.gender == 'M' ? 'Male' : t.gender ?? '—',
                            context),
                        _infoRow(Icons.phone_outlined, 'ទូរសព្ទ',
                            t.phone ?? '—', context),
                        _infoRow(Icons.email_outlined, 'អ៊ីមែល', t.email ?? '—',
                            context),
                      ], context),
                      const SizedBox(height: 20),
                      _sectionTitle('ព័ត៌មានវិជ្ជាជីវៈ', context),
                      const SizedBox(height: 8),
                      _card([
                        _infoRow(Icons.school_outlined, 'ឯកទេស', t.major ?? '—',
                            context),
                        _infoRow(Icons.account_balance_outlined, 'មហាវិទ្យាល័យ',
                            t.faculty ?? '—', context),
                        _infoRow(Icons.calendar_today_outlined, 'ឆ្នាំ',
                            t.year?.toString() ?? '—', context),
                        _infoRow(Icons.schedule_outlined, 'កាលបរិច្ឆេទ',
                            t.schedule ?? '—', context),
                        _infoRow(Icons.schedule_outlined, 'កាលវិភាគ',
                            t.shift ?? '—', context),
                      ], context),
                      const SizedBox(height: 20),
                      _sectionTitle('ព័ត៌មានប្រព័ន្ធ', context),
                      const SizedBox(height: 8),
                      _card([
                        _infoRow(Icons.tag, 'Teacher ID', '#${t.id}', context),
                        _infoRow(Icons.person_outline, 'User ID',
                            t.userId?.toString() ?? '—', context),
                        _infoRow(Icons.event_outlined, 'បានចូលរួម',
                            t.createdAt ?? '—', context,
                            last: true),
                      ], context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _sectionTitle(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _isDarkMode(context) ? Colors.grey[400] : Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _card(List<Widget> children, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode(context) ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDarkMode(context) ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(
      IconData icon, String label, String value, BuildContext context,
      {bool last = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _primary.withOpacity(_isDarkMode(context) ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: _isDarkMode(context)
                            ? Colors.grey[500]
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isDarkMode(context)
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!last)
          Divider(
              height: 1,
              indent: 56,
              color: _isDarkMode(context)
                  ? Colors.grey[700]
                  : Colors.grey.shade100),
      ],
    );
  }
}
