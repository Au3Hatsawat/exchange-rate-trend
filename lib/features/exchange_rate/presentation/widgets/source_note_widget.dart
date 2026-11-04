import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SourceNoteWidget extends StatelessWidget {
  const SourceNoteWidget({super.key});

  static const String frankfurterUrl = 'https://frankfurter.dev';

  Future<void> _openSourceUrl() async {
    final uri = Uri.parse(frankfurterUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: _openSourceUrl,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16.0,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  'อัตราแลกเปลี่ยนจาก Frankfurter (frankfurter.dev)',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12.0,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4.0),
              const Icon(
                Icons.open_in_new,
                size: 14.0,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
