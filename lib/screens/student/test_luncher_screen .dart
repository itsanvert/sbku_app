import 'package:flutter/material.dart';
import 'student_list_screen.dart';
import 'add_student_screen.dart';
import 'show_student_screen.dart';

class TestLauncherScreen extends StatelessWidget {
  const TestLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧪 Test Launcher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentListScreen()),
              ),
              child: const Text('Test Student List'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddStudentScreen()),
              ),
              child: const Text('Test Add Student'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShowStudentScreen(studentId: "SBKU0100196"),
                ),
              ),
              child: const Text('Test Show Student (Hardcoded ID)'),
            ),
          ],
        ),
      ),
    );
  }
}
