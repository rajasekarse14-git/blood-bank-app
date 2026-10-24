import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/widgets/blood_badge.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/donor_provider.dart';
import '../data/donor_model.dart';

/// Admin Donors Screen: infinite-scroll pagination, debounced search (400ms), edit & deactivate.
class AdminDonorsScreen extends ConsumerStatefulWidget {
  const AdminDonorsScreen({super.key});

  @override
  ConsumerState<AdminDonorsScreen> createState() => _AdminDonorsScreenState();
}

class _AdminDonorsScreenState extends ConsumerState<AdminDonorsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 400));

  String? _selectedBloodGroup;

  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(donorListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      ref.read(donorListProvider.notifier).fetchDonors(
            bloodGroup: _selectedBloodGroup,
            search: query.trim(),
          );
    });
  }

  void _showEditDonorDialog(Donor donor) {
    final nameCtrl = TextEditingController(text: donor.name);
    final phoneCtrl = TextEditingController(text: donor.phone);
    final addressCtrl = TextEditingController(text: donor.address);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Donor: ${donor.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(donorListProvider.notifier).updateDonor(
                donor.id,
                {
                  'name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'address': addressCtrl.text.trim(),
                },
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Donor updated successfully' : 'Failed to update donor'),
                    backgroundColor: ok ? AppColors.healthy : AppColors.critical,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivateDonor(Donor donor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Donor?'),
        content: Text(
          'Are you sure you want to deactivate ${donor.name}? They will no longer appear in public donor searches.',
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
              final ok = await ref.read(donorListProvider.notifier).deactivateDonor(donor.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Donor deactivated' : 'Failed to deactivate donor'),
                    backgroundColor: ok ? AppColors.healthy : AppColors.critical,
                  ),
                );
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donorListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donors Registry'),
      ),
      body: Column(
        children: [
          // DEBOUNCED SEARCH BAR (400ms)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search donor by name, phone, address...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // BLOOD GROUP FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('ALL'),
                    selected: _selectedBloodGroup == null,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _selectedBloodGroup == null ? Colors.white : theme.textTheme.bodyMedium?.color,
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedBloodGroup = null;
                      });
                      ref.read(donorListProvider.notifier).fetchDonors(
                            bloodGroup: null,
                            search: _searchController.text.trim(),
                          );
                    },
                  ),
                ),
                ...bloodGroups.map((bg) {
                  final isSelected = _selectedBloodGroup == bg;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(bg),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      ),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedBloodGroup = bg;
                        });
                        ref.read(donorListProvider.notifier).fetchDonors(
                              bloodGroup: bg,
                              search: _searchController.text.trim(),
                            );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // DONOR LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(donorListProvider.notifier).fetchDonors(
                    bloodGroup: _selectedBloodGroup,
                    search: _searchController.text.trim(),
                  ),
              color: AppColors.primary,
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerListPlaceholder(count: 5, itemHeight: 88),
                    );
                  }

                  if (state.errorMessage != null) {
                    return ErrorView(
                      message: state.errorMessage!,
                      onRetry: () => ref.read(donorListProvider.notifier).fetchDonors(
                            bloodGroup: _selectedBloodGroup,
                            search: _searchController.text.trim(),
                          ),
                    );
                  }

                  if (state.donors.isEmpty) {
                    return const EmptyView(
                      title: 'No Registered Donors Found',
                      message: 'No donors match the search query or filter.',
                      icon: Icons.people_outline_rounded,
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.donors.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.donors.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final donor = state.donors[index];

                      return Container(
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
                            BloodBadge(bloodGroup: donor.bloodGroup, size: 44),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donor.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${donor.age} yrs • ${donor.gender} • ${donor.phone}',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    donor.address,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: AppColors.lightTextMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              onSelected: (action) {
                                if (action == 'edit') {
                                  _showEditDonorDialog(donor);
                                } else if (action == 'deactivate') {
                                  _confirmDeactivateDonor(donor);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'deactivate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_off_outlined, color: AppColors.critical, size: 18),
                                      SizedBox(width: 8),
                                      Text('Deactivate', style: TextStyle(color: AppColors.critical)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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
