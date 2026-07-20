import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// NotificationModel represents a notification data structure
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.metadata,
    required this.createdAt,
  });
}

/// Enhanced notification service with better error handling and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<NotificationModel> _notificationHistory = [];
  static const int maxHistorySize = 50;

  // Callbacks
  Function(NotificationModel)? onNotificationReceived;
  Function(NotificationModel)? onNotificationTapped;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          if (details.payload != null) {
            print('Local notification tapped with payload: ${details.payload}');
          }
        },
      );

      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  /// Show generic notification snackbar
  void _showGenericNotification(
    BuildContext context,
    NotificationModel notification,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(notification.body),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }

  /// Add notification to history
  void _addToHistory(NotificationModel notification) {
    _notificationHistory.insert(0, notification);
    if (_notificationHistory.length > maxHistorySize) {
      _notificationHistory.removeAt(_notificationHistory.length - 1);
    }
  }

  /// Get notification history
  List<NotificationModel> getHistory() => List.from(_notificationHistory);

  /// Show local notification programmatically
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _notificationsPlugin.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notificationsPlugin.cancelAll();
  }

  /// Cleanup resources
  void dispose() {
    _notificationHistory.clear();
  }
}
