import 'package:dio/dio.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/config.dart';
import 'donor_model.dart';

abstract class DonorRepository {
  Future<DonorListResponse> getDonors({
    String? bloodGroup,
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<Donor> registerDonor({
    required String name,
    required int age,
    required String gender,
    required String bloodGroup,
    required String phone,
    required String address,
  });
  Future<Donor> getDonor(int id);
  Future<Donor> updateDonor(int id, Map<String, dynamic> data);
  Future<void> deactivateDonor(int id);
}

class DonorRepositoryImpl implements DonorRepository {
  final Dio _dio;

  DonorRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<DonorListResponse> getDonors({
    String? bloodGroup,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        queryParams['blood_group'] = bloodGroup;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        ApiConfig.donors,
        queryParameters: queryParams,
      );

      return DonorListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<Donor> registerDonor({
    required String name,
    required int age,
    required String gender,
    required String bloodGroup,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.donors,
        data: {
          'name': name,
          'age': age,
          'gender': gender,
          'blood_group': bloodGroup,
          'phone': phone,
          'address': address,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final donorMap = data['donor'] as Map<String, dynamic>;
      return Donor.fromJson(donorMap);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Donor> getDonor(int id) async {
    try {
      final response = await _dio.get('${ApiConfig.donors}/$id');
      return Donor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Donor> updateDonor(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConfig.donors}/$id', data: data);
      final resData = response.data as Map<String, dynamic>;
      final donorMap = resData['donor'] as Map<String, dynamic>;
      return Donor.fromJson(donorMap);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deactivateDonor(int id) async {
    try {
      await _dio.delete('${ApiConfig.donors}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
