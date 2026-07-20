import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sbku_app/service/api_service.dart';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/presentation/screens/attendance/qr_scan_attendance_screen.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('FCM Background message received: ${message.messageId}');
  print('  Title: ${message.notification?.title}');
  print('  Body: ${message.notification?.body}');
  print('  Data: ${message.data}');
}

/// Firebase Cloud Messaging service for push notifications.
///
/// Handles FCM token registration, foreground/background message display,
/// and notification tap navigation.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService _instance = FirebaseMessagingService._();
  factory FirebaseMessagingService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Global navigator key for navigating from outside the widget tree.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Track the notification that cold-started the app.
  RemoteMessage? _initialMessage;

  bool _isInitialized = false;
  String? _currentToken;

  /// Initialize Firebase Messaging, request permissions, set up handlers.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Request permission (iOS requires this; Android is auto-granted but
    // calling it is harmless).
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
      carPlay: false,
      announcement: false,
    );
    print('FCM Permission status: ${settings.authorizationStatus}');

    // Configure local notifications for foreground messages
    await _setupLocalNotifications();

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background/terminated tap (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for cold-start notification (app was terminated)
    _initialMessage = await _messaging.getInitialMessage();
    if (_initialMessage != null) {
      print('FCM Cold-start message: ${_initialMessage!.messageId}');
    }

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      _currentToken = newToken;
      _registerTokenWithBackend(newToken);
    });

    // Get current token
    final token = await _messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      _currentToken = token;
    }

    // Subscribe to the 'all' topic as a fallback
    await _messaging.subscribeToTopic('all');
    print('FCM subscribed to topic: all');
  }

  /// Set up the local notifications plugin for showing foreground messages.
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Ensure the Android notification channel exists
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle messages received while the app is in the foreground.
  void _onForegroundMessage(RemoteMessage message) {
    print('FCM Foreground message: ${message.notification?.title}');
    final notification = message.notification;
    if (notification == null) return;

    // Show a local notification so the user sees it
    _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification taps (background/terminated).
  void _onMessageOpenedApp(RemoteMessage message) {
    print('FCM onMessageOpenedApp: ${message.data}');
    _handleNotificationTap(message.data);
  }

  /// Handle taps on local notifications shown by the plugin.
  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleNotificationTap(data);
    } catch (e) {
      print('Error parsing local notification payload: $e');
    }
  }

  /// Navigate based on notification data payload.
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final sessionId = data['session_id'] as String?;
    final qrToken = data['qr_token'] as String?;

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('Navigator context unavailable, cannot navigate from notification');
      return;
    }

    switch (type) {
      case 'attendance_session_started':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QrScanAttendanceScreen(
              sessionId: sessionId,
              qrToken: qrToken,
            ),
          ),
        );
        break;
      case 'attendance_session_ended':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QrScanAttendanceScreen(
              sessionId: sessionId,
            ),
          ),
        );
        break;
      default:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
    }
  }

  /// Register the FCM token with the backend.
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final apiService = sl<ApiService>();
      final response = await apiService.post(
        'user/fcm-token',
        {'token': token},
        requiresAuth: true,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('FCM token registered with backend successfully');
      } else {
        print('FCM token registration failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Failed to register FCM token with backend: $e');
    }
  }

  /// Public method to register the current token with the backend.
  /// Called after login or when the token is refreshed.
  Future<void> registerToken() async {
    final token = _currentToken ?? await _messaging.getToken();
    if (token != null) {
      _currentToken = token;
      await _registerTokenWithBackend(token);
    }
  }

  /// Get the current FCM token.
  Future<String?> getToken() async {
    return _currentToken ?? await _messaging.getToken();
  }

  /// Handle cold-start notification (app opened from terminated state).
  /// Call this after the app's first frame is rendered.
  void handleColdStartNotification() {
    if (_initialMessage != null) {
      final msg = _initialMessage!;
      _initialMessage = null;
      _handleNotificationTap(msg.data);
    }
  }
}
