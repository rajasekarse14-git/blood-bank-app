import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable badge displaying blood group (e.g. A+, O-) with themed styling.
class BloodBadge extends StatelessWidget {
  final String bloodGroup;
  final double size;
  final bool isFilled;

  const BloodBadge({
    super.key,
    required this.bloodGroup,
    this.size = 40,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primary : AppColors.badgeRedBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isFilled ? AppColors.primaryDark : AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Text(
        bloodGroup,
        style: TextStyle(
          color: isFilled ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
