// widget/filter_row_widget.dart
import 'package:flutter/material.dart';
import 'filter_dropdown_widget.dart';

class FilterConfig {
  final String? value;
  final String hint;
  final List<String> items;
  final String Function(String)? labelBuilder;
  final ValueChanged<String?> onChanged;

  FilterConfig({
    required this.value,
    required this.hint,
    required this.items,
    this.labelBuilder,
    required this.onChanged,
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
                labelBuilder: filter.labelBuilder,
                hint: filter.hint,
                items: filter.items,
                onChanged: filter.onChanged,
              ),
            );
          },
        ),
      ),
    );
  }
}
