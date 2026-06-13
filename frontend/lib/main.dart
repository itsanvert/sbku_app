import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/core/constants/app_config.dart';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/presentation/screens/home/home_screen.dart';
import 'package:sbku_app/presentation/screens/welcome/login_screen.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/providers/theme_provider.dart';
import 'package:sbku_app/presentation/screens/welcome/splash_screen.dart';
import 'package:sbku_app/service/notification_service_v2.dart';
import 'package:sbku_app/service/app_lifecycle_manager.dart';
import 'package:sbku_app/service/platform_channel_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global app lifecycle manager
final appLifecycleManager = AppLifecycleManager();
final notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Create Android Notification Channel
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('Notifications initialized successfully');
  } catch (e) {
    print('Notification initialization error: $e');
  }

  // Lock to portrait for a consistent login experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light, // iOS
  ));

  try {
    await dotenv.load(fileName: '.env');
    print('✓ .env loaded successfully');
  } catch (e) {
    print('✗ Failed to load .env: $e');
    try {
      await dotenv.load(fileName: '.env.example');
      print('✓ .env.example loaded as fallback');
    } catch (e2) {
      print('✗ Failed to load .env.example: $e2');
      print('⚠ Using hardcoded fallback: ${AppConfig.localApiHost}');
    }
  }

  // Debug: show which API URL is actually being resolved
  print('🔧 Resolved API URL: ${AppConfig.apiBaseUrl}');
  print('🔧 Resolved API Host: ${AppConfig.apiHost}');

  setupServiceLocator();

  // Get device info
  _logDeviceInfo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Log device information for debugging
Future<void> _logDeviceInfo() async {
  try {
    final deviceInfo = await PlatformChannelService.getDeviceInfo();
    print('=== Device Info ===');
    print('Device: ${deviceInfo['device']}');
    print('Manufacturer: ${deviceInfo['manufacturer']}');
    print('Model: ${deviceInfo['model']}');
    print('Android Version: ${deviceInfo['androidVersion']}');
    print('===================');
  } catch (e) {
    print('Error getting device info: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize app lifecycle manager
    appLifecycleManager.initialize();
    appLifecycleManager.onLifecycleChange = _handleLifecycleChange;
  }

  @override
  void dispose() {
    appLifecycleManager.dispose();
    notificationService.dispose();
    super.dispose();
  }

  void _handleLifecycleChange(AppLifecycleEvent event) {
    print('Lifecycle event: $event');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SBKU App',
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      scrollBehavior: const _AppScrollBehavior(),
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePageScreen(),
      },
    );
  }
}

/// Custom scroll behavior: bouncing physics on Android too, no glow overscroll.
class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child; // removes the default Android glow overscroll
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isChecking = true;
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize notifications once we have a valid context
    if (!_notificationsInitialized) {
      _notificationsInitialized = true;
      notificationService.initialize(context);
    }
  }

  Future<void> _checkAuth() async {
    final startTime = DateTime.now();

    // Check auth status (makes /api/user API call if token is saved)
    await Provider.of<AuthProvider>(context, listen: false).checkAuth();

    // Enforce a minimum splash duration of 1.5s so transition is smooth
    // and the background warm-up gets a head start if no token is saved
    final elapsed = DateTime.now().difference(startTime);
    const minSplashDuration = Duration(milliseconds: 1500);
    if (elapsed < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsed);
    }

    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _warmUpServer() async {
    try {
      final apiService = sl<ApiService>();
      await apiService.healthCheck();
      print('Render API Warm-up: Server is warm and ready!');
    } catch (e) {
      print('Render API Warm-up failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const HomePageScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
