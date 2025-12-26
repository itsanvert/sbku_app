import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return AppBar(
      toolbarHeight: 80,
      leadingWidth: 70,

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6A00), Color(0xFF9C3701)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),

      // Logo with improved quality
      leading: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 4),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: SvgPicture.asset(
            'assets/images/sbku-logo.svg',
            width: 160,
            height: 160,
          ),
        ),
      ),

      // Responsive title section
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'សាកលវិទ្យាល័យសម្តេចព្រះមហាសង្ឃរាជ បួរ គ្រី',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            'Samdech Preah Mahasangharajah Bour Kry University',
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 10.5,
              color: Colors.white.withOpacity(0.95),
              letterSpacing: 0.1,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),

      // Notification button
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 26),
          color: Colors.white,
          splashRadius: 24,
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 4),
      ],

      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

// Alternative: Use SVG for even better quality
// If you have the logo as SVG, use flutter_svg package:
/*
import 'package:flutter_svg/flutter_svg.dart';

// In pubspec.yaml add:
// dependencies:
//   flutter_svg: ^2.0.9

// Then replace Image.asset with:
SvgPicture.asset(
  'assets/images/sbku-logo.svg',
  fit: BoxFit.contain,
  colorFilter: null, // Preserves original colors
) ;
*/
