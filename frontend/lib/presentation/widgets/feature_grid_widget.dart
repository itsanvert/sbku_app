import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

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

class _FeatureGridState extends State<FeatureGrid> {
  late List<FeatureItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.features);
  }

  @override
  void didUpdateWidget(FeatureGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.features != oldWidget.features) {
      _items = List.from(widget.features);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primary = Color(0xFFFF6A00);

    // Theme-aware defaults
    final effectiveIconColor = widget.defaultIconColor ?? primary;
    final effectiveLabelColor = widget.defaultLabelColor ??
        (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937));
    final effectiveBorderColor = widget.defaultBorderColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB));
    final effectiveShadowColor = widget.defaultShadowColor ??
        (isDark ? Colors.black54 : Colors.black12);
    final effectiveBackgroundColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : Colors.white);

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

        return KeyedSubtree(
          key: ValueKey('feature_${feature.label}'),
          child: InkWell(
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
                    color: featureIconColor.withValues(alpha: isDark ? 0.3 : 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [

                    BoxShadow(
                      color: effectiveShadowColor.withValues(alpha: isDark ? 0.2 : 0.03),
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

                    // Clean Flat Icon Pill
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: featureIconColor.withValues(alpha: 0.08),
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
          ),
        );
      },
    );
  }
}
