import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_list_catgories.dart';
import 'package:sbku_app/presentation/screens/staff/staff_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/student/student_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/syllabus/syllabus_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/request_permission_screen.dart';
import 'package:sbku_app/presentation/screens/teacher/teacher_list_screen.dart';
import 'package:sbku_app/presentation/screens/messages/message_list_screen.dart';

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
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const GreetingCard(),
            ),
            FeatureGrid(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              features: const [
                FeatureItem(
                  icon: Icons.people,
                  label: 'គ្រូបង្រៀន',
                  screen: TeacherListViewScreen(),
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
                  screen: const RequestPermissionScreen(),
                ),
                FeatureItem(
                  icon: Icons.subject,
                  label: 'តារាងមុខវិជ្ជា',
                  screen: SyllabusListViewScreen(),
                ),
                FeatureItem(
                  icon: Icons.notifications_active_outlined,
                  label: 'សារជូនដំណឹង',
                  screen: const MessageListScreen(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ImageSlider.campus(
                imagePaths: const [
                  'assets/images/campus.png',
                  'assets/images/campus.png',
                  'assets/images/campus.png',
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
