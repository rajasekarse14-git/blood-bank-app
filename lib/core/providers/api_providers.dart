import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/inventory/data/inventory_repository.dart';
import '../../features/donors/data/donor_repository.dart';
import '../../features/requests/data/blood_request_repository.dart';
import '../../features/dashboard/data/dashboard_repository.dart';

/// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Shared session expiration notifier
class SessionExpiredNotifier extends StateNotifier<bool> {
  SessionExpiredNotifier() : super(false);
  void trigger() => state = true;
  void reset() => state = false;
}

final sessionExpiredProvider =
    StateNotifierProvider<SessionExpiredNotifier, bool>((ref) {
  return SessionExpiredNotifier();
});

/// ApiClient provider with dynamic session expiry trigger
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(
    storage: storage,
    onSessionExpired: () {
      ref.read(sessionExpiredProvider.notifier).trigger();
    },
  );
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(apiClientProvider).dio;
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dio: ref.watch(dioProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(dio: ref.watch(dioProvider));
});

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  return DonorRepositoryImpl(dio: ref.watch(dioProvider));
});

final bloodRequestRepositoryProvider = Provider<BloodRequestRepository>((ref) {
  return BloodRequestRepositoryImpl(dio: ref.watch(dioProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(dio: ref.watch(dioProvider));
});

// Connectivity Provider
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield !initial.contains(ConnectivityResult.none);

  await for (final results in connectivity.onConnectivityChanged) {
    yield !results.contains(ConnectivityResult.none);
  }
});
