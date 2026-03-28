import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/service/location_service.dart';

class TeacherStartAttendanceScreen extends StatefulWidget {
  const TeacherStartAttendanceScreen({super.key});

  @override
  State<TeacherStartAttendanceScreen> createState() =>
      _TeacherStartAttendanceScreenState();
}

class _TeacherStartAttendanceScreenState
    extends State<TeacherStartAttendanceScreen> {
  final LocationService _locationService = LocationService();
  final AttendanceService _attendanceService = AttendanceService();

  bool _isLoading = false;
  Position? _currentLocation;

  // These IDs will come from the teacher's profile or selection
  int? _teacherId;
  int? _facultyId;
  int? _majorId;
  int? _scheduleId;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // TODO: Get teacher info from auth provider
    _teacherId = 1; // placeholder
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

    if (_teacherId == null) {
      _showError('Teacher ID not found');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _attendanceService.startSession(
        teacherId: _teacherId!,
        facultyId: _facultyId,
        majorId: _majorId,
        scheduleId: _scheduleId,
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );

      final session = result['session'];
      final qrToken = result['qr_token'];

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherActiveSessionScreen(
              sessionId: session['id'],
              qrToken: qrToken,
            ),
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
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ការបើកវេនវត្តមាន',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ពេលបើកវេន សិស្សអាចស្កេន QR កូដដើម្បីចុះវត្តមាន។',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.qr_code, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        const Text('QR កូដនឹងត្រូវបង្កើតដោយស្វ័យប្រវត្តិ'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        const Text('ទីតាំងនឹងត្រូវកត់ត្រា'),
                      ],
                    ),
                  ],
                ),
              ),
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
}
