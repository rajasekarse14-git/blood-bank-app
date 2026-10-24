import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/auth_interceptor.dart';
import '../../../core/api/config.dart';
import 'auth_model.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String username, String password);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getToken();
  Future<String?> getUsername();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl({
    required Dio dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio,
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);

      // Persist token and username
      await _storage.write(key: AuthInterceptor.tokenKey, value: authResponse.token);
      await _storage.write(key: AuthInterceptor.userKey, value: authResponse.username);

      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } catch (_) {
      // Even if network fails, ensure local storage is wiped
    } finally {
      await _storage.delete(key: AuthInterceptor.tokenKey);
      await _storage.delete(key: AuthInterceptor.userKey);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: AuthInterceptor.tokenKey);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AuthInterceptor.tokenKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getUsername() async {
    try {
      return await _storage.read(key: AuthInterceptor.userKey);
    } catch (_) {
      return null;
    }
  }
}
