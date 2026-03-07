import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
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
    final day = days[now.weekday - 1];
    final month = months[now.month - 1];
    return '$day, $month ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.user?.name ?? 'User';
        final userEmail = auth.user?.email ?? '';
        final initials = userName
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join();

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
            children: [
              // ── Decorative orb ─────────────────────────────────
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
                  // Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting + icon
                        Row(
                          children: [
                            Icon(
                              _greetingIcon,
                              color: Colors.white.withOpacity(0.85),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_greeting!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Name
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
                        if (userEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Date chip
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
}
