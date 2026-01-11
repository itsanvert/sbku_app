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
    final effectiveIconColor = defaultIconColor ?? const Color(0xFFFF5E01);
    final effectiveLabelColor = defaultLabelColor ?? const Color(0xFFFF5500);
    final effectiveBorderColor = defaultBorderColor ?? const Color(0xFFFF6A00);
    final effectiveShadowColor = defaultShadowColor ?? const Color(0xFFFF6A00);
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;

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
            opacity: isEnabled ? 1.0 : 0.5,
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
                  // Top colored bar
                  Container(
                    height: topBarHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: feature.borderColor ?? effectiveBorderColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(borderRadius),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    feature.icon,
                    size: iconSize ?? 36,
                    color: feature.iconColor ?? effectiveIconColor,
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
                        fontSize: labelFontSize ?? 13,
                        fontWeight: labelFontWeight ?? FontWeight.w600,
                        color: feature.labelColor ?? effectiveLabelColor,
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
