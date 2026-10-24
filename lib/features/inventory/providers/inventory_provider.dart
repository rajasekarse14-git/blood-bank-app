import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/providers/api_providers.dart';
import '../data/inventory_model.dart';
import '../data/inventory_repository.dart';

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryItem>>> {
  final InventoryRepository _repo;

  InventoryNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.getInventory();
      state = AsyncValue.data(items);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<bool> updateUnits(String bloodGroup, int units) async {
    try {
      final updated = await _repo.updateInventory(bloodGroup, units);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((item) {
        if (item.bloodGroup == bloodGroup) {
          return updated;
        }
        return item;
      }).toList();

      state = AsyncValue.data(updatedList);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, AsyncValue<List<InventoryItem>>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repo);
});

/// Search blood provider family
final searchBloodProvider =
    FutureProvider.family<SearchResult, String>((ref, bloodGroup) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.searchBlood(bloodGroup);
});
