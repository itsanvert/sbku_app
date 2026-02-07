import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(title: 'ប្រវត្តិវត្តមាន'),
      body: const Center(child: Text('History screen - Coming soon')),
    );
  }
}

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(title: 'របាយការណ៍វត្តមាន'),
      body: const Center(child: Text('Report screen - Coming soon')),
    );
  }
}

class StudentAttendanceHistoryScreen extends StatelessWidget {
  const StudentAttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(title: 'ប្រវត្តិវត្តមានរបស់ខ្ញុំ'),
      body: const Center(child: Text('Student history - Coming soon')),
    );
  }
}
