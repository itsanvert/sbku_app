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
    this.showSnackBar = true,
    this.snackBarPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.only(top: 50),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEnabled = item.screen != null || item.onTap != null;

        return Padding(
          padding: EdgeInsets.only(bottom: itemSpacing),
          child: TabStyleCard(
            contentLabel: item.label,
            icon: item.icon,
            borderColor: item.borderColor ??
                defaultBorderColor ??
                const Color(0xFFE74C3C),
            labelColor:
                item.labelColor ?? defaultLabelColor ?? const Color(0xFFE74C3C),
            tabGradientColors: tabGradientColors,
            isEnabled: isEnabled,
            onTap: isEnabled
                ? () {
                    if (showSnackBar) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('${snackBarPrefix ?? 'បើក'} ${item.label}'),
                          backgroundColor: item.borderColor ??
                              defaultBorderColor ??
                              const Color(0xFFE74C3C),
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
    this.borderColor = const Color(0xFFE74C3C),
    this.labelColor = const Color(0xFFE74C3C),
    this.tabGradientColors,
    this.isEnabled = true,
    this.height = 60,
    this.borderWidth = 2.5,
    this.tabHeight = 10,
    this.tabWidth = 200,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradientColors = tabGradientColors ??
        [
          const Color.fromARGB(255, 251, 79, 0),
          const Color.fromARGB(255, 139, 64, 2),
        ];

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius + 5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main container
            Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Content label
                    Expanded(
                      child: Text(
                        contentLabel,
                        style: TextStyle(
                          fontSize: 18,
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Optional: Add arrow or icon here
                    Icon(
                      Icons.arrow_forward_ios,
                      color: labelColor.withOpacity(0.5),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            // Tab-like header (positioned at top)
            Positioned(
              top: -4,
              left: 15,
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
                      color: borderColor.withOpacity(0.4),
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
