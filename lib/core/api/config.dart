import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// API configuration for HemoLife 2.0 mobile application.
/// Configurable in one place. Defaults intelligently:
/// - Android Emulator: http://10.0.2.2:5000
/// - Web / Windows Desktop / Local testing: http://127.0.0.1:5000
/// - Physical LAN device: change to http://<YOUR_LAN_IP>:5000 (e.g. http://192.168.1.100:5000)
class ApiConfig {
  ApiConfig._();

  static String _resolveDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:5000';
  }

  /// Easily switchable backend baseUrl.
  static String baseUrl = _resolveDefaultBaseUrl();

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Endpoints
  static const String health = '/api/health';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String donors = '/api/donors';
  static const String requests = '/api/requests';
  static const String inventory = '/api/inventory';
  static const String search = '/api/search';
  static const String dashboard = '/api/dashboard/stats';
}
