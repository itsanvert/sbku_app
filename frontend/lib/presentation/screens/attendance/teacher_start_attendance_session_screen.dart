import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sbku_app/presentation/screens/attendance/teacher_active_session_monitor.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/shimmer_widget.dart';
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
  bool _isLoadingSchedules = false;
  bool _locationFailed = false;
  Position? _currentLocation;

  String? _teacherId;
  String? _facultyId;
  String? _majorId;

  // Schedule auto-detect fields
  List<Map<String, dynamic>> _schedules = [];
  Map<String, dynamic>? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    _loadTeacherInfo();
    _getCurrentLocation();
  }

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
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (_teacherId == null) return;
    setState(() => _isLoadingSchedules = true);

    try {
      final now = DateTime.now();
      final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final today = days[now.weekday % 7];

      final schedules = await _attendanceService.getTeacherSchedules(
        teacherId: _teacherId!,
        day: today,
      );

      if (!mounted) return;

      setState(() {
        _schedules = schedules;
        _isLoadingSchedules = false;
      });

      if (schedules.length == 1) {
        _selectSchedule(schedules.first);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSchedules = false);
      print('Failed to load schedules: $e');
    }
  }

  void _selectSchedule(Map<String, dynamic> schedule) {
    setState(() {
      _selectedSchedule = schedule;
      _facultyId = schedule['subject']?['faculty_id']?.toString();
      _majorId = schedule['subject']?['major_id']?.toString();
    });
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
      final now = DateTime.now();
      final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final today = days[now.weekday % 7];

      final result = await _attendanceService.startSession(
        teacherId: _teacherId!,
        facultyId: _facultyId,
        majorId: _majorId,
        scheduleId: _selectedSchedule?['id']?.toString(),
        subjectId: _selectedSchedule?['subject_id']?.toString(),
        academicClassId: _selectedSchedule?['class_id']?.toString(),
        dayOfWeek: today,
        startTime: _selectedSchedule?['start_time'],
        endTime: _selectedSchedule?['end_time'],
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
              sessionId: session['id'].toString(),
              qrToken: qrToken,
            ),
          ),
        );
      }
    } catch (e) {
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
            _buildScheduleCard(),
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
                  ? const ShimmerWidget(width: 24, height: 24, borderRadius: 12)
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

  Widget _buildScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'កាលវិភាគថ្ងៃនេះ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingSchedules)
              const Center(child: ShimmerWidget(width: 200, height: 20, borderRadius: 10))
            else if (_schedules.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'រកមិនឃើញកាលវិភាគសម្រាប់ថ្ងៃនេះ\nSession will notify all students.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange, fontSize: 13),
                ),
              )
            else if (_schedules.length == 1)
              _buildScheduleDetail(_schedules.first)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ជ្រើសរើសកាលវិភាគ:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ...(_selectedSchedule != null ? [_schedules.where((s) => s['id'] == _selectedSchedule!['id']).toList()] : [_schedules])
                      .expand((list) => list)
                      .map((schedule) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildScheduleOption(schedule),
                          )),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(Map<String, dynamic> schedule) {
    final isSelected = _selectedSchedule?['id'] == schedule['id'];
    final subjectName = schedule['subject']?['name'] ?? 'Unknown Subject';
    final className = schedule['academic_class']?['name'] ?? '';
    final timeRange = '${(schedule['start_time'] ?? '').toString().substring(0, 5)} - ${(schedule['end_time'] ?? '').toString().substring(0, 5)}';

    return GestureDetector(
      onTap: () => _selectSchedule(schedule),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (className.isNotEmpty)
                    Text(
                      'Class: $className',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  Text(
                    timeRange,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleDetail(Map<String, dynamic> schedule) {
    final subjectName = schedule['subject']?['name'] ?? 'Unknown Subject';
    final className = schedule['academic_class']?['name'] ?? '';
    final timeRange = '${(schedule['start_time'] ?? '').toString().substring(0, 5)} - ${(schedule['end_time'] ?? '').toString().substring(0, 5)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subjectName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          if (className.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.class_, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(className, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(timeRange, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ],
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
              const ShimmerWidget(width: 48, height: 48, borderRadius: 24)
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
