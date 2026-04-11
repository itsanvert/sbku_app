import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_history_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_start_attendance_session_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/qr_scan_attendance_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_sessions_list.dart';

import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/list_card_widget.dart';

import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';

class AttendanceListCategoryScreen extends StatelessWidget {
  const AttendanceListCategoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final role = user?.role?.toLowerCase();
    final bool showTeacherMenu = role == 'teacher' || role == 'admin';

    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីវត្តមាន',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListCardList(
            items: showTeacherMenu ? _teacherMenuItems() : _studentMenuItems(),
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
        screen: const QrScanAttendanceScreen(),
      ),
      ListCardItem(
        icon: Icons.history,
        label: 'ប្រវត្តិវត្តមានរបស់ខ្ញុំ',
        screen: StudentAttendanceHistoryScreen(),
      ),
    ];
  }
}
