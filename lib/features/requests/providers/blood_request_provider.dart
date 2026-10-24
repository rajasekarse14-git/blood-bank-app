import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/providers/api_providers.dart';
import '../data/blood_request_model.dart';
import '../data/blood_request_repository.dart';

class BloodRequestListState {
  final List<BloodRequest> allRequests;
  final bool isLoading;
  final String? errorMessage;
  final String statusFilter; // 'all', 'pending', 'processing', 'fulfilled', 'cancelled'
  final String searchQuery;

  const BloodRequestListState({
    this.allRequests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter = 'all',
    this.searchQuery = '',
  });

  List<BloodRequest> get filteredRequests {
    return allRequests.where((req) {
      final matchesStatus =
          statusFilter == 'all' || req.status.toLowerCase() == statusFilter.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          req.patientName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          req.hospital.toLowerCase().contains(searchQuery.toLowerCase()) ||
          req.referenceId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          req.bloodGroup.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  BloodRequestListState copyWith({
    List<BloodRequest>? allRequests,
    bool? isLoading,
    String? errorMessage,
    String? statusFilter,
    String? searchQuery,
  }) {
    return BloodRequestListState(
      allRequests: allRequests ?? this.allRequests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class BloodRequestListNotifier extends StateNotifier<BloodRequestListState> {
  final BloodRequestRepository _repo;

  BloodRequestListNotifier(this._repo) : super(const BloodRequestListState()) {
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repo.getRequests(page: 1, limit: 100);
      state = state.copyWith(
        allRequests: res.requests,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> updateStatus(int id, String status) async {
    try {
      final updated = await _repo.updateRequestStatus(id, status);
      state = state.copyWith(
        allRequests: state.allRequests.map((r) => r.id == id ? updated : r).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteRequest(int id) async {
    try {
      await _repo.deleteRequest(id);
      state = state.copyWith(
        allRequests: state.allRequests.where((r) => r.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final bloodRequestListProvider =
    StateNotifierProvider<BloodRequestListNotifier, BloodRequestListState>((ref) {
  final repo = ref.watch(bloodRequestRepositoryProvider);
  return BloodRequestListNotifier(repo);
});
