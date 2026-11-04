import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PeriodSegmentedControl extends StatelessWidget {
  final int selectedDays;
  final bool isLoading;
  final ValueChanged<int> onPeriodSelected;

  const PeriodSegmentedControl({
    super.key,
    required this.selectedDays,
    required this.isLoading,
    required this.onPeriodSelected,
  });

  static const List<int> _periods = [7, 30, 90];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: _periods.map((days) {
          final isSelected = selectedDays == days;
          return Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : () => onPeriodSelected(days),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.bgSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$days วัน',
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.brandPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
