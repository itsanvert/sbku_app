import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sbku_app/model/attendance_session_model.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_list_pending_screen.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/service/location_service.dart';
class StudentAttendanceCheckInScreen extends StatefulWidget {
  const StudentAttendanceCheckInScreen({super.key});

  @override
  State<StudentAttendanceCheckInScreen> createState() =>
      _StudentAttendanceCheckInScreenState();
}

class _StudentAttendanceCheckInScreenState
    extends State<StudentAttendanceCheckInScreen> {
  final LocationService _locationService = LocationService();

  bool _isLoading = false;
  Position? _studentLocation;
  AttendanceSession? _nearbySession;

  @override
  void initState() {
    super.initState();
    _checkNearbySession();
  }

  Future<void> _checkNearbySession() async {
    setState(() => _isLoading = true);

    final hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
      _showError('សូមអនុញ្ញាតប្រើទីតាំង');
      setState(() => _isLoading = false);
      return;
    }

    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      _showError('មិនអាចរកឃើញទីតាំង');
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _studentLocation = position);

    // Find nearby active session
    AttendanceSession? foundSession;
    for (var session in activeSessions) {
      if (!session.isActive) continue;

      final teacherPosition = Position(
        latitude: session.latitude,
        longitude: session.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      if (_locationService.isWithinRange(position, teacherPosition)) {
        foundSession = session;
        break;
      }
    }

    setState(() {
      _nearbySession = foundSession;
      _isLoading = false;
    });
  }

  Future<void> _checkInAttendance() async {
    if (_nearbySession == null || _studentLocation == null) return;

    setState(() => _isLoading = true);

    // Simulate check-in
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ចុះវត្តមានជោគជ័យ!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
      appBar: AppBarWidget(title: 'ចុះវត្តមាន'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: _nearbySession == null
                  ? _buildNoSessionFound()
                  : _buildSessionFound(),
            ),
    );
  }

  Widget _buildNoSessionFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'រកមិនឃើញវេនវត្តមាន',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'សូមធ្វើឱ្យប្រាកដថាអ្នកស្ថិតនៅក្បែរគ្រូ',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _checkNearbySession,
            icon: const Icon(Icons.refresh),
            label: const Text('ស្វែងរកម្តងទៀត'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionFound() {
    final distance = _locationService.calculateDistance(
      _studentLocation!.latitude,
      _studentLocation!.longitude,
      _nearbySession!.latitude,
      _nearbySession!.longitude,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.green[400],
        ),
        const SizedBox(height: 16),
        const Text(
          'រកឃើញវេនវត្តមាន!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('មហាវិទ្យាល័យ', _nearbySession!.facultyId),
                _buildInfoRow('ថ្នាក់', _nearbySession!.classId),
                _buildInfoRow('វេន', _nearbySession!.shiftId),
                _buildInfoRow('ចម្ងាយ', '${distance.toStringAsFixed(1)}m'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _checkInAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
          ),
          child: const Text(
            'ចុះវត្តមាន',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
