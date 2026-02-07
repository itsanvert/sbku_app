import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_list_catgories.dart';
import 'package:sbku_app/presentation/screens/staff/staff_list_view_screen.dart';

import 'package:sbku_app/presentation/screens/student/student_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/syllabus/syllabus_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/teacher/teacher_list_screen.dart';

import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/campus_slider_widget.dart';
import 'package:sbku_app/presentation/widgets/greeting_card_widget.dart';
import 'package:sbku_app/presentation/widgets/feature_grid_widget.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.home(
        enableScaling: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const GreetingCard(),
            const SizedBox(height: 16),
            FeatureGrid(
              features: const [
                FeatureItem(
                  icon: Icons.people,
                  label: 'គ្រូបង្រៀន',
                  screen: TeacherListScreen(),
                ),
                FeatureItem(
                  icon: Icons.school,
                  label: 'សិស្ស',
                  screen: StudentListViewScreen(), // ✅ This will now work
                ),
                FeatureItem(
                  icon: Icons.group,
                  label: 'បុគ្គលិក',
                  screen: StaffListViewScreen(),
                ),
                FeatureItem(
                  icon: Icons.event,
                  label: 'អវត្តមាន',
                  screen: AttendanceListCategoryScreen(),
                ),
                FeatureItem(
                  icon: Icons.list_alt,
                  label: 'ស្នើរសុំច្បាប់',
                  // screen: SqliteSamplePage(),
                ),
                FeatureItem(
                  icon: Icons.subject,
                  label: 'តារាងមុខវិជ្ជា',
                  screen: SyllabusListViewScreen(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ImageSlider.campus(
              imagePaths: const [
                'assets/images/campus.png',
                'assets/images/campus.png',
                'assets/images/campus.png',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
