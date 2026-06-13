import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'shimmer_widget.dart';

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

class FeatureGrid extends StatefulWidget {
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
  final Function(List<FeatureItem>)? onReorder;

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
    this.onReorder,
  });

  @override
  State<FeatureGrid> createState() => _FeatureGridState();
}

class _FeatureGridState extends State<FeatureGrid>
    with SingleTickerProviderStateMixin {
  late List<FeatureItem> _items;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.features);
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(FeatureGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.features != oldWidget.features) {
      _items = List.from(widget.features);
      _appearController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primary = Color(0xFFFF6A00);

    final effectiveIconColor = widget.defaultIconColor ?? primary;
    final effectiveLabelColor = widget.defaultLabelColor ??
        (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937));
    final effectiveBorderColor = widget.defaultBorderColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB));
    final effectiveShadowColor = widget.defaultShadowColor ??
        (isDark ? Colors.black54 : Colors.black12);
    final effectiveBackgroundColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : Colors.white);

    return AnimatedBuilder(
      animation: _appearAnim,
      builder: (context, child) {
        return ReorderableGridView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          itemCount: _items.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = _items.removeAt(oldIndex);
              _items.insert(newIndex, item);
            });
            if (widget.onReorder != null) {
              widget.onReorder!(_items);
            }
          },
          dragWidgetBuilder: (index, child) {
            return Transform.scale(
              scale: 1.05,
              child: Material(
                color: Colors.transparent,
                child: child,
              ),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
            childAspectRatio: widget.childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final feature = _items[index];
            final isEnabled = feature.screen != null || feature.onTap != null;
            final featureIconColor = feature.iconColor ?? effectiveIconColor;
            final featureBorderColor = feature.borderColor ?? effectiveBorderColor;

            final staggerDelay = index * 0.08;
            final rawProgress = (_appearController.value - staggerDelay) / 0.28;
            final clamped = rawProgress.clamp(0.0, 1.0);
            final opacity = Curves.easeOutCubic.transform(clamped);
            final scaleVal = Curves.elasticOut.transform(clamped);

            return KeyedSubtree(
              key: ValueKey('feature_${feature.label}'),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: 0.5 + (0.5 * scaleVal),
                  child: _buildTile(
                    feature: feature,
                    isEnabled: isEnabled,
                    featureIconColor: featureIconColor,
                    featureBorderColor: featureBorderColor,
                    effectiveBackgroundColor: effectiveBackgroundColor,
                    effectiveShadowColor: effectiveShadowColor,
                    effectiveLabelColor: effectiveLabelColor,
                    isDark: isDark,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTile({
    required FeatureItem feature,
    required bool isEnabled,
    required Color featureIconColor,
    required Color featureBorderColor,
    required Color effectiveBackgroundColor,
    required Color effectiveShadowColor,
    required Color effectiveLabelColor,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(widget.borderRadius),
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
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: featureIconColor.withOpacity(isDark ? 0.3 : 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveShadowColor.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: featureIconColor.withOpacity(0.08),
                ),
                child: Center(
                  child: Icon(
                    feature.icon,
                    size: widget.iconSize ?? 26,
                    color: featureIconColor,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  feature.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.labelFontSize ?? 13,
                    fontWeight: widget.labelFontWeight ?? FontWeight.w700,
                    color: feature.labelColor ?? effectiveLabelColor,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureGridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final double borderRadius;

  const FeatureGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 0.9,
    this.padding,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF334155).withOpacity(0.5)
        : const Color(0xFFE5E7EB).withOpacity(0.5);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const ShimmerWidget(width: 52, height: 52, borderRadius: 26),
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerWidget(
                  width: double.infinity,
                  height: 13,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ShimmerWidget(
                  width: double.infinity,
                  height: 13,
                  borderRadius: 4,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}
