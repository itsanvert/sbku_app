import 'package:flutter/material.dart';

class FeatureItem {
  final IconData icon;
  final String label;
  final Widget? screen;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Color? borderColor;

  const FeatureItem({
    required this.icon,
    required this.label,
    this.screen,
    this.onTap,
    this.iconColor,
    this.labelColor,
    this.borderColor,
  });
}

class FeatureGrid extends StatelessWidget {
  final List<FeatureItem> features;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final Color? defaultIconColor;
  final Color? defaultLabelColor;
  final Color? defaultBorderColor;
  final Color? defaultShadowColor;
  final Color? backgroundColor;
  final double? iconSize;
  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final double borderRadius;
  final double topBarHeight;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const FeatureGrid({
    super.key,
    required this.features,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 0.9,
    this.defaultIconColor,
    this.defaultLabelColor,
    this.defaultBorderColor,
    this.defaultShadowColor,
    this.backgroundColor,
    this.iconSize,
    this.labelFontSize,
    this.labelFontWeight,
    this.borderRadius = 14,
    this.topBarHeight = 6,
    this.padding,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primary = Color(0xFFFF6A00);

    // Theme-aware defaults
    final effectiveIconColor = defaultIconColor ?? primary;
    final effectiveLabelColor = defaultLabelColor ??
        (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151));
    final effectiveBorderColor = defaultBorderColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB));
    final effectiveShadowColor = defaultShadowColor ??
        (isDark ? Colors.black45 : Colors.black12);
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : Colors.white);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: features.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];
        final isEnabled = feature.screen != null || feature.onTap != null;
        final featureIconColor = feature.iconColor ?? effectiveIconColor;
        final featureBorderColor = feature.borderColor ?? primary;

        return InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isEnabled
              ? () {
                  if (feature.onTap != null) {
                    feature.onTap!();
                  } else if (feature.screen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => feature.screen!,
                      ),
                    );
                  }
                }
              : null,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.45,
            child: Container(
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: feature.borderColor ?? effectiveBorderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveShadowColor.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top accent bar
                  Container(
                    height: topBarHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [featureBorderColor, featureBorderColor.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(borderRadius),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Icon with background pill
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: featureIconColor.withOpacity(0.12),
                    ),
                    child: Icon(
                      feature.icon,
                      size: iconSize ?? 26,
                      color: featureIconColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      feature.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: labelFontSize ?? 12.5,
                        fontWeight: labelFontWeight ?? FontWeight.w600,
                        color: feature.labelColor ?? effectiveLabelColor,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
