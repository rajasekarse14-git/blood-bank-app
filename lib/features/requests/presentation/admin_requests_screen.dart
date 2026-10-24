import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/blood_badge.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/blood_request_provider.dart';
import '../data/blood_request_model.dart';

/// Admin Requests Screen: status filter chips, search, status change modal, and deletion.
class AdminRequestsScreen extends ConsumerStatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  ConsumerState<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends ConsumerState<AdminRequestsScreen> {
  final _searchController = TextEditingController();

  static const List<String> statusTabs = [
    'all', 'pending', 'processing', 'fulfilled', 'cancelled'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStatusBottomSheet(BloodRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String selectedStatus = request.status.toLowerCase();
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.referenceId,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            request.patientName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      BloodBadge(bloodGroup: request.bloodGroup, size: 40),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hospital:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(request.hospital, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quantity Needed:', style: TextStyle(color: Colors.grey.shade600)),
                      Text('${request.quantity} Units', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Emergency Contact:', style: TextStyle(color: Colors.grey.shade600)),
                      Text(request.contact, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Update Request Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['pending', 'processing', 'fulfilled', 'cancelled'].map((st) {
                      final isSelected = selectedStatus == st;
                      Color chipColor;
                      switch (st) {
                        case 'pending':
                          chipColor = AppColors.low;
                          break;
                        case 'processing':
                          chipColor = const Color(0xFF0288D1);
                          break;
                        case 'fulfilled':
                          chipColor = AppColors.healthy;
                          break;
                        case 'cancelled':
                        default:
                          chipColor = Colors.grey.shade600;
                      }

                      return ChoiceChip(
                        label: Text(
                          st.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : chipColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: chipColor,
                        showCheckmark: false,
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedStatus = st;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(
                        '/tracking',
                        extra: {
                          'referenceId': request.referenceId,
                          'patientName': request.patientName,
                          'hospital': request.hospital,
                          'bloodGroup': request.bloodGroup,
                          'quantity': request.quantity,
                        },
                      );
                    },
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: const Text('Track Live Delivery on Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.healthy,
                      side: const BorderSide(color: AppColors.healthy, width: 1.5),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              final ok = await ref
                                  .read(bloodRequestListProvider.notifier)
                                  .updateStatus(request.id, selectedStatus);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? 'Status updated to ${selectedStatus.toUpperCase()}'
                                        : 'Failed to update status'),
                                    backgroundColor: ok ? AppColors.healthy : AppColors.critical,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save Status'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BloodRequest request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request?'),
        content: Text(
          'Are you sure you want to delete blood request for "${request.patientName}" (${request.referenceId})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(bloodRequestListProvider.notifier).deleteRequest(request.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Request deleted' : 'Failed to delete request'),
                    backgroundColor: ok ? AppColors.healthy : AppColors.critical,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bloodRequestListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Requests'),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by patient, hospital, ref ID...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(bloodRequestListProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(bloodRequestListProvider.notifier).setSearchQuery(val);
              },
            ),
          ),

          // STATUS FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: statusTabs.map((st) {
                final isSelected = state.statusFilter == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      st.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      ref.read(bloodRequestListProvider.notifier).setStatusFilter(st);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // REQUEST LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(bloodRequestListProvider.notifier).fetchRequests(),
              color: AppColors.primary,
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerListPlaceholder(count: 4, itemHeight: 90),
                    );
                  }

                  if (state.errorMessage != null) {
                    return ErrorView(
                      message: state.errorMessage!,
                      onRetry: () => ref.read(bloodRequestListProvider.notifier).fetchRequests(),
                    );
                  }

                  final requests = state.filteredRequests;

                  if (requests.isEmpty) {
                    return EmptyView(
                      title: 'No Blood Requests Found',
                      message: 'No requests match the selected status or query.',
                      icon: Icons.assignment_outlined,
                      action: state.statusFilter != 'all'
                          ? TextButton(
                              onPressed: () {
                                ref.read(bloodRequestListProvider.notifier).setStatusFilter('all');
                              },
                              child: const Text('Show All Requests'),
                            )
                          : null,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final req = requests[index];

                      Color statusBadgeColor;
                      switch (req.status.toLowerCase()) {
                        case 'pending':
                          statusBadgeColor = AppColors.low;
                          break;
                        case 'processing':
                          statusBadgeColor = const Color(0xFF0288D1);
                          break;
                        case 'fulfilled':
                          statusBadgeColor = AppColors.healthy;
                          break;
                        case 'cancelled':
                        default:
                          statusBadgeColor = Colors.grey.shade600;
                      }

                      return Dismissible(
                        key: ValueKey(req.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.critical,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          _confirmDelete(req);
                          return false; // dialog handles delete
                        },
                        child: InkWell(
                          onTap: () => _showStatusBottomSheet(req),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.brightness == Brightness.dark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                BloodBadge(bloodGroup: req.bloodGroup, size: 44),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            req.referenceId,
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusBadgeColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              req.status.toUpperCase(),
                                              style: TextStyle(
                                                color: statusBadgeColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        req.patientName,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${req.quantity} Units • ${req.hospital}',
                                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextMuted),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
