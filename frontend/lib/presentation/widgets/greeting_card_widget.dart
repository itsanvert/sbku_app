import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/providers/theme_provider.dart';
import 'package:sbku_app/presentation/screens/profile/profile_screen.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key});

  // ── Time-aware greeting (Khmer) ────────────────────────────────
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

  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  /// Returns a friendly display label for the role
  String _roleLabel(String? role) {
    if (role == null) return '';
    switch (role.toLowerCase()) {
      case 'teacher':
        return 'គ្រូ';
      case 'student':
        return 'សិស្ស';
      case 'super admin':
      case 'superadmin':
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  Color _roleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'teacher':
        return const Color(0xFF60A5FA); // blue
      case 'student':
        return const Color(0xFF34D399); // green
      default:
        return const Color(0xFFFBBF24); // amber
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final userName = user?.name ?? 'User';
        final userEmail = user?.email ?? '';
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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6A00), Color(0xFF9E3801)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6A00).withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Decorative orbs ────────────────────────────────
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -16,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────────
              Row(
                children: [
                  // ── Avatar ─────────────────────────────────────
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSettingsBottomSheet(context),
                      borderRadius: BorderRadius.circular(52),
                      child: _buildAvatar(photoUrl: photoUrl, initials: initials),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // ── Name / greeting / email ─────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting row
                        Row(
                          children: [
                            Icon(
                              _greetingIcon,
                              color: Colors.white.withOpacity(0.85),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _greeting,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Full name
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Email + role badge in one row
                        Row(
                          children: [
                            if (userEmail.isNotEmpty) ...[
                              Flexible(
                                child: Text(
                                  userEmail,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (roleLabel.isNotEmpty)
                                const SizedBox(width: 6),
                            ],
                            // Role badge
                            if (roleLabel.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: roleColor.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  roleLabel,
                                  style: TextStyle(
                                    color: roleColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Date chip ───────────────────────────────────
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _formattedDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.45),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                // Show initials while loading
                frameBuilder: (ctx, child, frame, loaded) {
                  if (loaded) return child;
                  return frame != null ? child : _initialsWidget(initials);
                },
                errorBuilder: (_, __, ___) => _initialsWidget(initials),
              )
            : _initialsWidget(initials),
      ),
    );
  }

  Widget _initialsWidget(String initials) {
    return Container(
      width: 52,
      height: 52,
      color: Colors.transparent,
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
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
            color: isDark ? const Color(0xFF0F172A) : theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'ការកំណត់ & គណនី (Settings & Profile)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 28),

              // Profile Section
              _buildSettingItem(
                context,
                icon: Icons.person_outline_rounded,
                label: 'មើលព័ត៌មានផ្ទាល់ខ្លួន (View Profile)',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),

              // Overall Setting Section
              _buildSettingItem(
                context,
                icon: Icons.notifications_none_rounded,
                label: 'ការជូនដំណឹង (Notifications)',
                onTap: () {
                  // Not implemented yet
                },
              ),

              // Theme Toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return _buildSettingItem(
                    context,
                    icon: themeProvider.isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    label: 'មុខងារងងឹត (Dark Mode)',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                      activeColor: const Color(0xFFFF6A00),
                    ),
                  );
                },
              ),

              _buildSettingItem(
                context,
                icon: Icons.help_outline_rounded,
                label: 'ជំនួយ & ការគាំទ្រ (Help & Support)',
                onTap: () {},
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, thickness: 1, color: Colors.black12),
              ),

              _buildSettingItem(
                context,
                icon: Icons.logout_rounded,
                label: 'ចាកចេញ (Logout)',
                color: Colors.redAccent,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('ចាកចេញ (Logout)'),
                      content: const Text('តើអ្នកប្រាកដជាចង់ចាកចេញមែនទេ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ទេ')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('បាទ/ចាកចេញ'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    Navigator.pop(context);
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: color ?? (isDark ? Colors.white70 : const Color(0xFF4B5563)),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white : const Color(0xFF1F2937)),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            size: 20,
            color: isDark ? Colors.white38 : Colors.grey,
          ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
