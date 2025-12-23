import 'package:flutter/material.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': Icons.people, 'label': 'គ្រូបង្រៀន'},
      {'icon': Icons.school, 'label': 'សិស្ស'},
      {'icon': Icons.group, 'label': 'បុគ្គលិក'},
      {'icon': Icons.event, 'label': 'អវត្តមាន'},
      {'icon': Icons.list_alt, 'label': 'ស្នើរសុំច្បាប់'},
      {'icon': Icons.subject, 'label': 'តារាងមុខវិជ្ជា'},
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFF6A00), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6A00).withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top orange bar
              Container(
                height: 6,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 94, 0),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14),
                    bottom: Radius.circular(14),
                  ),
                ),
              ),

              const Spacer(),

              Icon(
                features[index]['icon'] as IconData,
                size: 36,
                color: const Color(0xFFFF5E01),
              ),

              const SizedBox(height: 10),

              Text(
                features[index]['label'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF5500),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
