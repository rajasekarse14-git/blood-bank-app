import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor that attaches JWT Bearer token and triggers session logout on 401.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final void Function()? onSessionExpired;

  static const String tokenKey = 'hemolife_auth_token';
  static const String userKey = 'hemolife_auth_user';

  AuthInterceptor({
    FlutterSecureStorage? storage,
    this.onSessionExpired,
  }) : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.read(key: tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Secure storage read error fallback
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        await _storage.delete(key: tokenKey);
        await _storage.delete(key: userKey);
      } catch (_) {}

      // Trigger automatic logout redirect
      onSessionExpired?.call();
    }
    return handler.next(err);
  }
}
