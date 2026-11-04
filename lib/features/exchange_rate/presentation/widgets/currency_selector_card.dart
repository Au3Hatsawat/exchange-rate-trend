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
    return Material(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: AppColors.borderDefault, width: 1.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${pair.base} → ${pair.quote}',
                  style: AppTypography.heading,
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
    );
  }
}
