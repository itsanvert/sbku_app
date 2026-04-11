import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/presentation/screens/welcome/login_screen.dart';
import 'package:sbku_app/providers/auth_provider.dart';

enum AppBarType {
  home, // Logo + Title + Actions
  simple, // Back button + Title
  custom, // Custom leading + Title + Actions
}

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final AppBarType type;
  final String? title;
  final String? subtitle;
  final String? logoPath;
  final double height;
  final List<Color>? gradientColors;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final bool automaticallyImplyLeading;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool enableScaling;
  final double? customScaleFactor;
  final bool showBottomShadow;

  const AppBarWidget({
    super.key,
    this.type = AppBarType.simple,
    this.title,
    this.subtitle,
    this.logoPath,
    this.height = 80,
    this.gradientColors,
    this.actions,
    this.leading,
    this.onBackPressed,
    this.automaticallyImplyLeading = true,
    this.titleStyle,
    this.subtitleStyle,
    this.enableScaling = true,
    this.customScaleFactor,
    this.showBottomShadow = true,
  });

  factory AppBarWidget.home({
    Key? key,
    String? logoPath,
    String? title,
    String? subtitle,
    List<Widget>? actions,
    double height = 90,
    List<Color>? gradientColors,
    bool enableScaling = true,
  }) {
    return AppBarWidget(
      key: key,
      type: AppBarType.home,
      logoPath: logoPath ?? 'assets/images/logo.jpg',
      title: title ?? 'សាកលវិទ្យាល័យសម្តេចព្រះមហាសង្ឃរាជ បួរ គ្រី',
      subtitle: subtitle ?? 'Samdech Preah Mahasangharajah Bour Kry University',
      actions: actions,
      height: height,
      gradientColors: gradientColors,
      enableScaling: enableScaling,
    );
  }

  factory AppBarWidget.simple({
    Key? key,
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    double height = 75,
    List<Color>? gradientColors,
    TextStyle? titleStyle,
    bool enableScaling = true,
  }) {
    return AppBarWidget(
      key: key,
      type: AppBarType.simple,
      title: title,
      onBackPressed: onBackPressed,
      actions: actions,
      height: height,
      gradientColors: gradientColors,
      titleStyle: titleStyle,
      enableScaling: enableScaling,
    );
  }

  factory AppBarWidget.custom({
    Key? key,
    required String title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    double height = 75,
    List<Color>? gradientColors,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    bool enableScaling = true,
  }) {
    return AppBarWidget(
      key: key,
      type: AppBarType.custom,
      title: title,
      subtitle: subtitle,
      leading: leading,
      actions: actions,
      height: height,
      gradientColors: gradientColors,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      enableScaling: enableScaling,
    );
  }

  double _getScaleFactor(double screenWidth) {
    if (customScaleFactor != null) return customScaleFactor!;
    if (!enableScaling) return 1.0;
    if (screenWidth < 360) return 0.85;
    if (screenWidth < 420) return 0.95;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = _getScaleFactor(screenWidth);
    final topPadding = MediaQuery.of(context).padding.top;

    final defaultGradientColors = gradientColors ??
        (isDark
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFFFF6A00), const Color(0xFF9C3701)]);

    // We use a custom Container with Safe Area to achieve the premium look
    // while still respecting PreferredSize for the Scaffold
    Widget content = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: defaultGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showBottomShadow
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : defaultGradientColors.last.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // ── Decorative background ───────────────────────────
          Positioned(
            top: -10,
            right: -10,
            child: _decorativeOrb(70, Colors.white.withOpacity(isDark ? 0.03 : 0.08)),
          ),
          Positioned(
            bottom: 5,
            left: screenWidth * 0.2,
            child: _decorativeOrb(30, Colors.white.withOpacity(isDark ? 0.02 : 0.05)),
          ),

          // ── App Bar Contents ────────────────────────────────
          Column(
            children: [
              SizedBox(height: topPadding),
              SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      // 1. Leading
                      _buildLeading(context),

                      const SizedBox(width: 4),

                      // 2. Title Section
                      Expanded(child: _buildTitle()),

                      // 3. Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildActions(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (enableScaling && scaleFactor != 1.0) {
      return Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.diagonal3Values(1.0, scaleFactor, 1.0),
        child: content,
      );
    }

    return content;
  }

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;

    switch (type) {
      case AppBarType.home:
        return Container(
          margin: const EdgeInsets.only(left: 12),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border:
                Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                logoPath!,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 22.5),
              ),
            ),
          ),
        );

      case AppBarType.simple:
        if (automaticallyImplyLeading && Navigator.canPop(context)) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _circularActionIcon(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              size: 20,
            ),
          );
        }
        return const SizedBox(width: 16);

      case AppBarType.custom:
        return const SizedBox(width: 16);
    }
  }

  Widget _buildTitle() {
    final isHome = type == AppBarType.home ||
        (type == AppBarType.custom && subtitle != null);

    if (isHome) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle ??
                  const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.1,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 1),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle ??
                    TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.1,
                      letterSpacing: 0.1,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title ?? '',
        style: titleStyle ??
            const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (actions != null) return actions!;

    if (type == AppBarType.home) {
      return [
        _circularActionIcon(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ];
    }
    return [const SizedBox(width: 12)];
  }

  Widget _circularActionIcon({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 22,
  }) {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }

  Widget _decorativeOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
