import 'package:sbku_app/data/dummy_attendance_session.dart';
import 'package:sbku_app/model/attendance_session_model.dart';
import 'package:flutter/material.dart';
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
  late AttendanceSession _currentSession;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
  }

  void _endSession() {
    final index =
        attendanceSessions.indexWhere((s) => s.id == _currentSession.id);
    if (index != -1) {
      attendanceSessions[index] = _currentSession.copyWith(
        isActive: false,
        endTime: DateTime.now(),
      );

      // Generate AttendanceEntity records for all students in the class
      generateAttendanceFromSession(attendanceSessions[index]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'វេនបានបិទ។ បង្កើតកំណត់ត្រាវត្តមាន ${_currentSession.attendedStudentIds.length} នាក់'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Get updated session from list
    final sessionIndex =
        attendanceSessions.indexWhere((s) => s.id == _currentSession.id);
    if (sessionIndex != -1) {
      _currentSession = attendanceSessions[sessionIndex];
    }

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
                      'ចាប់ផ្តើម: ${_currentSession.startTime.hour}:${_currentSession.startTime.minute.toString().padLeft(2, '0')}',
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
              'សិស្សចូលរួម: ${_currentSession.attendedStudentIds.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _currentSession.attendedStudentIds.isEmpty
                  ? const Center(
                      child: Text('មិនទាន់មានសិស្សចុះវត្តមាន'),
                    )
                  : ListView.builder(
                      itemCount: _currentSession.attendedStudentIds.length,
                      itemBuilder: (context, index) {
                        final studentId =
                            _currentSession.attendedStudentIds[index];
                        final studentName = getStudentNameById(studentId);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Text(
                              studentName[0].toUpperCase(),
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                          title: Text(studentName),
                          subtitle: Text(studentId),
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
