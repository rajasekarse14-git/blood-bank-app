import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/blood_badge.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../donors/providers/donor_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

/// Public Find Blood Screen: Blood group chips, inventory status, and matching donors.
class FindBloodScreen extends ConsumerStatefulWidget {
  final String initialBloodGroup;

  const FindBloodScreen({super.key, this.initialBloodGroup = 'A+'});

  @override
  ConsumerState<FindBloodScreen> createState() => _FindBloodScreenState();
}

class _FindBloodScreenState extends ConsumerState<FindBloodScreen> {
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  late String selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    selectedBloodGroup = widget.initialBloodGroup;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDonorsForGroup(selectedBloodGroup);
    });
  }

  void _loadDonorsForGroup(String bg) {
    ref.read(donorListProvider.notifier).fetchDonors(bloodGroup: bg);
  }

  Future<void> _callDonor(String phone) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot initiate call to $phone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchBloodProvider(selectedBloodGroup));
    final donorState = ref.watch(donorListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Blood & Donors'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BLOOD GROUP SELECTOR HEADER
            Text(
              'Select Required Blood Group',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // CHIPS ROW / WRAP
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bloodGroups.map((bg) {
                final isSelected = bg == selectedBloodGroup;
                return ChoiceChip(
                  label: Text(
                    bg,
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: theme.cardTheme.color,
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.lightBorder,
                      width: 1.5,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedBloodGroup = bg;
                      });
                      _loadDonorsForGroup(bg);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // BLOOD BANK INVENTORY AVAILABILITY CARD
            Text(
              'Central Blood Bank Stock',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            searchAsync.when(
              data: (result) {
                final stockColor = AppColors.getStockColor(result.units);
                final stockLabel = AppColors.getStockLabel(result.units);

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: stockColor.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: stockColor.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      BloodBadge(bloodGroup: result.bloodGroup, size: 54),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${result.units} Units Available',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: stockColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                stockLabel,
                                style: TextStyle(
                                  color: stockColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        result.available ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: stockColor,
                        size: 28,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const ShimmerLoading(
                width: double.infinity,
                height: 90,
                borderRadius: 16,
              ),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(searchBloodProvider(selectedBloodGroup)),
              ),
            ),
            const SizedBox(height: 28),

            // MATCHING REGISTERED DONORS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Matching Registered Donors',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${donorState.donors.length} found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (donorState.isLoading)
              const ShimmerListPlaceholder(count: 3, itemHeight: 96)
            else if (donorState.errorMessage != null)
              ErrorView(
                message: donorState.errorMessage!,
                onRetry: () => _loadDonorsForGroup(selectedBloodGroup),
              )
            else if (donorState.donors.isEmpty)
              EmptyView(
                title: 'No Registered Donors Yet',
                message: 'No donors registered for blood group $selectedBloodGroup yet.',
                icon: Icons.person_off_rounded,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: donorState.donors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final donor = donorState.donors[index];

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
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.badgeRedBg,
                          child: Text(
                            donor.name.isNotEmpty ? donor.name[0].toUpperCase() : 'D',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donor.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${donor.age} yrs • ${donor.gender}',
                                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.lightTextMuted),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      donor.address,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 12,
                                        color: AppColors.lightTextMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => _callDonor(donor.phone),
                          icon: const Icon(Icons.phone_rounded, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.healthy,
                            foregroundColor: Colors.white,
                          ),
                          tooltip: 'Call Donor (${donor.phone})',
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
  }
}
