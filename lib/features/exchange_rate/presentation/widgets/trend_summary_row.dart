import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/exchange_rate_trend.dart';

class TrendSummaryRow extends StatelessWidget {
  final int days;
  final double changePercentage;
  final TrendDirection direction;

  const TrendSummaryRow({
    super.key,
    required this.days,
    required this.changePercentage,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeText, badgeIcon, textColor, bgColor) = switch (direction) {
      TrendDirection.up => (
        'สูงขึ้น',
        Icons.arrow_upward,
        AppColors.statusUp,
        AppColors.statusUpSubtle,
      ),
      TrendDirection.down => (
        'ลดลง',
        Icons.arrow_downward,
        AppColors.statusDown,
        AppColors.statusDownSubtle,
      ),
      TrendDirection.neutral => (
        'ทรงตัว',
        Icons.remove,
        AppColors.statusNeutral,
        AppColors.statusNeutralSubtle,
      ),
    };

    final String formattedPercent;
    if (changePercentage > 0) {
      formattedPercent = '+${changePercentage.toStringAsFixed(2)}%';
    } else if (changePercentage < 0) {
      formattedPercent = '${changePercentage.toStringAsFixed(2)}%';
    } else {
      formattedPercent = '0.00%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'เปลี่ยนแปลง $days วัน',
              style: AppTypography.bodyDefault.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            formattedPercent,
            style: AppTypography.heading.copyWith(color: textColor),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, size: 14.0, color: textColor),
                const SizedBox(width: 4.0),
                Text(
                  badgeText,
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
