import 'package:flutter/material.dart';
import 'package:sbku_app/model/attendance_session_model.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_list_pending_screen.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';

class TeacherActiveSessionScreen extends StatefulWidget {
  final AttendanceSession session;

  const TeacherActiveSessionScreen({super.key, required this.session});

  @override
  State<TeacherActiveSessionScreen> createState() =>
      _TeacherActiveSessionScreenState();
}

class _TeacherActiveSessionScreenState
    extends State<TeacherActiveSessionScreen> {
  late List<String> _attendedStudents = [];

  void _endSession() {
    final index = activeSessions.indexWhere((s) => s == widget.session);
    if (index != -1) {
      activeSessions[index] = widget.session.copyWith(
        isActive: false,
        endTime: DateTime.now(),
      );
    }

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'វេនវត្តមានកំពុងដំណើរការ'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    const Text(
                      'វេនវត្តមានកំពុងដំណើរការ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ចាប់ផ្តើម: ${widget.session.startTime.hour}:${widget.session.startTime.minute.toString().padLeft(2, '0')}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'រង្វង់ទីតាំង: 10 មេត្រ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'សិស្សចូលរួម: ${_attendedStudents.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _attendedStudents.isEmpty
                  ? const Center(
                      child: Text('មិនទាន់មានសិស្សចុះវត្តមាន'),
                    )
                  : ListView.builder(
                      itemCount: _attendedStudents.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(_attendedStudents[index]),
                          trailing:
                              const Icon(Icons.check, color: Colors.green),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: _endSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'បិទវេនវត្តមាន',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
