import 'package:dio/dio.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/config.dart';
import 'blood_request_model.dart';

abstract class BloodRequestRepository {
  Future<BloodRequestListResponse> getRequests({int page = 1, int limit = 20});
  Future<Map<String, dynamic>> createRequest({
    required String patientName,
    required String bloodGroup,
    required int quantity,
    required String hospital,
    required String contact,
    String? notes,
  });
  Future<BloodRequest> getRequest(int id);
  Future<BloodRequest> updateRequestStatus(int id, String status);
  Future<void> deleteRequest(int id);
}

class BloodRequestRepositoryImpl implements BloodRequestRepository {
  final Dio _dio;

  BloodRequestRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<BloodRequestListResponse> getRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.requests,
        queryParameters: {'page': page, 'limit': limit},
      );
      return BloodRequestListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createRequest({
    required String patientName,
    required String bloodGroup,
    required int quantity,
    required String hospital,
    required String contact,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.requests,
        data: {
          'patient_name': patientName,
          'blood_group': bloodGroup,
          'quantity': quantity,
          'hospital': hospital,
          'contact': contact,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final refId = data['reference_id'] as String? ?? '';
      final reqMap = data['request'] as Map<String, dynamic>? ?? {};
      final request = BloodRequest.fromJson(reqMap);

      return {
        'reference_id': refId,
        'request': request,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<BloodRequest> getRequest(int id) async {
    try {
      final response = await _dio.get('${ApiConfig.requests}/$id');
      return BloodRequest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<BloodRequest> updateRequestStatus(int id, String status) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.requests}/$id/status',
        data: {'status': status},
      );
      final data = response.data as Map<String, dynamic>;
      final reqMap = data['request'] as Map<String, dynamic>;
      return BloodRequest.fromJson(reqMap);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteRequest(int id) async {
    try {
      await _dio.delete('${ApiConfig.requests}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
