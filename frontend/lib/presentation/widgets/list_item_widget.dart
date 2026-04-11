import 'package:flutter/material.dart';

/// A generic list item widget that displays an entity with avatar, info, and actions
class ListItemWidget<T> extends StatelessWidget {
  final T item;
  final String title;
  final String? subtitle;
  final String? trailingSubtitle;
  final String? avatarText;
  final String? avatarImageUrl;
  final Color? avatarBackgroundColor;
  final Color? avatarTextColor;
  final List<ItemAction> actions;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? avatarSize;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Widget? trailing;
  final Widget? leading;
  final CrossAxisAlignment? contentAlignment;
  final double spacing;

  const ListItemWidget({
    super.key,
    required this.item,
    required this.title,
    this.subtitle,
    this.trailingSubtitle,
    this.avatarText,
    this.avatarImageUrl,
    this.avatarBackgroundColor,
    this.avatarTextColor,
    this.actions = const [],
    this.onTap,
    this.margin,
    this.padding,
    this.avatarSize,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.trailing,
    this.leading,
    this.contentAlignment,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveMargin =
        margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
    final effectivePadding = padding ?? const EdgeInsets.all(14);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(14);
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : Colors.white);
    final effectiveBorderColor = borderColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB));

    Widget content = Row(
      children: [
        // Leading widget (avatar or custom)
        if (leading != null)
          leading!
        else if (avatarText != null || avatarImageUrl != null)
          _buildAvatar(isDark),

        if (leading != null || avatarText != null || avatarImageUrl != null)
          SizedBox(width: spacing),

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: contentAlignment ?? CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),

        // Actions or trailing widget
        if (trailing != null)
          trailing!
        else if (trailingSubtitle != null)
          Text(
            trailingSubtitle!,
            style: theme.textTheme.bodySmall,
          )
        else if (actions.isNotEmpty)
          _buildActions(context),
      ],
    );

    return Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: effectiveBorderColor),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Padding(
            padding: effectivePadding,
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    final size = avatarSize ?? 44.0;
    final bgColor = avatarBackgroundColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6));
    final txtColor = avatarTextColor ??
        (isDark ? Colors.white70 : const Color(0xFF374151));

    if (avatarImageUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(avatarImageUrl!),
        backgroundColor: bgColor,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Center(
        child: Text(
          avatarText ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: txtColor,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) {
        if (action.isIcon) {
          return IconButton(
            onPressed: action.onPressed,
            icon: Icon(action.icon, color: action.color),
            tooltip: action.label,
          );
        }
        return TextButton(
          onPressed: action.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: action.color,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
          ),
          child: Text(
            action.label,
            style: TextStyle(
              color: action.color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Action button configuration for list items
class ItemAction {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final IconData? icon;
  final bool isIcon;

  const ItemAction({
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.isIcon = false,
  });

  factory ItemAction.text({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ItemAction(
      label: label,
      onPressed: onPressed,
      color: color,
      isIcon: false,
    );
  }

  factory ItemAction.icon({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ItemAction(
      label: label,
      onPressed: onPressed,
      color: color,
      icon: icon,
      isIcon: true,
    );
  }
}
