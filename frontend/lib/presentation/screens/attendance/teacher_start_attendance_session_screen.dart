import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/service/auth_service.dart';
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
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoadingLocation = false;
  bool _locationFailed = false;
  Position? _currentLocation;

  int? _teacherId;
  int? _facultyId;
  int? _majorId;
  int? _scheduleId;

  @override
  void initState() {
    super.initState();
    _loadTeacherInfo();
    _getCurrentLocation();
  }

  /// Fetch the authenticated teacher's ID from the API instead of hardcoding.
  Future<void> _loadTeacherInfo() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;

    if (user == null) {
      _showError('Could not load teacher profile. Please log in again.');
      return;
    }
    if (user.teacherId == null) {
      _showError('Your account is not linked to a teacher profile.');
      return;
    }
    setState(() => _teacherId = user.teacherId);
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _locationFailed = false;
    });

    final hasPermission = await _locationService.requestLocationPermission();
    if (!mounted) return;

    if (!hasPermission) {
      setState(() {
        _isLoadingLocation = false;
        _locationFailed = true;
      });
      _showError('Location permission denied. Please enable it in settings.');
      return;
    }

    final position = await _locationService.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      _currentLocation = position;
      _isLoadingLocation = false;
      _locationFailed = position == null;
    });

    if (position == null) {
      _showError('Could not get location. Please tap "Retry Location".');
    }
  }

  Future<void> _startAttendanceSession() async {
    if (_currentLocation == null) {
      _showError('Location is not available. Please tap "Retry Location".');
      return;
    }

    if (_teacherId == null) {
      _showError('Teacher profile not loaded yet. Please wait or restart the app.');
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
      // Strip leading "Exception: " added by Dart so the message is clean
      final message = e.toString().replaceFirst('Exception: ', '');
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
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
            const SizedBox(height: 16),
            _buildTeacherInfoCard(),
            const SizedBox(height: 16),
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
              onPressed: (_isLoading || _isLoadingLocation || _teacherId == null)
                  ? null
                  : _startAttendanceSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
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

  Widget _buildTeacherInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _teacherId != null ? Icons.person : Icons.person_off,
              color: _teacherId != null ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 12),
            _teacherId != null
                ? Text(
                    'Teacher ID: $_teacherId',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )
                : const Text(
                    'Loading teacher profile...',
                    style: TextStyle(color: Colors.grey),
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
            if (_isLoadingLocation)
              const SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              )
            else
              Icon(
                _currentLocation != null ? Icons.location_on : Icons.location_off,
                size: 48,
                color: _currentLocation != null ? Colors.green : Colors.red,
              ),
            const SizedBox(height: 8),
            Text(
              _isLoadingLocation
                  ? 'កំពុងរកទីតាំង...'
                  : _currentLocation != null
                      ? 'ទីតាំង​បាន​ទទួល'
                      : 'មិនអាចទទួលទីតាំង',
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
            if (_locationFailed && !_isLoadingLocation) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Location'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
