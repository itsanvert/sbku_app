import 'package:flutter/material.dart';
import 'package:sbku_app/widget/list_card_widget.dart';

class AttendanceListCategoryScreen extends StatelessWidget {
  const AttendanceListCategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text('Teacher Attendance Categories'),
          centerTitle: true,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListCardList(
            items: const [
              ListCardItem(
                icon: Icons.check_circle_outline,
                label: 'Present Students',
                // screen: PresentStudentsScreen(),
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
