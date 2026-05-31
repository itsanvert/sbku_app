import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration for API and asset URLs.
class AppConfig {
  AppConfig._();

  /// Local Laragon fallback (used if .env is missing).
  static const String localApiHost = 'http://192.168.1.101:8000';

  static String get apiHost {
    final fromEnv = dotenv.env['API_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv.replaceAll(RegExp(r'/+$'), '');
    }
    return localApiHost;
  }

  static String get apiBaseUrl => '$apiHost/api';

  static String storageUrl(String path) {
    final normalized = path.replaceFirst(RegExp(r'^/+'), '');
    return '$apiHost/api/storage/$normalized';
  }

  /// Turns a storage path or full URL into a loadable image URL for the device.
  static String? resolveMediaUrl(String? urlOrPath) {
    if (urlOrPath == null || urlOrPath.isEmpty) return null;

    if (urlOrPath.contains('ui-avatars.com') ||
        urlOrPath.contains('googleusercontent.com')) {
      return urlOrPath;
    }

    if (urlOrPath.startsWith('http')) {
      return _rewriteLoopback(urlOrPath);
    }

    return storageUrl(urlOrPath);
  }

  static String _rewriteLoopback(String url) {
    final loopback =
        RegExp(r'https?://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?');
    if (loopback.hasMatch(url)) {
      return url.replaceFirst(loopback, apiHost);
    }
    return url;
  }
}
