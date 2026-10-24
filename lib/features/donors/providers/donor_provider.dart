import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/providers/api_providers.dart';
import '../data/donor_model.dart';
import '../data/donor_repository.dart';

class DonorListState {
  final List<Donor> donors;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int page;
  final int total;
  final String? bloodGroupFilter;
  final String searchQuery;

  const DonorListState({
    this.donors = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.page = 1,
    this.total = 0,
    this.bloodGroupFilter,
    this.searchQuery = '',
  });

  bool get hasMore => donors.length < total;

  DonorListState copyWith({
    List<Donor>? donors,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? page,
    int? total,
    String? bloodGroupFilter,
    String? searchQuery,
  }) {
    return DonorListState(
      donors: donors ?? this.donors,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      page: page ?? this.page,
      total: total ?? this.total,
      bloodGroupFilter: bloodGroupFilter ?? this.bloodGroupFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DonorListNotifier extends StateNotifier<DonorListState> {
  final DonorRepository _repo;

  DonorListNotifier(this._repo) : super(const DonorListState()) {
    fetchDonors();
  }

  Future<void> fetchDonors({
    String? bloodGroup,
    String? search,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      page: 1,
      bloodGroupFilter: bloodGroup,
      searchQuery: search ?? '',
    );

    try {
      final res = await _repo.getDonors(
        bloodGroup: bloodGroup,
        search: search,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(
        donors: res.donors,
        isLoading: false,
        page: res.page,
        total: res.total,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;

    try {
      final res = await _repo.getDonors(
        bloodGroup: state.bloodGroupFilter,
        search: state.searchQuery,
        page: nextPage,
        limit: 20,
      );

      state = state.copyWith(
        donors: [...state.donors, ...res.donors],
        isLoadingMore: false,
        page: res.page,
        total: res.total,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> registerDonor({
    required String name,
    required int age,
    required String gender,
    required String bloodGroup,
    required String phone,
    required String address,
  }) async {
    try {
      final newDonor = await _repo.registerDonor(
        name: name,
        age: age,
        gender: gender,
        bloodGroup: bloodGroup,
        phone: phone,
        address: address,
      );
      state = state.copyWith(
        donors: [newDonor, ...state.donors],
        total: state.total + 1,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deactivateDonor(int id) async {
    try {
      await _repo.deactivateDonor(id);
      state = state.copyWith(
        donors: state.donors.where((d) => d.id != id).toList(),
        total: state.total > 0 ? state.total - 1 : 0,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDonor(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.updateDonor(id, data);
      state = state.copyWith(
        donors: state.donors.map((d) => d.id == id ? updated : d).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

final donorListProvider =
    StateNotifierProvider<DonorListNotifier, DonorListState>((ref) {
  final repo = ref.watch(donorRepositoryProvider);
  return DonorListNotifier(repo);
});
