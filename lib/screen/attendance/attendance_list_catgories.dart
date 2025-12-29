import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_attendance.dart';
import 'package:sbku_app/model/attendance.dart';
import 'package:sbku_app/screen/attendance/attendance_list_view_screen.dart';
import 'package:sbku_app/widget/appbar_widget.dart';
import 'package:sbku_app/widget/list_card_widget.dart';

class AttendanceListCategoryScreen extends StatelessWidget {
  const AttendanceListCategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីវត្តមាន',
        actions: [
          // IconButton(
          //   onPressed: () {
          //     // Share functionality
          //   },
          //   icon: const Icon(Icons.share, color: Colors.white),
          // ),
          // IconButton(
          //   onPressed: () {
          //     // Add functionality
          //   },
          //   icon: const Icon(Icons.add, color: Colors.white),
          // ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListCardList(
            items: [
              ListCardItem(
                icon: Icons.check_circle_outline,
                label: 'Present Students',
                screen: AttendanceItemWidget(
                  attendance: dummyAttendances[0],
                ),
              ),
              ListCardItem(
                icon: Icons.cancel_outlined,
                label: 'Absent Students',
                // screen: AbsentStudentsScreen(),
              ),
              ListCardItem(
                icon: Icons.hourglass_bottom_outlined,
                label: 'Late Students',
                // screen: LateStudentsScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
