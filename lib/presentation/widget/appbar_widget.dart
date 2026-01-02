import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  });

  // Home header factory constructor
  factory AppBarWidget.home({
    Key? key,
    String? logoPath,
    String? title,
    String? subtitle,
    List<Widget>? actions,
    double height = 80,
    List<Color>? gradientColors,
    bool enableScaling = true,
  }) {
    return AppBarWidget(
      key: key,
      type: AppBarType.home,
      logoPath: logoPath ?? 'assets/images/sbku-logo.svg',
      title: title ?? 'សាកលវិទ្យាល័យសម្តេចព្រះមហាសង្ឃរាជ បួរ គ្រី',
      subtitle: subtitle ?? 'Samdech Preah Mahasangharajah Bour Kry University',
      actions: actions,
      height: height,
      gradientColors: gradientColors,
      enableScaling: enableScaling,
    );
  }

  // Simple header factory constructor
  factory AppBarWidget.simple({
    Key? key,
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    double height = 80,
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

  // Custom header factory constructor
  factory AppBarWidget.custom({
    Key? key,
    required String title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    double height = 80,
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

  Widget _buildLeading(BuildContext context) {
    switch (type) {
      case AppBarType.home:
        return Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 4),
          child: SvgPicture.asset(
            logoPath!,
            fit: BoxFit.contain,
          ),
        );
      case AppBarType.simple:
        if (leading != null) return leading!;
        if (automaticallyImplyLeading && Navigator.canPop(context)) {
          return IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBackPressed ?? () => Navigator.pop(context),
          );
        }
        return const SizedBox.shrink();
      case AppBarType.custom:
        return leading ?? const SizedBox.shrink();
    }
  }

  Widget _buildTitle() {
    if (type == AppBarType.home ||
        (type == AppBarType.custom && subtitle != null)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle ??
                const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle ??
                  const TextStyle(
                    fontSize: 10.5,
                    color: Colors.white70,
                    height: 1.2,
                  ),
            ),
          ],
        ],
      );
    }

    return Text(
      title ?? '',
      style: titleStyle ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
    );
  }

  List<Widget> _buildActions() {
    if (type == AppBarType.home && actions == null) {
      return [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 26),
          color: Colors.white,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ];
    }
    return actions ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = _getScaleFactor(screenWidth);

    final defaultGradientColors =
        gradientColors ?? [const Color(0xFFFF6A00), const Color(0xFF9C3701)];

    final appBar = AppBar(
      toolbarHeight: height,
      leadingWidth: type == AppBarType.home ? 70 : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: defaultGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: _buildLeading(context),
      title: _buildTitle(),
      actions: _buildActions(),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    if (enableScaling && scaleFactor != 1.0) {
      return PreferredSize(
        preferredSize: preferredSize,
        child: Transform.scale(
          scale: scaleFactor,
          alignment: Alignment.topCenter,
          child: appBar,
        ),
      );
    }

    return appBar;
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
