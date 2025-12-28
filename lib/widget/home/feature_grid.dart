import 'package:flutter/material.dart';
import 'package:sbku_app/screen/attendance/attendance_list_catgories.dart';
import 'package:sbku_app/screen/student/student_list.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.people,
        'label': 'គ្រូបង្រៀន',
        // 'screen': const TeacherScreen(),
      },
      {
        'icon': Icons.school,
        'label': 'សិស្ស',
        'screen': const StudentListScreen(),
      },
      {
        'icon': Icons.group, 'label': 'បុគ្គលិក',
        // 'screen': const EmployeeListScreen(),
      },
      {
        'icon': Icons.event,
        'label': 'អវត្តមាន',
        'screen': const AttendanceListCategoryScreen()
      },
      {
        'icon': Icons.list_alt, 'label': 'ស្នើរសុំច្បាប់',
        //  'screen': const RequestLeaveScreen(),
      },
      {
        'icon': Icons.subject, 'label': 'តារាងមុខវិជ្ជា',
        //  'screen': const SubjectListScreen(),
      },
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
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => features[index]['screen'] as Widget,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFF6A00)),
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
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5E00),
                    borderRadius: BorderRadius.vertical(
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF5500),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
