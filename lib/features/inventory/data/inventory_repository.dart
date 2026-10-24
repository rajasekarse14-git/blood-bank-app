import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/config.dart';
import 'inventory_model.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory();
  Future<InventoryItem> getInventoryItem(String bloodGroup);
  Future<InventoryItem> updateInventory(String bloodGroup, int units);
  Future<SearchResult> searchBlood(String bloodGroup);
  Future<List<InventoryItem>> getCachedInventory();
}

class InventoryRepositoryImpl implements InventoryRepository {
  final Dio _dio;
  static const String cacheKey = 'cached_inventory_json';

  InventoryRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<InventoryItem>> getInventory() async {
    try {
      final response = await _dio.get(ApiConfig.inventory);
      final data = response.data as Map<String, dynamic>;
      final list = (data['inventory'] as List<dynamic>? ?? [])
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Cache locally for offline resilience
      _cacheInventoryLocally(list);

      return list;
    } on DioException catch (e) {
      // Offline fallback: try reading from cache
      final cached = await getCachedInventory();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      final cached = await getCachedInventory();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<InventoryItem> getInventoryItem(String bloodGroup) async {
    try {
      final encoded = Uri.encodeComponent(bloodGroup);
      final response = await _dio.get('${ApiConfig.inventory}/$encoded');
      return InventoryItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<InventoryItem> updateInventory(String bloodGroup, int units) async {
    try {
      final encoded = Uri.encodeComponent(bloodGroup);
      final response = await _dio.put(
        '${ApiConfig.inventory}/$encoded',
        data: {'units': units},
      );
      final data = response.data as Map<String, dynamic>;
      final invMap = data['inventory'] as Map<String, dynamic>;
      return InventoryItem.fromJson(invMap);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<SearchResult> searchBlood(String bloodGroup) async {
    try {
      // Must URL-encode "+" sign for query parameter
      final encoded = Uri.encodeComponent(bloodGroup);
      final response = await _dio.get('${ApiConfig.search}?blood_group=$encoded');
      return SearchResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<InventoryItem>> getCachedInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _cacheInventoryLocally(List<InventoryItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((e) => e.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(jsonList));
    } catch (_) {}
  }
}
