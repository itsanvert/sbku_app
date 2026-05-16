# Flutter-Android Integration Enhancements

## Overview

This document describes the comprehensive enhancements made to ensure smooth integration between your Flutter app and Android native code.

## Key Enhancements

### 1. **Enhanced MainActivity.kt** (Android Native Integration)

**Location**: `android/app/src/main/kotlin/com/example/sbku_app/MainActivity.kt`

**Features**:

- Platform Channel communication with Flutter (Method Channel)
- Device information retrieval
- Native device properties access

**Available Methods**:

```kotlin
- getDeviceInfo()      // Get comprehensive device information
- getAndroidVersion()  // Get Android OS version
- getDeviceModel()     // Get device manufacturer and model
```

**Usage from Flutter**:

```dart
import 'package:sbku_app/service/platform_channel_service.dart';

final deviceInfo = await PlatformChannelService.getDeviceInfo();
final version = await PlatformChannelService.getAndroidVersion();
```

---

### 2. **Enhanced API Service** (`lib/service/api_service.dart`)

**Improvements**:

- ✅ Automatic retry logic with exponential backoff (max 3 attempts)
- ✅ Request timeout handling (30 seconds)
- ✅ Better error recovery for network failures
- ✅ User-Agent header for device identification
- ✅ PATCH request support
- ✅ Health check endpoint

**Configuration**:

```dart
static const int maxRetries = 3;
static const Duration requestTimeout = Duration(seconds: 30);
```

**New Methods**:

```dart
// Patch request
Future<http.Response> patch(String endpoint, Map<String, dynamic> body)

// Health check
Future<bool> healthCheck()
```

**Usage**:

```dart
final apiService = sl<ApiService>();

// Automatic retry on failure
final response = await apiService.get('users');

// Health check
bool isHealthy = await apiService.healthCheck();
```

---

### 3. **Platform Channel Service** (`lib/service/platform_channel_service.dart`)

**Purpose**: Enables communication between Flutter and native Android code

**Methods**:

```dart
// Get comprehensive device info
Map<String, dynamic> getDeviceInfo()

// Get Android OS version
String? getAndroidVersion()

// Get device model
String? getDeviceModel()

// Send debug info to native logging
Future<void> logDebugInfo(String tag, String message)
```

**Usage Example**:

```dart
import 'package:sbku_app/service/platform_channel_service.dart';

// Get device information
final deviceInfo = await PlatformChannelService.getDeviceInfo();
print('Device: ${deviceInfo['device']}');
print('Manufacturer: ${deviceInfo['manufacturer']}');
print('Model: ${deviceInfo['model']}');
print('Android Version: ${deviceInfo['androidVersion']}');

// Log to native side
await PlatformChannelService.logDebugInfo('MyTag', 'Debug message');
```

---

### 4. **Enhanced Notification Service** (`lib/service/notification_service_v2.dart`)

**Major Improvements**:

- ✅ Structured notification model
- ✅ Notification history tracking (last 50 notifications)
- ✅ Better error handling with fallbacks
- ✅ Callback system for notification events
- ✅ Improved Firestore real-time sync
- ✅ Separate handling for foreground/background
- ✅ Type-specific alert dialogs

**NotificationModel**:

```dart
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
}
```

**Supported Notification Types**:

- `attendance_session_started` - Shows attendance alert dialog
- `message` - Shows generic notification
- `default` - Generic snackbar notification

**Usage**:

```dart
// Initialize in main.dart (already done)
await notificationService.initialize(context);

// Set callbacks
notificationService.onNotificationReceived = (notification) {
  print('Received: ${notification.title}');
};

notificationService.onNotificationTapped = (notification) {
  print('Tapped: ${notification.title}');
  // Navigate based on notification type
};

// Show local notification
await notificationService.showLocalNotification(
  title: 'Hello',
  body: 'This is a test notification',
);

// Get notification history
List<NotificationModel> history = notificationService.getHistory();

// Clear all notifications
notificationService.clearAll();
```

---

### 5. **App Lifecycle Manager** (`lib/service/app_lifecycle_manager.dart`)

**Purpose**: Tracks app state changes and enables appropriate cleanup/resumption

**Lifecycle Events**:

```dart
enum AppLifecycleEvent {
  resumed,      // App came to foreground
  paused,       // App went to background
  detached,     // App is detached
  hidden,       // App is hidden (Android 11+)
  inactive,     // App is inactive
}
```

**Usage**:

```dart
final appLifecycleManager = AppLifecycleManager();

// Initialize
appLifecycleManager.initialize();

// Set callback
appLifecycleManager.onLifecycleChange = (event) {
  switch (event) {
    case AppLifecycleEvent.resumed:
      print('App resumed - sync data');
      break;
    case AppLifecycleEvent.paused:
      print('App paused - save state');
      break;
    case AppLifecycleEvent.hidden:
      print('App hidden');
      break;
    default:
      break;
  }
};

// Check if app is in background
bool inBackground = appLifecycleManager.isAppInBackground;

// Cleanup
appLifecycleManager.dispose();
```

---

### 6. **Enhanced main.dart**

**Improvements**:

