import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_history_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_list_pending_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/student_check_in_attendance_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_sessions_list.dart';

import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/list_card_widget.dart';

class AttendanceListCategoryScreen extends StatelessWidget {
  final bool isTeacher; // Pass from auth/user role

  const AttendanceListCategoryScreen({
    Key? key,
    this.isTeacher = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីវត្តមាន',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListCardList(
            items: isTeacher ? _teacherMenuItems() : _studentMenuItems(),
          ),
        ),
      ),
    );
  }

  List<ListCardItem> _teacherMenuItems() {
    return [
      ListCardItem(
        icon: Icons.add_location_alt,
        label: 'បើកវេនវត្តមាន',
        screen: TeacherStartAttendanceScreen(),
      ),
      ListCardItem(
        icon: Icons.list_alt,
        label: 'វេនកំពុងដំណើរការ',
        screen: TeacherActiveSessionsListScreen(),
      ),
      ListCardItem(
        icon: Icons.history,
        label: 'ប្រវត្តិវត្តមាន',
        screen: AttendanceHistoryScreen(),
      ),
      ListCardItem(
        icon: Icons.analytics,
        label: 'របាយការណ៍វត្តមាន',
        screen: AttendanceReportScreen(),
      ),
    ];
  }

  List<ListCardItem> _studentMenuItems() {
    return [
      ListCardItem(
        icon: Icons.check_circle_outline,
        label: 'ចុះវត្តមាន',
        screen: StudentAttendanceCheckInScreen(),
      ),
      ListCardItem(
        icon: Icons.history,
        label: 'ប្រវត្តិវត្តមានរបស់ខ្ញុំ',
        screen: StudentAttendanceHistoryScreen(),
      ),
    ];
  }
}
