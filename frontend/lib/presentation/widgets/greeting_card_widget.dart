import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/providers/theme_provider.dart';
import 'package:sbku_app/presentation/screens/profile/profile_screen.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key});

  // ── ការស្វាគមន៍តាមម៉ោង (ភាសាខ្មែរ) ────────────────────────────
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'អរុណសួស្តី';
    if (hour < 17) return 'ទិវាសួស្តី';
    if (hour < 21) return 'សាយណ្ហសួស្តី';
    return 'រាត្រីសួស្តី';
  }

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_outlined;
    if (hour < 17) return Icons.light_mode_outlined;
    if (hour < 21) return Icons.wb_twilight_outlined;
    return Icons.nightlight_outlined;
  }

  // ── ទម្រង់កាលបរិច្ឆេទជាភាសាខ្មែរ ──────────────────────────────
  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      'មករា',
      'កុម្ភៈ',
      'មីនា',
      'មេសា',
      'ឧសភា',
      'មិថុនា',
      'កក្កដា',
      'សីហា',
      'កញ្ញា',
      'តុលា',
      'វិច្ឆិកា',
      'ធ្នូ',
    ];
    const days = [
      'ច័ន្ទ',
      'អង្គារ',
      'ពុធ',
      'ព្រហស្បតិ៍',
      'សុក្រ',
      'សៅរ៍',
      'អាទិត្យ'
    ];
    return '${days[now.weekday - 1]}\n${now.day} ${months[now.month - 1]}';
  }

  // ── ស្លាកតួនាទី ──────────────────────────────────────────────
  String _roleLabel(String? role) {
    if (role == null) return '';
    switch (role.toLowerCase()) {
      case 'teacher':
        return 'គ្រូបង្រៀន';
      case 'student':
        return 'សិស្ស';
      case 'super admin':
      case 'superadmin':
      case 'admin':
        return 'អ្នកគ្រប់គ្រង';
      default:
        return role;
    }
  }

  Color _roleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'teacher':
        return const Color(0xFF93C5FD);
      case 'student':
        return const Color(0xFF6EE7B7);
      default:
        return const Color(0xFFFCD34D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final userName = user?.name ?? 'អ្នកប្រើប្រាស់';
        final photoUrl = user?.profilePhotoUrl;
        final role = user?.role;

        final initials = userName
            .trim()
            .split(' ')
            .take(2)
            .where((w) => w.isNotEmpty)
            .map((w) => w[0].toUpperCase())
            .join();
        final roleLabel = _roleLabel(role);
        final roleColor = _roleColor(role);

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A), const Color(0xFF020617)]
                  : [const Color(0xFFFF6A00), const Color(0xFFB84300), const Color(0xFF7A2500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : const Color(0xFFFF6A00).withOpacity(0.40),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Decorative shapes ──────────────
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06))),
              ),

              // ── Main Content ──────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSettingsBottomSheet(context),
                      borderRadius: BorderRadius.circular(56),
                      child:
                          _buildAvatar(photoUrl: photoUrl, initials: initials),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_greetingIcon,
                                color: Colors.white.withOpacity(0.80),
                                size: 13),
                            const SizedBox(width: 5),
                            Text(_greeting,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.80),
                                    fontSize: 12.5)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(userName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (roleLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(roleLabel,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: roleColor,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ]
                      ],
                    ),
                  ),

                  // Date
                  GestureDetector(
                    onTap: () => _showSettingsBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.22)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14, color: Colors.white.withOpacity(0.75)),
                          const SizedBox(height: 4),
                          Text(_formattedDate,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar({String? photoUrl, required String initials}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.50), width: 2.5),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(photoUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsWidget(initials))
            : _initialsWidget(initials),
      ),
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
        child: Text(initials.isEmpty ? '?' : initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)));
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1117) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF6A00).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.manage_accounts_rounded,
                          color: Color(0xFFFF6A00), size: 20)),
                  const SizedBox(width: 12),
                  Text('ការកំណត់ & គណនី',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF111827))),
                ],
              ),
              const SizedBox(height: 22),
              _buildSettingItem(context,
                  icon: Icons.person_outline_rounded,
                  label: 'មើលព័ត៌មានផ្ទាល់ខ្លួន',
                  isDark: isDark, onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }),
              _buildSettingItem(context,
                  icon: Icons.notifications_none_rounded,
                  label: 'ការជូនដំណឹង',
                  isDark: isDark),
              Consumer<ThemeProvider>(
                  builder: (context, tp, _) => _buildSettingItem(context,
                      icon: tp.isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      label: 'របៀបងងឹត',
                      isDark: isDark,
                      trailing: Switch(
                          value: tp.isDarkMode,
                          onChanged: (v) => tp.toggleTheme(v),
                          activeColor: const Color(0xFFFF6A00)))),
              const SizedBox(height: 14),
              const Divider(),
              _buildSettingItem(context,
                  icon: Icons.logout_rounded,
                  label: 'ចាកចេញ',
                  isDark: isDark,
                  color: Colors.redAccent, onTap: () {
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).logout();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem(BuildContext context,
      {required IconData icon,
      required String label,
      required bool isDark,
      VoidCallback? onTap,
      Widget? trailing,
      Color? color}) {
    final textColor =
        color ?? (isDark ? Colors.white70 : const Color(0xFF1F2937));
    return ListTile(
      onTap: onTap,
      leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: (color ?? (isDark ? Colors.white : Colors.black))
                  .withOpacity(0.06),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: textColor, size: 20)),
      title: Text(label,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w600, fontSize: 14.5)),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              size: 20, color: isDark ? Colors.white24 : Colors.grey),
    );
  }
}
