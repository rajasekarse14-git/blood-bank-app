import 'package:dio/dio.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/config.dart';
import 'dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardStats();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<DashboardData> getDashboardStats() async {
    try {
      final response = await _dio.get(ApiConfig.dashboard);
      return DashboardData.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
