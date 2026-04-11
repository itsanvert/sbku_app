import 'package:flutter/material.dart';

class FilterDropdownWidget extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? labelBuilder;

  const FilterDropdownWidget({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final textStyle = theme.textTheme.bodyMedium!;
    final activeTextStyle = theme.textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.w600,
    );

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      style: activeTextStyle,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 22),

      // Hint
      hint: Text(
        hint,
        style: textStyle.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),

      // Items
      items: [
        // "All" option
        DropdownMenuItem<String>(
          value: null,
          child: Text(hint, style: textStyle),
        ),
        ...items.map((id) {
          final label = labelBuilder?.call(id) ?? id;
          return DropdownMenuItem<String>(
            value: id,
            child: Text(label, overflow: TextOverflow.ellipsis, style: activeTextStyle),
          );
        }),
      ],

      // Selected item builder
      selectedItemBuilder: (context) {
        return [
          Align(alignment: Alignment.centerLeft, child: Text(hint, style: textStyle)),
          ...items.map((id) {
            final label = labelBuilder?.call(id) ?? id;
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(label, overflow: TextOverflow.ellipsis, style: activeTextStyle),
            );
          }),
        ];
      },

      onChanged: onChanged,

      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: value == null
                ? (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB))
                : primaryColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
