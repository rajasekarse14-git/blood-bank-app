import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/blood_badge.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/inventory_provider.dart';

/// Admin Inventory Screen: 8 blood groups with +/- stepper and save button per card to PUT units.
class AdminInventoryScreen extends ConsumerStatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  ConsumerState<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends ConsumerState<AdminInventoryScreen> {
  final Map<String, int> _localUnits = {};
  final Set<String> _savingGroups = {};

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh Inventory',
            onPressed: () {
              ref.read(inventoryProvider.notifier).fetchInventory();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: inventoryAsync.when(
        data: (items) {
          final sortedItems = [...items]..sort((a, b) => a.bloodGroup.compareTo(b.bloodGroup));

          // Sync local map
          for (final it in sortedItems) {
            _localUnits.putIfAbsent(it.bloodGroup, () => it.units);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _localUnits.clear();
              await ref.read(inventoryProvider.notifier).fetchInventory();
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // INVENTORY OVERVIEW CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.badgeRedBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Adjust units in the regional bank using + / - steppers and tap Save to commit changes immediately.',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // GRID OF 8 CARDS
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      final currentUnits = _localUnits[item.bloodGroup] ?? item.units;
                      final isSaving = _savingGroups.contains(item.bloodGroup);
                      final stockColor = AppColors.getStockColor(currentUnits);
                      final stockLabel = AppColors.getStockLabel(currentUnits);
                      final hasChanged = currentUnits != item.units;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasChanged ? AppColors.primary : stockColor.withOpacity(0.4),
                            width: hasChanged ? 2 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: stockColor.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // TOP ROW: BADGE + STATUS PILL
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BloodBadge(bloodGroup: item.bloodGroup, size: 38),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: stockColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    stockLabel,
                                    style: TextStyle(
                                      color: stockColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // STEPPER ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton.filledTonal(
                                  onPressed: currentUnits > 0
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            _localUnits[item.bloodGroup] = currentUnits - 1;
                                          });
                                        }
                                      : null,
                                  icon: const Icon(Icons.remove, size: 16),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '$currentUnits',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: stockColor,
                                    ),
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _localUnits[item.bloodGroup] = currentUnits + 1;
                                    });
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),

                            // SAVE BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        setState(() {
                                          _savingGroups.add(item.bloodGroup);
                                        });

                                        final ok = await ref
                                            .read(inventoryProvider.notifier)
                                            .updateUnits(item.bloodGroup, currentUnits);

                                        if (mounted) {
                                          setState(() {
                                            _savingGroups.remove(item.bloodGroup);
                                          });
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(ok
                                                  ? '${item.bloodGroup} units updated to $currentUnits'
                                                  : 'Failed to update ${item.bloodGroup}'),
                                              backgroundColor:
                                                  ok ? AppColors.healthy : AppColors.critical,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasChanged ? AppColors.primary : Colors.grey.shade700,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        hasChanged ? 'Save Changes' : 'Save',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerGridPlaceholder(count: 8),
        ),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(inventoryProvider.notifier).fetchInventory(),
        ),
      ),
    );
  }
}
