import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/home/home_screen.dart';
import 'package:sbku_app/presentation/widgets/shimmer_widget.dart';

class LoginSuccessScreen extends StatefulWidget {
  final String? userName;

  const LoginSuccessScreen({Key? key, this.userName}) : super(key: key);

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFFE84E0F);
  static const _primaryDark = Color(0xFFBF3B08);

  late final AnimationController _circleController;
  late final AnimationController _checkController;
  late final AnimationController _contentController;
  late final AnimationController _particleController;
  late final AnimationController _buttonController;

  late final Animation<double> _circleScale;
  late final Animation<double> _circleOpacity;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentOpacity;
  late final Animation<double> _buttonScale;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Generate confetti particles
    final rng = Random();
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.6,
        size: rng.nextDouble() * 8 + 4,
        color: [
          _primary,
          _primaryDark,
          const Color(0xFFFFD600),
          Colors.white,
          const Color(0xFFFF8A65),
        ][rng.nextInt(5)],
        speed: rng.nextDouble() * 0.4 + 0.3,
        angle: rng.nextDouble() * pi * 2,
      ));
    }

    // 1. Circle burst
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.elasticOut),
    );
    _circleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // 2. Check mark draw-in
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = CurvedAnimation(
      parent: _checkController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // 3. Content slides up
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    // 4. Particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 5. Button bounce in
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    // Sequence the animations
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _circleController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _buttonController.forward();

    // Auto-navigate after 3s
    await Future.delayed(const Duration(milliseconds: 3000));
    _navigateHome();
  }

  void _navigateHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomePageScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    _contentController.dispose();
    _particleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8F5), Color(0xFFFFEDE6), Color(0xFFFFF8F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Background orbs ──────────────────────────────────
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -70,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withOpacity(0.05),
                ),
              ),
            ),

            // ── Confetti particles ───────────────────────────────
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) {
                return CustomPaint(
                  size: size,
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                  ),
                );
              },
            ),

            // ── Main card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Check circle
                  AnimatedBuilder(
                    animation: _circleController,
                    builder: (_, __) {
                      return Opacity(
                        opacity: _circleOpacity.value,
                        child: Transform.scale(
                          scale: _circleScale.value,
                          child: _buildCheckCircle(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  // Text content
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, child) {
                      return Opacity(
                        opacity: _contentOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _contentSlide.value),
                          child: child,
                        ),
                      );
                    },
                    child: _buildContent(),
                  ),

                  const SizedBox(height: 48),

                  // Button
                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (_, child) {
                      return Transform.scale(
                        scale: _buttonScale.value,
                        child: child,
                      );
                    },
                    child: _buildButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Check circle ─────────────────────────────────────────────────────────

  Widget _buildCheckCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primary.withOpacity(0.08),
          ),
        ),
        // Middle ring
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primary.withOpacity(0.12),
          ),
        ),
        // Main circle
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_primary, _primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.45),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _checkController,
            builder: (_, __) {
              return Opacity(
                opacity: _checkOpacity.value,
                child: Transform.scale(
                  scale: _checkScale.value,
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Text content ─────────────────────────────────────────────────────────

  Widget _buildContent() {
    final name = widget.userName;

    return Column(
      children: [
        Text(
          name != null ? 'Welcome, $name!' : 'Login Successful!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You have successfully signed in.\nTaking you to the dashboard…',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),

        // Auto-redirect countdown chip
        _CountdownChip(
          duration: const Duration(seconds: 3),
          onComplete: _navigateHome,
        ),
      ],
    );
  }

  // ── Button ───────────────────────────────────────────────────────────────

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [_primary, _primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.38),
              blurRadius: 20,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _navigateHome,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Go to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Countdown chip
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownChip extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;

  const _CountdownChip({required this.duration, required this.onComplete});

  @override
  State<_CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<_CountdownChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _primary = Color(0xFFE84E0F);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final remaining =
            ((1 - _ctrl.value) * widget.duration.inSeconds).ceil();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFFFFDDD3)),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Text(
                'Redirecting in ${remaining}s',
                style: const TextStyle(
                  fontSize: 13,
                  color: _primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle painter
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double angle;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      final opacity = (1.0 - t).clamp(0.0, 1.0);

      final dx = p.x * size.width + cos(p.angle) * t * 120;
      final dy = p.y * size.height - t * 180 * p.speed;

      final paint = Paint()
        ..color = p.color.withOpacity(opacity * 0.85)
        ..style = PaintingStyle.fill;

      // Alternate circles and squares
      if (particles.indexOf(p) % 2 == 0) {
        canvas.drawCircle(Offset(dx, dy), p.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(t * pi * 3);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
