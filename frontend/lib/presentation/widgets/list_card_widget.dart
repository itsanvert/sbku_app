import 'package:flutter/material.dart';

/// A reusable card item for list-based navigation
class ListCardItem {
  final IconData icon;
  final String label;
  final Widget? screen;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Color? borderColor;

  const ListCardItem({
    required this.icon,
    required this.label,
    this.screen,
    this.onTap,
    this.iconColor,
    this.labelColor,
    this.borderColor,
  });
}

/// A reusable list of navigation cards with tab-style design
class ListCardList extends StatelessWidget {
  final List<ListCardItem> items;
  final EdgeInsets? padding;
  final double itemSpacing;
  final Color? defaultBorderColor;
  final Color? defaultLabelColor;
  final List<Color>? tabGradientColors;
  final bool showSnackBar;
  final String? snackBarPrefix;

  const ListCardList({
    super.key,
    required this.items,
    this.padding,
    this.itemSpacing = 50,
    this.defaultBorderColor,
    this.defaultLabelColor,
    this.tabGradientColors,
    this.showSnackBar = false,
    this.snackBarPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors adapt to theme
    final effectiveBorderColor = defaultBorderColor ??
        (isDark ? theme.primaryColor.withOpacity(0.6) : theme.primaryColor);
    final effectiveLabelColor = defaultLabelColor ??
        (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937));

    return ListView.builder(
      padding: padding ?? const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEnabled = item.screen != null || item.onTap != null;

        return Padding(
          padding: EdgeInsets.only(bottom: itemSpacing),
          child: TabStyleCard(
            contentLabel: item.label,
            icon: item.icon,
            borderColor: item.borderColor ?? effectiveBorderColor,
            labelColor: item.labelColor ?? effectiveLabelColor,
            tabGradientColors: tabGradientColors,
            isEnabled: isEnabled,
            isDark: isDark,
            onTap: isEnabled
                ? () {
                    if (showSnackBar) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${snackBarPrefix ?? 'បើក'} ${item.label}'),
                          backgroundColor: item.borderColor ?? effectiveBorderColor,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }

                    if (item.onTap != null) {
                      item.onTap!();
                    } else if (item.screen != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item.screen!),
                      );
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}

/// Individual tab-style card widget
class TabStyleCard extends StatelessWidget {
  final String contentLabel;
  final IconData icon;
  final VoidCallback? onTap;
  final Color borderColor;
  final Color labelColor;
  final List<Color>? tabGradientColors;
  final bool isEnabled;
  final bool isDark;
  final double height;
  final double borderWidth;
  final double tabHeight;
  final double tabWidth;
  final double borderRadius;

  const TabStyleCard({
    super.key,
    required this.contentLabel,
    required this.icon,
    this.onTap,
    this.borderColor = const Color(0xFFFF6A00),
    this.labelColor = const Color(0xFF1F2937),
    this.tabGradientColors,
    this.isEnabled = true,
    this.isDark = false,
    this.height = 68,
    this.borderWidth = 1.5,
    this.tabHeight = 10,
    this.tabWidth = 200,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradientColors = tabGradientColors ??
        [
          const Color(0xFFFF6A00),
          const Color(0xFF9C3701),
        ];

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark
        ? borderColor.withOpacity(0.5)
        : borderColor.withOpacity(0.4);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius + 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Main card ───────────────────────────────────────
            Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: cardBorder, width: borderWidth),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6A00).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: const Color(0xFFFF6A00), size: 22),
                    ),
                    const SizedBox(width: 14),
                    // Label
                    Expanded(
                      child: Text(
                        contentLabel,
                        style: TextStyle(
                          fontSize: 16,
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFD1D5DB),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab header ──────────────────────────────────────
            Positioned(
              top: -5,
              left: 16,
              child: Container(
                height: tabHeight,
                width: tabWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: effectiveGradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6A00).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

