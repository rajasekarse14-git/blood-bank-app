import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_interceptor.dart';
import 'config.dart';

/// Centralized Dio HTTP client provider with interceptors and timeouts.
class ApiClient {
  late final Dio dio;
  final AuthInterceptor authInterceptor;

  ApiClient({
    FlutterSecureStorage? storage,
    void Function()? onSessionExpired,
  }) : authInterceptor = AuthInterceptor(
          storage: storage,
          onSessionExpired: onSessionExpired,
        ) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(authInterceptor);
  }

  /// Updates baseUrl dynamically if changed at runtime.
  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
    ApiConfig.baseUrl = newUrl;
  }
}
