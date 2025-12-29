// widget/filter_row_widget.dart
import 'package:flutter/material.dart';
import 'filter_dropdown_widget.dart';

class FilterConfig {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? icon;
  final Color? iconColor;
  final Color? hintColor;

  const FilterConfig({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.icon,
    this.iconColor,
    this.hintColor,
  });
}

class FilterRowWidget extends StatelessWidget {
  final List<FilterConfig> filters;
  final EdgeInsets? padding;
  final double spacing;
  final Color? defaultIconColor;
  final Color? defaultHintColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showAllOption;
  final String allOptionLabel;

  const FilterRowWidget({
    super.key,
    required this.filters,
    this.padding,
    this.spacing = 8,
    this.defaultIconColor,
    this.defaultHintColor,
    this.backgroundColor,
    this.borderColor,
    this.showAllOption = true,
    this.allOptionLabel = 'ទាំងអស់',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Row(
        children: List.generate(
          filters.length * 2 - 1,
          (index) {
            if (index.isOdd) {
              return SizedBox(width: spacing);
            }

            final filterIndex = index ~/ 2;
            final filter = filters[filterIndex];

            return Expanded(
              child: FilterDropdownWidget(
                value: filter.value,
                hint: filter.hint,
                items: filter.items,
                onChanged: filter.onChanged,
                icon: filter.icon,
                iconColor: filter.iconColor ?? defaultIconColor,
                hintColor: filter.hintColor ?? defaultHintColor,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                showAllOption: showAllOption,
                allOptionLabel: allOptionLabel,
              ),
            );
          },
        ),
      ),
    );
  }
}
