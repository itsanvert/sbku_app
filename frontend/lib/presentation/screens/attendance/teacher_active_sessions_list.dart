import 'package:sbku_app/data/dummy_class.dart';
import 'package:sbku_app/data/dummy_attendance_session.dart';
import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';

class TeacherActiveSessionsListScreen extends StatelessWidget {
  const TeacherActiveSessionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeSessions = attendanceSessions.where((s) => s.isActive).toList();

    return Scaffold(
      appBar: AppBarWidget.simple(title: 'វេនកំពុងដំណើរការ'),
      body: activeSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'មិនមានវេនកំពុងដំណើរការ',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: activeSessions.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final session = activeSessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.check_circle, color: Colors.green[700]),
                    ),
                    title: Text(
                      dummyClasses
                          .firstWhere((c) => c.id == session.classId)
                          .className,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'សិស្ស: ${session.attendedStudentIds.length} នាក់\n${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TeacherActiveSessionScreen(session: session),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
