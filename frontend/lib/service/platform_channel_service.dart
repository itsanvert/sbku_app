import 'package:flutter/services.dart';

/// Service for communicating with native Android code via Platform Channels.
/// 
/// This allows Flutter to call native Android methods and retrieve device information.
class PlatformChannelService {
  static const platform = MethodChannel('com.sbkuapp.sbku/native');

  /// Get comprehensive device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> result = 
          await platform.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting device info: $e');
      return {};
    }
  }

  /// Get Android OS version
  static Future<String?> getAndroidVersion() async {
    try {
      final String version = 
          await platform.invokeMethod('getAndroidVersion');
      return version;
    } catch (e) {
      print('Error getting Android version: $e');
      return null;
    }
  }

  /// Get device model name
  static Future<String?> getDeviceModel() async {
    try {
      final String model = 
          await platform.invokeMethod('getDeviceModel');
      return model;
    } catch (e) {
      print('Error getting device model: $e');
      return null;
    }
  }

  /// Send debug info to native logging
  static Future<void> logDebugInfo(String tag, String message) async {
    try {
      await platform.invokeMethod('logDebugInfo', {
        'tag': tag,
        'message': message,
      });
    } catch (e) {
      print('Error logging to native: $e');
    }
  }
}
