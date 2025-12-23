import 'package:flutter/material.dart';

import '../../data/dummy_students.dart';

class ShowStudentScreen extends StatelessWidget {
  final String studentId;
  const ShowStudentScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final student = dummyStudents.firstWhere((s) => s.id == studentId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Student Details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
            const SizedBox(height: 20),
            _row('Student ID', student.id),
            _row('Name', student.name),
            _row('Gender', student.gender == 'M' ? 'Male' : 'Female'),
            _row('Faculty', student.faculty),
            _row('Major', student.major),
            _row('Shift', student.shift),
            _row('Generation', student.generation),
            _row('Year', student.year),
            _row('Email', student.email),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 2, child: Text(value)),
        ],
      ),
    );
  }
}
