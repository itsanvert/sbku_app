import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sbku_app/data/dummy_faculty.dart';
import 'package:sbku_app/data/dummy_major.dart';
import 'package:sbku_app/data/dummy_class.dart';
import 'package:sbku_app/data/dummy_year.dart';
import 'package:sbku_app/data/dummy_shirt.dart';
import 'package:sbku_app/model/attendance_session_model.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/location_service.dart';

// Store active sessions (in real app, use state management)
List<AttendanceSession> activeSessions = [];

class TeacherStartAttendanceScreen extends StatefulWidget {
  const TeacherStartAttendanceScreen({super.key});

  @override
  State<TeacherStartAttendanceScreen> createState() =>
      _TeacherStartAttendanceScreenState();
}

class _TeacherStartAttendanceScreenState
    extends State<TeacherStartAttendanceScreen> {
  final LocationService _locationService = LocationService();

  String _facultyId = 'F01';
  String _majorId = 'M01';
  String _classId = 'C01';
  String _yearId = 'Y1';
  String _id = 'SH1';

  bool _isLoading = false;
  Position? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
      _showError('Location permission denied');
      return;
    }

    final position = await _locationService.getCurrentLocation();
    setState(() {
      _currentLocation = position;
    });
  }

  Future<void> _startAttendanceSession() async {
    if (_currentLocation == null) {
      _showError('Unable to get location. Please try again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = AttendanceSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teacherId: 'TEACHER_001', // Get from auth
        facultyId: _facultyId,
        majorId: _majorId,

        classId: _classId,
        yearId: _yearId,
        shiftId: _id,
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        startTime: DateTime.now(),
      );

      activeSessions.add(session);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherActiveSessionScreen(session: session),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to start session: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'បើកវេនវត្តមាន'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLocationCard(),
            const SizedBox(height: 24),
            _buildDropdown(
              label: 'មហាវិទ្យាល័យ',
              value: _facultyId,
              items: dummyFaculties
                  .map((f) =>
                      DropdownMenuItem(value: f.id, child: Text(f.facultyName)))
                  .toList(),
              onChanged: (v) => setState(() => _facultyId = v!),
            ),
            _buildDropdown(
              label: 'ឯកទេស',
              value: _majorId,
              items: dummyMajors
                  .map((m) => DropdownMenuItem(
                      value: m.id, child: Text(m.majorName)))
                  .toList(),
              onChanged: (v) => setState(() => _majorId = v!),
            ),
            _buildDropdown(
              label: 'ថ្នាក់',
              value: _classId,
              items: dummyClasses
                  .map((c) => DropdownMenuItem(
                      value: c.id, child: Text(c.className)))
                  .toList(),
              onChanged: (v) => setState(() => _classId = v!),
            ),
            _buildDropdown(
              label: 'ឆ្នាំទី',
              value: _yearId,
              items: dummyYears
                  .map((y) => DropdownMenuItem(
                      value: y.id, child: Text(y.yearName)))
                  .toList(),
              onChanged: (v) => setState(() => _yearId = v!),
            ),
            _buildDropdown(
              label: 'វេន',
              value: _id,
              items: dummyShifts
                  .map((s) => DropdownMenuItem(
                      value: s.id, child: Text(s.shiftName)))
                  .toList(),
              onChanged: (v) => setState(() => _id = v!),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _startAttendanceSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'បើកវេនវត្តមាន',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _currentLocation != null ? Icons.location_on : Icons.location_off,
              size: 48,
              color: _currentLocation != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              _currentLocation != null ? 'ទីតាំង​បាន​ទទួល' : 'កំពុងរកទីតាំង...',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_currentLocation != null) ...[
              const SizedBox(height: 4),
              Text(
                'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Long: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
