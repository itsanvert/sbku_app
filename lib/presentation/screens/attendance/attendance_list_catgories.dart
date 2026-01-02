import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_list_view_screen.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/list_card_widget.dart';

class AttendanceListCategoryScreen extends StatelessWidget {
  const AttendanceListCategoryScreen({Key? key}) : super(key: key);

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
            items: [
              ListCardItem(
                icon: Icons.check_circle_outline,
                label: 'បញ្ជីវត្តមានទូទៅ',
                screen: AttendanceListViewScreen(),
              ),
              ListCardItem(
                icon: Icons.cancel_outlined,
                label: 'សូមដំណើរការអវត្តមាន',
                // screen: AbsentStudentsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
