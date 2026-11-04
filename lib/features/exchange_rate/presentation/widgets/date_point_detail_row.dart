import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/rate_point.dart';

class DatePointDetailRow extends StatelessWidget {
  final RatePoint point;

  const DatePointDetailRow({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    final thaiDate = DateFormatter.formatThaiShortDate(point.date);
    final rateStr = point.rate.toStringAsFixed(3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: const BoxDecoration(
              color: AppColors.brandPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            '$thaiDate · $rateStr',
            style: AppTypography.bodyDefault.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(point.quote, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