- ✅ Better Firebase error handling
- ✅ App lifecycle management integrated
- ✅ Device info logging on startup
- ✅ Improved notification initialization
- ✅ Better routing and error handling
- ✅ State management for app lifecycle
- ✅ Graceful error recovery

**New Global Instances**:

```dart
final appLifecycleManager = AppLifecycleManager();
final notificationService = NotificationService();
```

---

## Integration Flow

```
Android Native Code (MainActivity.kt)
           ↕
Platform Channel Service
           ↕
Flutter App
     ↙      ↘
API Service    Notification Service
     ↓              ↓
Backend         Firebase/Firestore
```

---

## Usage Examples

### Example 1: Making an API Call with Retry

```dart
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/service/api_service.dart';

// Get the service from service locator
final apiService = sl<ApiService>();

try {
  // This will automatically retry up to 3 times
  final response = await apiService.get('users');

  if (response.statusCode == 200) {
    print('Success: ${response.body}');
  } else {
    print('Error: ${response.statusCode}');
  }
} catch (e) {
  print('Failed after retries: $e');
}
```

### Example 2: Handling Notifications

```dart
import 'package:sbku_app/service/notification_service_v2.dart';

// Setup callbacks when app starts
notificationService.onNotificationReceived = (notification) {
  print('New notification: ${notification.title}');

  // Handle based on type
  if (notification.type == 'attendance_session_started') {
    // Navigate to attendance screen
    Navigator.pushNamed(context, '/attendance');
  }
};

// Get notification history
final history = notificationService.getHistory();
for (var notification in history) {
  print('${notification.title}: ${notification.body}');
}
```

### Example 3: Getting Device Information

```dart
import 'package:sbku_app/service/platform_channel_service.dart';

// Get device info for debugging/analytics
final deviceInfo = await PlatformChannelService.getDeviceInfo();

// Send to backend for device registration
await apiService.post('device/register', {
  'device': deviceInfo['device'],
  'manufacturer': deviceInfo['manufacturer'],
  'model': deviceInfo['model'],
  'android_version': deviceInfo['androidVersion'],
});
```

### Example 4: App Lifecycle Management

```dart
import 'package:sbku_app/service/app_lifecycle_manager.dart';

// Setup in your main widget
appLifecycleManager.onLifecycleChange = (event) {
  if (event == AppLifecycleEvent.resumed) {
    // Refresh data when app comes to foreground
    Provider.of<AuthProvider>(context, listen: false).checkAuth();
  } else if (event == AppLifecycleEvent.paused) {
    // Save state when app goes to background
    saveAppState();
  }
};
```

---

## Testing the Integration

### 1. Test API Retry Logic

```bash
# Simulate network issues and verify retries work
# Watch logs for retry messages
```

### 2. Test Notifications

```dart
// In your app, trigger a test notification
await notificationService.showLocalNotification(
  title: 'Test',
  body: 'This is a test notification',
);
```

### 3. Test Platform Channels

```dart
// Get device info and print to verify communication
final info = await PlatformChannelService.getDeviceInfo();
print(info);
```

### 4. Test App Lifecycle

```dart
// Put app in background and foreground, check logs
// Should see lifecycle events logged
```

---

## Troubleshooting

### Issue: Platform Channel Not Working

**Solution**:

- Verify MainActivity.kt has correct package name
- Ensure channel name matches: `com.sbkuapp.sbku/native`
- Check that FlutterEngine is properly configured

### Issue: Notifications Not Showing

**Solution**:

- Verify Firebase is initialized
- Check notification permissions are granted
- Ensure Android notification channel is created
- Check FCM token is being updated

### Issue: API Retries Not Working

**Solution**:

- Check network connectivity
- Verify backend is responding with proper status codes
- Review logs for timeout messages
- Ensure timeout is reasonable for your network

### Issue: App Crashes on Startup

**Solution**:

- Check Firebase initialization errors
- Verify .env file is properly formatted
- Check for null pointer exceptions in lifecycle manager
- Review logcat for detailed errors

---

## Performance Considerations

1. **Notification History**: Limited to 50 notifications to prevent memory issues
2. **API Timeout**: 30 seconds should work for most networks; adjust if needed
3. **Platform Channel Calls**: Keep them lightweight; don't block main thread
4. **Firebase Initialization**: Can take 1-2 seconds; show splash screen during this

---

## Security Notes

1. ✅ Tokens stored in FlutterSecureStorage (encrypted)
2. ✅ Anonymous Firebase auth prevents read access issues
3. ✅ All API calls validated on backend
4. ✅ User-Agent header helps identify legitimate clients
5. ⚠️ Never log sensitive data (tokens, passwords)

---

## Next Steps

1. ✅ Test all features locally
2. ✅ Verify Firebase configuration on production
3. ✅ Monitor app crashes and API failures
4. ✅ Gather feedback from users
5. ✅ Optimize retry and timeout values based on real usage
6. ✅ Add analytics for notification interactions

---

## Support

For issues or questions about these enhancements:

1. Check the logs: `flutter logs`
2. Review the troubleshooting section above
3. Test individual components in isolation
4. Check Firebase Console for messaging issues
