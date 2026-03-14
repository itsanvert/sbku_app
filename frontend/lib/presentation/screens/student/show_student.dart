import 'package:flutter/material.dart';
import 'package:sbku_app/model/student_model.dart';
import 'package:sbku_app/service/student_service.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';

class ShowStudentScreen extends StatelessWidget {
  final String studentId;
  const ShowStudentScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final StudentService service = StudentService();
    final int? id = int.tryParse(studentId);

    if (id == null) {
      return const Scaffold(body: Center(child: Text('Invalid Student ID')));
    }

    return Scaffold(
      appBar: AppBarWidget(
        title: "ព័ត៌មានសិស្ស",
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: FutureBuilder<Student>(
        future: service.getStudent(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error ?? "រកមិនឃើញសិស្ស"}'));
          }

          final student = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (student.avatarUrl != null && student.avatarUrl!.isNotEmpty)
                      ? NetworkImage(student.avatarUrl!)
                      : NetworkImage(
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(student.name)}&background=6366f1&color=ffffff&size=128&bold=true',
                        ),
                ),
                const SizedBox(height: 20),
                _row('ID', student.id.toString()),
                _row('Name', student.name),
                _row('Gender', student.gender ?? '—'),
                _row('Date of Birth', student.dob ?? '—'),
                _row('Faculty', student.faculty ?? '—'),
                _row('Major', student.major ?? '—'),
                _row('Shift', student.shift ?? '—'),
                _row('Generation', student.generation ?? '—'),
                _row('Year', student.year?.toString() ?? '—'),
                _row('Email', student.email ?? '—'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
            Expanded(flex: 2, child: Text(value, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
