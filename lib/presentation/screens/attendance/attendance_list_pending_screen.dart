import 'package:flutter/material.dart';

class AttendanceListPendingScreen extends StatelessWidget {
  const AttendanceListPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance List Pending'),
      ),
      body: const Center(
        child: Text('Attendance List Pending'),
      ),
    );
  }
}