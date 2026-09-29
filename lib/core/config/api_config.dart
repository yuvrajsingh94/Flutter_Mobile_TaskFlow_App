import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const int defaultPort = 5000;
  static const String defaultLanIp = '172.16.2.15';
  static const String _customUrlStorageKey = 'taskflow_custom_api_url';

  static String? _customApiBaseUrl;

  /// Returns the active API Base URL.
  static String get baseUrl {
    if (kReleaseMode) {
      const definedUrl = String.fromEnvironment('API_URL');
      if (definedUrl.isNotEmpty) {
        return _cleanUrl(definedUrl);
      }
      return defaultBaseUrl;
    }
    if (_customApiBaseUrl != null && _customApiBaseUrl!.trim().isNotEmpty) {
      return _cleanUrl(_customApiBaseUrl!);
    }
    return defaultBaseUrl;
  }

  /// Evaluates platform-appropriate default base URL:
  /// - Android Emulator: 10.0.2.2:5000/api
  /// - iOS Simulator: 127.0.0.1:5000/api
  /// - Physical devices & default: 172.16.2.15:5000/api
  static String get defaultBaseUrl {
    if (kIsWeb) {
      if (Uri.base.host.contains('trycloudflare.com')) {
        return 'https://bizrate-nikon-stakeholders-training.trycloudflare.com/api';
      }
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:$defaultPort/api';
    }

    try {
      if (Platform.isAndroid) {
        // By default use LAN IP so physical devices and emulators on LAN work seamlessly
        return 'http://$defaultLanIp:$defaultPort/api';
      } else if (Platform.isIOS) {
        return 'http://$defaultLanIp:$defaultPort/api';
      }
    } catch (_) {
      // Fallback
    }

    return 'http://$defaultLanIp:$defaultPort/api';
  }

  /// Clean trailing slashes
  static String _cleanUrl(String url) {
    var cleaned = url.trim();
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }

  /// Initialize custom URL from persistent storage (development only)
  static Future<void> init() async {
    if (kReleaseMode) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _customApiBaseUrl = prefs.getString(_customUrlStorageKey);
    } catch (_) {}
  }

  /// Set and persist custom API URL override (development only)
  static Future<void> setCustomBaseUrl(String url) async {
    if (kReleaseMode) return;
    final cleaned = _cleanUrl(url);
    _customApiBaseUrl = cleaned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customUrlStorageKey, cleaned);
  }

  /// Reset to factory default URL
  static Future<void> resetToDefault() async {
    _customApiBaseUrl = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customUrlStorageKey);
  }
}
