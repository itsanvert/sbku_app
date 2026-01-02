// widget/filter_dropdown_widget.dart
import 'package:flutter/material.dart';

class FilterDropdownWidget extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color? iconColor;
  final Color? hintColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final bool showAllOption;

  const FilterDropdownWidget({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.iconColor,
    this.hintColor,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? const Color(0xFFFF6A00);
    final effectiveHintColor = hintColor ?? const Color(0xFFFF6A00);
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? Colors.grey[200]!;
    final effectiveIcon = icon ?? Icons.filter_alt;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: effectiveBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        hint: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(effectiveIcon, color: effectiveIconColor, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                hint,
                style: TextStyle(color: effectiveHintColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        items: [
          ...items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ],
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 14),
        icon: Icon(Icons.arrow_drop_down, color: effectiveIconColor),
      ),
    );
  }
}
