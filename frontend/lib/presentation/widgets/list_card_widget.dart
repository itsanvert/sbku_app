import 'package:flutter/material.dart';
import 'shimmer_widget.dart';

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

class ListCardListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;
  final double itemSpacing;
  final double borderRadius;

  const ListCardListSkeleton({
    super.key,
    this.itemCount = 4,
    this.padding,
    this.itemSpacing = 50,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark
        ? const Color(0xFFFF6A00).withOpacity(0.5)
        : const Color(0xFFFF6A00).withOpacity(0.4);

    return ListView.builder(
      padding: padding ?? const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: itemSpacing),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 68,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: cardBorder, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      const ShimmerWidget(width: 40, height: 40, borderRadius: 10),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShimmerWidget(
                              width: 140,
                              height: 16,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const ShimmerWidget(width: 16, height: 16, borderRadius: 4),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -5,
                left: 16,
                child: Container(
                  height: 10,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF6A00).withOpacity(0.5),
                        const Color(0xFF9C3701).withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton that mirrors the TeacherActiveSessionsList card layout
class ActiveSessionCardSkeleton extends StatelessWidget {
  final int itemCount;

  const ActiveSessionCardSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: 40, height: 40, borderRadius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ShimmerWidget(width: 140, height: 16, borderRadius: 4),
                          ),
                          const SizedBox(width: 8),
                          ShimmerWidget(width: 48, height: 20, borderRadius: 8),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ShimmerWidget(width: 180, height: 12, borderRadius: 4),
                      const SizedBox(height: 4),
                      ShimmerWidget(width: 120, height: 12, borderRadius: 4),
                      const SizedBox(height: 4),
                      ShimmerWidget(width: 100, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ShimmerWidget(width: 14, height: 14, borderRadius: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton that mirrors the Syllabus curriculum list layout
class SyllabusCardSkeleton extends StatelessWidget {
  final int yearCount;

  const SyllabusCardSkeleton({super.key, this.yearCount = 2});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: yearCount,
      itemBuilder: (context, index) {
        return Card(
          elevation: isDark ? 0 : 2,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFF1E3A8A),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ShimmerWidget(
                  width: 100,
                  height: 16,
                  borderRadius: 4,
                  baseColor: Colors.white30,
                  highlightColor: Colors.white60,
                ),
              ),
              // Semester section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    ShimmerWidget(width: 18, height: 18, borderRadius: 9),
                    const SizedBox(width: 8),
                    ShimmerWidget(width: 80, height: 14, borderRadius: 4),
                  ],
                ),
              ),
              Divider(
                height: 1,
                endIndent: 16,
                indent: 16,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              // Subject tiles
              ...List.generate(3, (i) => _buildSubjectTile(isDark)),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectTile(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.withOpacity(0.12) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: ShimmerWidget(width: 160, height: 14, borderRadius: 4)),
                ShimmerWidget(width: 60, height: 18, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ShimmerWidget(width: 14, height: 14, borderRadius: 7),
                const SizedBox(width: 4),
                ShimmerWidget(width: 100, height: 12, borderRadius: 4),
                const Spacer(),
                ShimmerWidget(width: 14, height: 14, borderRadius: 7),
                const SizedBox(width: 4),
                ShimmerWidget(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

