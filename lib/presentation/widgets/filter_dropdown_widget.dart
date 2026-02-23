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
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,

      // ✅ SHOW HINT WHEN value == null
      hint: Text(
        hint,
        style: const TextStyle(
          color: Color(0xFFFF6A00),
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),

      // ✅ ITEMS (WITH "ALL" OPTION)
      items: [
        // 🔹 ALL OPTION
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            hint,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),

        // 🔹 REAL ITEMS
        ...items.map((id) {
          final label = labelBuilder?.call(id) ?? id;
          return DropdownMenuItem<String>(
            value: id,
            child: Text(label, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ],

      // ✅ SELECTED TEXT BUILDER
      selectedItemBuilder: (context) {
        return [
          // For "All"
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hint,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

          // For real items
          ...items.map((id) {
            final label = labelBuilder?.call(id) ?? id;
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ];
      },

      onChanged: onChanged,

      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: value == null ? Colors.grey.shade300 : Colors.orange,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
      ),

      icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
    );
  }
}
