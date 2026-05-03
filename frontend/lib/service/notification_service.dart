import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sbku_app/presentation/screens/attendance/qr_scan_attendance_screen.dart';

/// A service that listens for attendance session notifications
/// and shows a rich alert dialog to students.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize foreground notification listeners.
  void initialize(BuildContext context) {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print('Notification tapped: ${details.payload}');
      },
    );

    // Listen for foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (context.mounted) {
        _handleMessage(context, message);
      }
    });

    // Listen for when user taps on a notification (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (context.mounted) {
        _handleMessage(context, message);
      }
    });

    // Listen to Firestore messages collection for real-time alerts
    _listenToFirestoreMessages(context);
  }

  void _handleMessage(BuildContext context, RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? '';

    if (type == 'attendance_session_started') {
      if (context.mounted) {
        _showAttendanceAlert(context, data);
      }
    } else {
      // Generic notification
      if (message.notification != null) {
        if (context.mounted) {
          _showGenericNotification(
            context,
            message.notification!.title ?? 'Notification',
            message.notification!.body ?? '',
          );
        }
      }
    }
  }

  void _listenToFirestoreMessages(BuildContext context) {
    FirebaseFirestore.instance
        .collection('messages')
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (!context.mounted) return;
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            // Check if this notification is very recent (within last 10 seconds)
            // to avoid showing old alerts on app start
            final createdAt = data['created_at'];
            if (createdAt != null) {
              final createdTime = DateTime.tryParse(createdAt.toString());
              if (createdTime != null &&
                  DateTime.now().difference(createdTime).inSeconds < 10) {
                
                final metadata = data['metadata'];
                final title = data['title'] ?? 'New Message';
                final body = data['body'] ?? '';

                if (metadata != null && metadata['type'] == 'attendance_session_started') {
                  if (context.mounted) {
                    _showAttendanceAlert(context, Map<String, dynamic>.from(metadata));
                  }
                } else {
                  // Show a SnackBar for other new messages
                  if (context.mounted) {
                    _showGenericNotification(context, title, body);
                  }
                }
              }
            }
          }
        }
      }
    });
  }

  /// Show a rich attendance session alert dialog
  void _showAttendanceAlert(BuildContext context, Map<String, dynamic> data) {
    final teacherName = data['teacher_name'] ?? 'Teacher';
    final subjectName = data['subject_name'] ?? 'Class';
    final majorName = data['major_name'] ?? '';
    final className = data['class_name'] ?? '';
    final shiftName = data['shift_name'] ?? '';
    final timeSlot = data['time_slot'] ?? '';
    final dayOfWeek = data['day_of_week'] ?? '';
    final sessionId = data['session_id'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header gradient ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4F46E5),
                      const Color(0xFF7C3AED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Attendance Check-in Open!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$teacherName has started a session',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Session details ──
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detailRow(Icons.book, 'Subject', subjectName),
                    if (className.isNotEmpty)
                      _detailRow(Icons.class_, 'Class', className),
                    if (majorName.isNotEmpty)
                      _detailRow(Icons.school, 'Major', majorName),
                    if (shiftName.isNotEmpty)
                      _detailRow(Icons.schedule, 'Shift', shiftName),
                    if (dayOfWeek.isNotEmpty)
                      _detailRow(Icons.calendar_today, 'Day',
                          dayOfWeek[0].toUpperCase() + dayOfWeek.substring(1)),
                    if (timeSlot.isNotEmpty)
                      _detailRow(Icons.access_time, 'Time', timeSlot),

                    const SizedBox(height: 8),

                    // Urgency indicator
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFBBF24)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please check in now using the QR scanner!',
                              style: TextStyle(
                                color: const Color(0xFF92400E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Dismiss',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              // Navigate to QR scanner
                              if (sessionId.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const QrScanAttendanceScreen(),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.qr_code_scanner, size: 20),
                            label: const Text(
                              'Scan QR Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showGenericNotification(
      BuildContext context, String title, String body) {
    // 1. Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (body.isNotEmpty) Text(body, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
      ),
    );

    // 2. Also show a system notification (important for foreground visibility)
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    _notificationsPlugin.show(
      id: DateTime.now().millisecond % 100000,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
