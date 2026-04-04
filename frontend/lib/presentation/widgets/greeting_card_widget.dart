import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';

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
                  _buildAvatar(photoUrl: photoUrl, initials: initials),
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
}
