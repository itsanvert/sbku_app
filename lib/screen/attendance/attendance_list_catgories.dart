import 'package:flutter/material.dart';
import 'package:sbku_app/widget/attendance/card_widget.dart';
import 'package:sbku_app/widget/attendance/header_widget.dart';

class AttendanceListCategoryScreen extends StatelessWidget {
  const AttendanceListCategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: HeaderWidget(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AttendanceCardWidget(),
        ),
      ),
    );
  }
}
