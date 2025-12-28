import 'package:flutter/material.dart';

class AttendanceCardWidget extends StatelessWidget {
  const AttendanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.list_alt,
        'label': 'បញ្ចីអវត្តមាន',
      },
      {
        'icon': Icons.subject,
        'label': 'ដំណើរការអវត្តមាន',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.only(top: 50), // remove default top padding
      itemCount: features.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: TabStyleCard(
            contentLabel: features[index]['label'] as String,
            icon: features[index]['icon'] as IconData,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('បើក ${features[index]['label']}'),
                  backgroundColor: const Color(0xFFE74C3C),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class TabStyleCard extends StatelessWidget {
  final String contentLabel;
  final IconData icon;
  final VoidCallback onTap;

  const TabStyleCard({
    Key? key,
    required this.contentLabel,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main container
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE74C3C),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 25, bottom: 15),
              child: Row(
                children: [
                  // Icon

                  const SizedBox(width: 15),

                  // Content label
                  Expanded(
                    child: Text(
                      contentLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFE74C3C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Arrow icon
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFE74C3C),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Tab-like header (positioned at top)
          Positioned(
            top: -4,
            left: 15,
            child: Container(
              height: 10,
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 1),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 251, 79, 0),
                    Color.fromARGB(255, 139, 64, 2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE74C3C).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage in a screen
