import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static const double ATTENDANCE_RADIUS = 10.0; // 10 meters

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check if permission is already granted
    var status = await Permission.location.status;
    
    if (status.isDenied) {
      // Request permission
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      // Open app settings if user permanently denied
      await openAppSettings();
      return false;
    }

    return status.isGranted || status.isLimited;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // Fallback to last known position if current is unavailable/timed out
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  bool isWithinRange(
    Position studentPosition,
    Position teacherPosition,
  ) {
    final distance = calculateDistance(
      studentPosition.latitude,
      studentPosition.longitude,
      teacherPosition.latitude,
      teacherPosition.longitude,
    );
    return distance <= ATTENDANCE_RADIUS;
  }
}
