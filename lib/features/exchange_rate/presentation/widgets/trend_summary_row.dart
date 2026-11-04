import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/exchange_rate_trend.dart';

class TrendSummaryRow extends StatelessWidget {
  final int days;
  final double changePercentage;
  final TrendDirection direction;
  final double? firstRate;
  final double? lastRate;

  const TrendSummaryRow({
    super.key,
    required this.days,
    required this.changePercentage,
    required this.direction,
    this.firstRate,
    this.lastRate,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeText, badgeIcon, textColor, bgColor) = switch (direction) {
      TrendDirection.up => (
        'สูงขึ้น',
        Icons.trending_up,
        AppColors.badgeInfoText,
        AppColors.badgeInfoBg,
      ),
      TrendDirection.down => (
        'ลดลง',
        Icons.trending_down,
        AppColors.badgeDownText,
        AppColors.badgeDownBg,
      ),
      TrendDirection.neutral => (
        'ทรงตัว',
        Icons.remove,
        AppColors.badgeNeutralText,
        AppColors.badgeNeutralBg,
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

    final hasRateRange = firstRate != null && lastRate != null;
    final subtitleText = hasRateRange
        ? 'จาก ${firstRate!.toStringAsFixed(3)} เป็น ${lastRate!.toStringAsFixed(3)}'
        : 'เทียบกับช่วงเริ่มต้น';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Data Row (Figma EL-537b9914)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: AppColors.borderDefault, width: 1.0),
          ),
          child: Row(
            children: [
              Icon(badgeIcon, size: 22.0, color: AppColors.textSecondary),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'เปลี่ยนแปลง $days วัน',
                      style: AppTypography.bodyDefault.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitleText,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                formattedPercent,
                style: AppTypography.heading.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),

        // Level Badge (Figma EL-e15384b6)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999.0),
          ),
          child: Text(
            badgeText,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
