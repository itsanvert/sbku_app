import 'package:flutter/material.dart';

/// A generic list item widget that displays an entity with avatar, info, and actions
class ListItemWidget<T> extends StatelessWidget {
  final T item;
  final String title;
  final String? subtitle;
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
    final effectiveMargin =
        margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final effectivePadding = padding ?? const EdgeInsets.all(16);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? Colors.grey[200]!;

    Widget content = Row(
      children: [
        // Leading widget (avatar or custom)
        if (leading != null)
          leading!
        else if (avatarText != null || avatarImageUrl != null)
          _buildAvatar(),

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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
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
        else if (actions.isNotEmpty)
          _buildActions(context),
      ],
    );

    return Container(
      margin: effectiveMargin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: effectiveBorderColor),
        boxShadow: boxShadow,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: effectiveBorderRadius,
              child: content,
            )
          : content,
    );
  }

  Widget _buildAvatar() {
    final size = avatarSize ?? 40;
    final bgColor = avatarBackgroundColor ?? Colors.purple[50];
    final txtColor = avatarTextColor ?? Colors.purple;

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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Center(
        child: Text(
          avatarText ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: txtColor,
            fontSize: size * 0.4,
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
          child: Text(
            action.label,
            style: TextStyle(color: action.color),
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
