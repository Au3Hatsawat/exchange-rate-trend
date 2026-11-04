import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/currency_pair.dart';

class CurrencySelectorCard extends StatelessWidget {
  final CurrencyPair pair;
  final VoidCallback? onTap;

  const CurrencySelectorCard({super.key, required this.pair, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'คู่สกุล',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4.0),
        Material(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 48.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppColors.borderDefault, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${pair.base} → ${pair.quote}',
                      style: AppTypography.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
