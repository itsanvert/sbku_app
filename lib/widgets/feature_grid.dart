import 'package:flutter/material.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': Icons.school, 'label': 'សិស្ស'},
      {'icon': Icons.event, 'label': 'សកម្មភាព'},
      {'icon': Icons.list_alt, 'label': 'ព័ត៌មាន'},
      {'icon': Icons.people, 'label': 'គ្រូបង្រៀន'},
      {'icon': Icons.group, 'label': 'និស្សិត'},
      {'icon': Icons.more_horiz, 'label': 'ផ្សេងៗ'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF6A00)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                features[index]['icon'] as IconData,
                color: const Color(0xFFFF6A00),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                features[index]['label'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF6A00),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
