import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/blood_badge.dart';
import '../../../core/widgets/custom_button.dart';

/// Screen displayed after a successful blood request submission.
class RequestSuccessScreen extends StatelessWidget {
  final String referenceId;
  final String patientName;
  final String bloodGroup;
  final int quantity;
  final String hospital;

  const RequestSuccessScreen({
    super.key,
    required this.referenceId,
    required this.patientName,
    required this.bloodGroup,
    required this.quantity,
    required this.hospital,
  });

  void _copyReferenceId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referenceId));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Reference ID $referenceId copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.healthy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Submitted'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SUCCESS ICON
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.badgeGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.healthy,
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Emergency Request Placed!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The hospital blood bank team has received your urgent request.',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // REFERENCE ID CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR TRACKING REFERENCE ID',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      referenceId,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _copyReferenceId(context),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy Reference ID'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size(180, 42),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // REQUEST SUMMARY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Patient', patientName),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Blood Group', style: TextStyle(color: AppColors.lightTextSecondary)),
                        BloodBadge(bloodGroup: bloodGroup, size: 30),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildSummaryRow('Quantity', '$quantity Units'),
                    const Divider(height: 20),
                    _buildSummaryRow('Hospital', hospital),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // LIVE MAP TRACKING BUTTON
              CustomButton(
                text: 'Track Live Blood Delivery (Live Map)',
                icon: Icons.map_rounded,
                backgroundColor: AppColors.healthy,
                onPressed: () {
                  context.push(
                    '/tracking',
                    extra: {
                      'referenceId': referenceId,
                      'patientName': patientName,
                      'bloodGroup': bloodGroup,
                      'quantity': quantity,
                      'hospital': hospital,
                    },
                  );
                },
              ),
              const SizedBox(height: 12),

              // RETURN HOME BUTTON
              CustomButton(
                text: 'Return to Home',
                icon: Icons.home_rounded,
                isOutlined: true,
                onPressed: () {
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.lightTextSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
