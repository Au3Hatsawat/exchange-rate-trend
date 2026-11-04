import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class StatCardCompact extends StatelessWidget {
  final String label;
  final double rate;

  const StatCardCompact({super.key, required this.label, required this.rate});

  @override
  Widget build(BuildContext context) {
    final isMax = label == 'สูงสุด';
    final iconData = isMax ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, size: 16.0, color: AppColors.textSecondary),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              rate.toStringAsFixed(3),
              style: AppTypography.statValue,
            ),
          ),
        ],
      ),
    );
  }
}
