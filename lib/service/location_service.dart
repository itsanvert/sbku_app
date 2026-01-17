// Create this file: lib/service/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double ATTENDANCE_RADIUS = 10.0; // 10 meters

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
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
